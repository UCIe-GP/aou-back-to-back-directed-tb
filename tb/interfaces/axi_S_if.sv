
import aou_tb_pkg::*;

`timescale 1ns/1ps
interface axi_S_if #(
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
    modport Slave (
        // AW
        input awid, awaddr, awlen, awsize, awburst, awvalid, awcache, awprot, awqos, awlock,
        output  awready,
        
        // W
        input wdata, wstrb, wlast, wvalid,
        output  wready,

        // B
        output  bid, bresp, bvalid,
        input bready,
        
        // AR
        input arid, araddr, arlen, arsize, arburst, arvalid, arcache, arprot, arqos, arlock,
        output  arready,
        
        // R
        output  rid, rdata, rresp, rlast, rvalid,
        input rready,

        import task resetSlave()
    );


    //SLAVE TASKS
    task automatic resetSlave();
        awready<=0;
        wready<=0;
        bid<=0;
        bresp<=0;
        bvalid<=0;
        arready<=0;
        rid<=0;
        rresp<=0;
        rlast<=0;
        rvalid<=0;
    endtask


endinterface