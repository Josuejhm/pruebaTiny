/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path  — solo lectura
    output wire [7:0] uio_out,  // IOs: Output path — solo escritura
    output wire [7:0] uio_oe,   // IOs: Enable path (1 = salida, 0 = entrada)
    input  wire       ena,      // Siempre 1 cuando está encendido
    input  wire       clk,      // Reloj del sistema
    input  wire       rst_n     // Reset activo en bajo
);

    // -------------------------------------------------------------------------
    // Mapeo de entradas (ui_in)
    //
    //   ui_in[0] → sck   (SPI Clock del maestro)
    //   ui_in[1] → cs_n  (Chip Select, activo en bajo)
    //   ui_in[2] → mosi  (Master Out Slave In)
    //   ui_in[7:3] → no usados
    // -------------------------------------------------------------------------
    wire sck  = ui_in[0];
    wire cs_n = ui_in[1];
    wire mosi = ui_in[2];

    // -------------------------------------------------------------------------
    // tx_data: dato que el slave devolverá al maestro vía MISO
    // Lo leemos desde los pines bidireccionales configurados como entrada
    //
    //   uio_in[7:0] → tx_data[7:0]
    // -------------------------------------------------------------------------
    wire [7:0] tx_data = uio_in[7:0];

    // -------------------------------------------------------------------------
    // Señales internas de salida del spi_slave
    // -------------------------------------------------------------------------
    wire       miso;
    wire [7:0] rx_data;
    wire       rx_valid;

    // -------------------------------------------------------------------------
    // Instancia del SPI Slave
    // CPOL=0, CPHA=0 → Modo 0 (el más común)
    // Cambia los parámetros si necesitas otro modo
    // -------------------------------------------------------------------------
    spi_slave #(
        .CPOL(0),
        .CPHA(0)
    ) u_spi_slave (
        .clk     (clk),
        .rst_n   (rst_n),
        .sck     (sck),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso),
        .tx_data (tx_data),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

    // -------------------------------------------------------------------------
    // Mapeo de salidas
    //
    //   uo_out[7:0] → rx_data   (byte recibido completo)
    //
    //   uio_out[0]  → miso      (línea de datos SPI hacia el maestro)
    //   uio_out[1]  → rx_valid  (pulso 1 ciclo = byte recibido OK)
    //   uio_out[7:2]→ 0         (no usados)
    //
    //   uio_oe[0]   → 1         (miso es SALIDA)
    //   uio_oe[1]   → 1         (rx_valid es SALIDA)
    //   uio_oe[7:2] → 0         (uio_in[7:2] son ENTRADAS para tx_data)
    // -------------------------------------------------------------------------
    assign uo_out  = rx_data;

    assign uio_out = {6'b00_0000, rx_valid, miso};
    assign uio_oe  = 8'b00_000011;

    // Suprimir advertencias de entradas no usadas
    wire _unused = &{ena, ui_in[7:3], 1'b0};

endmodule