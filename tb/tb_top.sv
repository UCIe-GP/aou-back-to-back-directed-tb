// ============================================================================
// File: tb/tb_top.sv
// Description: Top-level testbench connecting DMA Engine directly to Slave.
// ============================================================================
`timescale 1ns/1ps

import aou_tb_pkg::*;

module tb_top;

  // --------------------------------------------------------------------------
  // Clock & Reset Signals
  // --------------------------------------------------------------------------
  logic clk;
  logic rst_n;

  // Clock Generation (10ns period)
  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  // Reset Sequence
  initial begin
    rst_n = 1'b0;
    #25ns;
    rst_n = 1'b1;
  end

  // --------------------------------------------------------------------------
  // Interface Instance
  // --------------------------------------------------------------------------
  axi_if #(
      .ADDR_WIDTH(AXI_ADDR_WIDTH),
      .DATA_WIDTH(AXI_DATA_WIDTH),
      .ID_WIDTH  (AXI_ID_WIDTH),
      .STRB_WIDTH(AXI_STRB_WIDTH)
  ) axi_bus (
      .clk  (clk),
      .rst_n(rst_n)
  );

  // --------------------------------------------------------------------------
  // Module Instantiations
  // --------------------------------------------------------------------------
  // DMA Engine (AXI Master)
  dma_engine #(
      .ADDR_WIDTH   (AXI_ADDR_WIDTH),
      .DATA_WIDTH   (AXI_DATA_WIDTH),
      .ID_WIDTH     (AXI_ID_WIDTH),
      .STRB_WIDTH   (AXI_STRB_WIDTH),
      .MAX_BURST_LEN(AXI_MAX_BURST_LEN),
      .PAGE_SIZE    (AXI_PAGE_SIZE_BYTES)
  ) u_dma_engine (
      .clk  (clk),
      .rst_n(rst_n),
      .intf (axi_bus.Master)
  );

  // Slave Memory Model
  slave #(
      .ADDR_WIDTH   (AXI_ADDR_WIDTH),
      .DATA_WIDTH   (AXI_DATA_WIDTH),
      .ID_WIDTH     (AXI_ID_WIDTH),
      .STRB_WIDTH   (AXI_STRB_WIDTH),
      .MAX_BURST_LEN(AXI_MAX_BURST_LEN),
      .PAGE_SIZE    (AXI_PAGE_SIZE_BYTES)
  ) u_slave (
      .clk  (clk),
      .rst_n(rst_n),
      .intf (axi_bus.Slave)
  );

  // --------------------------------------------------------------------------
  // Waveform Dump & Simulation Timeout Guard
  // --------------------------------------------------------------------------
  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);

    // Timeout guard to prevent infinite loops during debugging
    #10000ns;
    $display("[TB TOP] Simulation watchdog timeout reached.");
    $finish;
  end

endmodule