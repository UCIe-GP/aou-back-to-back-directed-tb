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
    awid    <= '0;
    awaddr  <= '0;
    awlen   <= '0;
    awsize  <= $clog2(DATA_WIDTH/8);
    awburst <= 2'b01;
    awvalid <= 1'b0;

    wdata   <= '0;
    wstrb   <= '0;
    wlast   <= 1'b0;
    wvalid  <= 1'b0;

    bready  <= 1'b0;

    arid    <= '0;
    araddr  <= '0;
    arlen   <= '0;
    arsize  <= $clog2(DATA_WIDTH/8);
    arburst <= 2'b01;
    arvalid <= 1'b0;

    rready  <= 1'b0;
  endtask

  task automatic write_burst(
    input int txn_id, 
    input logic [ADDR_WIDTH-1:0] base_addr, 
    input logic [7:0] burst_len, 
    input logic [DATA_WIDTH-1:0] payload[$], 
    output logic [1:0] response
  );
    if(!(payload.size() == burst_len + 1)) begin
      $fatal("[WRITE BURST] Payload size %0d doesn't match number of beats %0d", payload.size(), (burst_len + 1));
    end
    fork
      // AW Channel
      begin
        @(posedge clk);
        $display("[WRITE BURST] AW HANDSHAKE START..");
        awid <= txn_id;
        // output awid, awaddr, awlen, awsize, awburst, awvalid,
        awaddr <= base_addr;
        awlen <= burst_len;
        awsize <= $clog2(DATA_WIDTH/8);
        awburst <= 2'b01;
        awvalid <= 1;

        do begin
          @(posedge clk);
        end while (!(awvalid && awready));
        $display("[WRITE BURST] AW HANDSHAKE DONE..");
        awvalid <= 0;
      end

      // W Channel
      begin
        logic [DATA_WIDTH-1:0] beat_data;
        int i = 0;
        @(posedge clk);
        while(payload.size() > 0) begin
          $display("[WRITE BURST] Writing beat %0d START..", ++i);
          beat_data = payload.pop_front(); 
          // output wdata, wstrb, wlast, wvalid,
          wdata <= beat_data;
          wstrb <= '1; 
          wlast <= (payload.size() == 0);
          wvalid <= 1;
          do begin
            @(posedge clk);
          end while (!(wvalid && wready));
          $display("[WRITE BURST] Writing beat %0d DONE..", i);
        end
        wvalid <= 0;
        wlast <= 0;
      end
    join
    
    // B Channel
    $display("[WRITE BURST] Waiting For Burst Write Response..");
    @(posedge clk);
    bready <= 1;

    do begin
      @(posedge clk);
    end while (!bvalid);

    if(bresp != 0) begin
      $error("[WRITE BURST] WRITE TRANSACTION FAILED..");
    end

    $display("[WRITE BURST] Response received..");
    response = bresp;

    bready <= 0;
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