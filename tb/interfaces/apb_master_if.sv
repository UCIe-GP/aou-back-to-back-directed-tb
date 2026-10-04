// ============================================================================
// File: tb/interfaces/apb_if.sv
// Description: APB Master & Monitor Interface.
// ============================================================================
`ifndef APB_IF_SV
`define APB_IF_SV

import aou_tb_pkg::*;

interface apb_if #(
    parameter int ADDR_WIDTH = APB_ADDR_WIDTH,
    parameter int DATA_WIDTH = APB_DATA_WIDTH
)(
    input logic pclk,
    input logic presetn
);

  // --------------------------------------------------------------------------
  // Signal Declarations
  // --------------------------------------------------------------------------
  logic                  psel;
  logic                  penable;
  logic                  pwrite;
  logic [ADDR_WIDTH-1:0] paddr;
  logic [DATA_WIDTH-1:0] pwdata;
  logic [DATA_WIDTH-1:0] prdata;
  logic                  pready;
  logic                  pslverr;

  // --------------------------------------------------------------------------
  // Clocking Blocks
  // --------------------------------------------------------------------------
  clocking cb_master @(posedge pclk);
    default input #1step output #1ns;
    output psel, penable, pwrite, paddr, pwdata;
    input  prdata, pready, pslverr;
  endclocking

  clocking cb_monitor @(posedge pclk);
    default input #2;
    input psel, penable, pwrite, paddr, pwdata;
    input prdata, pready, pslverr;
  endclocking

  // --------------------------------------------------------------------------
  // Reset Task
  // --------------------------------------------------------------------------
  task automatic reset_master();
    cb_master.psel    <= 1'b0;
    cb_master.penable <= 1'b0;
    cb_master.pwrite  <= 1'b0;
    cb_master.paddr   <= '0;
    cb_master.pwdata  <= '0;
  endtask

  // --------------------------------------------------------------------------
  // APB Driver Tasks
  // --------------------------------------------------------------------------
  task automatic apb_write(
      input  logic [ADDR_WIDTH-1:0] addr, 
      input  logic [DATA_WIDTH-1:0] data, 
      output logic                  slverr
  );
    // SETUP Phase
    @(cb_master);
    cb_master.psel    <= 1'b1;
    cb_master.penable <= 1'b0;
    cb_master.pwrite  <= 1'b1;
    cb_master.paddr   <= addr;
    cb_master.pwdata  <= data;

    // ACCESS Phase
    @(cb_master);
    cb_master.penable <= 1'b1;

    // Wait for Slave ready handshake
    do begin
      @(cb_master);
    end while (cb_master.pready !== 1'b1);

    slverr = cb_master.pslverr;

    // Return to IDLE State
    cb_master.psel    <= 1'b0;
    cb_master.penable <= 1'b0;
    cb_master.pwrite  <= 1'b0;
  endtask

  task automatic apb_read(
      input  logic [ADDR_WIDTH-1:0] addr, 
      output logic [DATA_WIDTH-1:0] data, 
      output logic                  slverr
  );
    // SETUP Phase
    @(cb_master);
    cb_master.psel    <= 1'b1;
    cb_master.penable <= 1'b0;
    cb_master.pwrite  <= 1'b0;
    cb_master.paddr   <= addr;

    // ACCESS Phase
    @(cb_master);
    cb_master.penable <= 1'b1;

    // Wait for Slave ready handshake
    do begin
      @(cb_master);
    end while (cb_master.pready !== 1'b1);

    data   = cb_master.prdata;
    slverr = cb_master.pslverr;

    // Return to IDLE State
    cb_master.psel    <= 1'b0;
    cb_master.penable <= 1'b0;
  endtask

  task automatic monitor_transaction(
      output logic [ADDR_WIDTH-1:0] addr,
      output logic                  pwrite,
      output logic [DATA_WIDTH-1:0] wdata,
      output logic [DATA_WIDTH-1:0] rdata,
      output logic                  slverr
  );
    do begin
      @(cb_monitor);
    end while (!(cb_monitor.psel && cb_monitor.penable && cb_monitor.pready));

    addr   = cb_monitor.paddr;
    pwrite = cb_monitor.pwrite;
    wdata  = cb_monitor.pwdata;
    rdata  = cb_monitor.prdata;
    slverr = cb_monitor.pslverr;
  endtask

  // --------------------------------------------------------------------------
  // Modports
  // --------------------------------------------------------------------------
  modport master (
    clocking cb_master,
    input    pclk,
    input    presetn,
    import   reset_master,
    import   apb_write,
    import   apb_read
  );

  modport monitor (
    clocking cb_monitor,
    input    pclk,
    input    presetn,
    import   monitor_transaction
  );

endinterface

`endif