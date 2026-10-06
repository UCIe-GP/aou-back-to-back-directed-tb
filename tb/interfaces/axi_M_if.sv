
import aou_tb_pkg::*;

`timescale 1ns/1ps
interface axi_M_if #(
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
    logic [3:0]            awcache;
    logic [3:0]            awqos;
    logic [2:0]            awprot;
    logic                  awready;
    logic                  awlock;


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
    logic [3:0]            arcache;
    logic [1:0]            arburst;
    logic [2:0]            arprot;
    logic [3:0]            arqos;
    logic                  arvalid;
    logic                  arlock;
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
        // AW
        output awid, awaddr, awlen, awsize, awburst, awvalid, awcache, awprot, awqos, awlock,
        input  awready,
        
        // W
        output wdata, wstrb, wlast, wvalid,
        input  wready,

        // B
        input  bid, bresp, bvalid,
        output bready,
        
        // AR
        output arid, araddr, arlen, arsize, arburst, arvalid, arcache, arprot, arqos, arlock,
        input  arready,
        
        // R
        input  rid, rdata, rresp, rlast, rvalid,
        output rready,

        import task reset_master(),
        import task write_burst(
            input int txn_id, 
            input logic [ADDR_WIDTH-1:0] base_addr, 
            input logic [7:0] burst_len, 
            input logic [DATA_WIDTH-1:0] payload[$], 
            output logic [1:0] response
        ),
        import task read_burst(
            input int txn_id, 
            input logic [ADDR_WIDTH-1:0] base_addr, 
            input logic [7:0] burst_len,
            output logic [DATA_WIDTH-1:0] payload[$], 
            output logic [1:0] response 
        )

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

        awcache <= '0; 
        awprot  <= '0;
        awqos   <= '0;
        awlock  <= '0;

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

        arcache <= '0; 
        arprot  <= '0;
        arqos   <= '0;
        arlock  <= '0;

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
            awcache <= 4'b0011;
            

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

        $display("[WRITE BURST] Response received..");
        response = bresp;

        bready <= 0;
    endtask

   task automatic read_burst(
        input  int txn_id, 
        input  logic [ADDR_WIDTH-1:0] base_addr, 
        input  logic [7:0] burst_len,
        output logic [DATA_WIDTH-1:0] payload[$], 
        output logic [1:0] response 
    );
        // 1. AR Phase
        @(posedge clk);
        arid    <= txn_id;
        araddr  <= base_addr;
        arlen   <= burst_len;
        arsize  <= $clog2(DATA_WIDTH/8);
        arburst <= 2'b01;
        arvalid <= 1'b1;

        do begin
            @(posedge clk);
        end while (!(arvalid && arready));

        arvalid <= 1'b0;

        // 2. R Phase
        payload.delete();
        response = 2'b00;
        rready  <= 1'b1;

        for (int i = 0; i < burst_len + 1; i++) begin
            do begin
                @(posedge clk);
            end while (!(rvalid && rready));

            payload.push_back(rdata);

            if (rresp != 2'b00 && response == 2'b00) begin
                response = rresp;
            end
        end

        rready <= 1'b0;
    endtask



endinterface