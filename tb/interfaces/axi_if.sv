// ============================================================================
// File: tb/interfaces/axi_if.sv
// Description: Signals interface with Master's BFM tasks to be called by the
// DMA ENGINE.
// ============================================================================
import aou_tb_pkg::*;

interface axi_if #(
    parameter int ADDR_WIDTH = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH = AXI_DATA_WIDTH,
    parameter int ID_WIDTH   = AXI_ID_WIDTH,
    parameter int STRB_WIDTH = AXI_STRB_WIDTH
)(
    input logic clk,
    input logic rst_n
);
  // Write Address Channel (AW)
  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [7:0]            awlen;
  logic [2:0]            awsize;
  logic [1:0]            awburst;
  logic                  awvalid;
  logic                  awready;

  // Write Data Channel (W)
  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wlast;
  logic                  wvalid;
  logic                  wready;

  // Write Response Channel (B)
  logic [ID_WIDTH-1:0]   bid;
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // Read Address Channel (AR)
  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [7:0]            arlen;
  logic [2:0]            arsize;
  logic [1:0]            arburst;
  logic                  arvalid;
  logic                  arready;

  // Read Data Channel (R)
  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;

  // --------------------------------------------------------------------------
  // Modports
  // --------------------------------------------------------------------------
  modport Master (
    output awid, awaddr, awlen, awsize, awburst, awvalid,
    input  awready,
    output wdata, wstrb, wlast, wvalid,
    input  wready,
    input  bid, bresp, bvalid,
    output bready,
    output arid, araddr, arlen, arsize, arburst, arvalid,
    input  arready,
    input  rid, rdata, rresp, rlast, rvalid,
    output rready
    import task reset_master, write_single, write_burst, read_single, read_burst;
  );

  modport Slave (
    input  awid, awaddr, awlen, awsize, awburst, awvalid,
    output awready,
    input  wdata, wstrb, wlast, wvalid,
    output wready,
    output bid, bresp, bvalid,
    input  bready,
    input  arid, araddr, arlen, arsize, arburst, arvalid,
    output arready,
    output rid, rdata, rresp, rlast, rvalid,
    input  rready
  );

  modport Monitor (
    input awid, awaddr, awlen, awsize, awburst, awvalid, awready,
    input wdata, wstrb, wlast, wvalid, wready,
    input bid, bresp, bvalid, bready,
    input arid, araddr, arlen, arsize, arburst, arvalid, arready,
    input rid, rdata, rresp, rlast, rvalid, rready
  );

  // ------------------------------------------------
  // AXI Master TASKS
  // ------------------------------------------------
  
  // reset the master related signals at the beginning.
  task automatic reset_master();
    // RESET THE HANDSHAKE SIGNALS.
  endtask

  task automatic write_burst();
    // TODO
    // I want to processes, one for the AW Channel, and one for the W Channel
    // The Task will take the base address, number of beats, and the payload, then it will start executing the AXI logic
    // for transferring the beats.
    // after the two tasks finish, it will wait for the response on the B channel.
    
  endtask

  task automatic read_burst();
    // TODO
    // TBD
  endtask

  task automatic write_single();
    // TODO
    // We can just wrap the burst to send one beat.
  endtask


  task automatic read_single();
    // TODO
    // TBD
  endtask 

endinterface