`timescale 1ns/1ps

import aou_tb_pkg::*;
`include "dut_wrapper.svh"

module tb_top;

    logic clk, pclk;
    logic rst_n;

    initial begin
        clk = 1'b0;
        forever #5ns clk = ~clk;
    end

    initial begin
        pclk = 1'b0;
        forever #50ns pclk = ~pclk;
    end

    logic presetn;
    assign presetn = rst_n;

    apb_if dut1_apb_if (.pclk(pclk), .presetn(presetn));
    apb_if dut2_apb_if (.pclk(pclk), .presetn(presetn));

    axi_M_if #(
      .ADDR_WIDTH(64),
      .DATA_WIDTH(256), 
      .ID_WIDTH(10),
      .STRB_WIDTH(32)
    ) axi_if_master (.clk(clk), .rst_n(rst_n));

    axi_S_if #(
      .ADDR_WIDTH(64),
      .DATA_WIDTH(512), 
      .ID_WIDTH(10),
      .STRB_WIDTH(64)
    ) axi_if_slave  (.clk(clk), .rst_n(rst_n));

    dut_wrapper u_dut_wrapper (
        .clk          (clk),
        .rst_n        (rst_n),
        .pclk         (pclk),
        .presetn      (presetn),
        .dut1_apb_if  (dut1_apb_if),
        .dut2_apb_if  (dut2_apb_if),
        .axi_if_master(axi_if_master),
        .axi_if_slave (axi_if_slave)
    );

    initial begin
       $display("[TB TOP] Asserting Reset...");
        rst_n = 0;
        
        @(posedge pclk);
        dut1_apb_if.reset_master();
        dut2_apb_if.reset_master();
        
        #500ns;
        rst_n = 1;
        $display("[TB TOP] Reset Released.");
        
        repeat(20) @(posedge pclk);

        $display("[TB TOP] Starting APB Configuration...");
        
        dut1_apb_if.apb_write(32'h4, 32'h1, apb_slverr); 
        dut1_apb_if.apb_write(32'h8, 32'h1, apb_slverr);
        dut2_apb_if.apb_write(32'h8, 32'h1, apb_slverr);
        $display("[TB TOP] APB Configuration Complete.");
        repeat(50) @(posedge pclk);
    end

    // --------------------------------------------------------------------------
    // Waveform Dump & Simulation Timeout Guard
    // --------------------------------------------------------------------------
    initial begin
        // $dumpfile("tb_top.vcd");
        // $dumpvars(0, tb_top);

        #10000ns;
        $display("[TB TOP] Simulation watchdog timeout reached.");
        $finish;
    end

endmodule