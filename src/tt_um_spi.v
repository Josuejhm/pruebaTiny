/*
 * Copyright (c) 2024 Ronald
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_spi (          // ← nombre debe coincidir con info.yaml
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire sck      = ui_in[0];
    wire cs_n     = ui_in[1];
    wire mosi     = ui_in[2];
    wire [7:0] tx_data = uio_in[7:0];

    wire       miso;
    wire [7:0] rx_data;
    wire       rx_valid;

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

    assign uo_out  = rx_data;
    assign uio_out = {6'b000000, rx_valid, miso};
    assign uio_oe  = 8'b00000011;

    wire _unused = &{ena, ui_in[7:3], 1'b0};

endmodule