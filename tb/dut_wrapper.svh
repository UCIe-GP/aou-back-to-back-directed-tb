`ifndef DUT_SVH
`define DUT_SVH

`timescale 1ns/1ps
module dut_wrapper (
    input logic clk,
    input logic rst_n,
    input logic pclk,
    input logic presetn,

    apb_if  dut1_apb_if,
    apb_if  dut2_apb_if,
    axi_M_if  axi_if_master,
    axi_S_if  axi_if_slave
);

    parameter int RP_COUNT          = 1;
    parameter int AXI_ADDR_WIDTH    = 64;
    parameter int AXI_ID_WIDTH      = 10;
    
    parameter int D1_AXI_DATA_WIDTH = 256;
    parameter int D1_AXI_STRB_WIDTH = D1_AXI_DATA_WIDTH / 8;

    parameter int D2_AXI_DATA_WIDTH = 512;
    parameter int D2_AXI_STRB_WIDTH = D2_AXI_DATA_WIDTH / 8;

    dma_engine #(
      .ADDR_WIDTH   (AXI_ADDR_WIDTH),
      .DATA_WIDTH   (D1_AXI_DATA_WIDTH),
      .ID_WIDTH     (AXI_ID_WIDTH),
      .STRB_WIDTH   (D1_AXI_STRB_WIDTH),
      .MAX_BURST_LEN(256),
      .PAGE_SIZE    (4096)
    ) 
    u_dma_engine (
      .clk  (clk),
      .rst_n(rst_n),
      .intf (axi_if_master.Master)
    );

    slave #(
        .ADDR_WIDTH   (AXI_ADDR_WIDTH),
        .DATA_WIDTH   (D2_AXI_DATA_WIDTH),
        .ID_WIDTH     (AXI_ID_WIDTH),
        .STRB_WIDTH   (D2_AXI_STRB_WIDTH),
        .MAX_BURST_LEN(256),
        .PAGE_SIZE    (4096)
    ) u_slave (
        .clk  (clk),
        .rst_n(rst_n),
        .intf (axi_if_slave.Slave)
    );

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]   d1_si_awid    = axi_if_master.awid;
    wire [RP_COUNT-1:0][AXI_ADDR_WIDTH-1:0] d1_si_awaddr  = axi_if_master.awaddr;
    wire [RP_COUNT-1:0][7:0]                d1_si_awlen   = axi_if_master.awlen;
    wire [RP_COUNT-1:0][2:0]                d1_si_awsize  = axi_if_master.awsize;
    wire [RP_COUNT-1:0][1:0]                d1_si_awburst = axi_if_master.awburst;
    wire [RP_COUNT-1:0]                     d1_si_awlock  = axi_if_master.awlock;
    wire [RP_COUNT-1:0][3:0]                d1_si_awcache = axi_if_master.awcache;
    wire [RP_COUNT-1:0][2:0]                d1_si_awprot  = axi_if_master.awprot;
    wire [RP_COUNT-1:0][3:0]                d1_si_awqos   = axi_if_master.awqos;
    wire [RP_COUNT-1:0]                     d1_si_awvalid = axi_if_master.awvalid;
    wire [RP_COUNT-1:0]                     d1_si_awready;
    assign axi_if_master.awready = d1_si_awready[0];

    wire [RP_COUNT-1:0][D1_AXI_DATA_WIDTH-1:0] d1_si_wdata  = axi_if_master.wdata;
    wire [RP_COUNT-1:0][D1_AXI_STRB_WIDTH-1:0] d1_si_wstrb  = axi_if_master.wstrb;
    wire [RP_COUNT-1:0]                        d1_si_wlast  = axi_if_master.wlast;
    wire [RP_COUNT-1:0]                        d1_si_wvalid = axi_if_master.wvalid;
    wire [RP_COUNT-1:0]                        d1_si_wready;
    assign axi_if_master.wready = d1_si_wready[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]   d1_si_bid;
    wire [RP_COUNT-1:0][1:0]                d1_si_bresp;
    wire [RP_COUNT-1:0]                     d1_si_bvalid;
    wire [RP_COUNT-1:0]                     d1_si_bready = axi_if_master.bready;
    assign axi_if_master.bid    = d1_si_bid[0];
    assign axi_if_master.bresp  = d1_si_bresp[0];
    assign axi_if_master.bvalid = d1_si_bvalid[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]   d1_si_arid    = axi_if_master.arid;
    wire [RP_COUNT-1:0][AXI_ADDR_WIDTH-1:0] d1_si_araddr  = axi_if_master.araddr;
    wire [RP_COUNT-1:0][7:0]                d1_si_arlen   = axi_if_master.arlen;
    wire [RP_COUNT-1:0][2:0]                d1_si_arsize  = axi_if_master.arsize;
    wire [RP_COUNT-1:0][1:0]                d1_si_arburst = axi_if_master.arburst;
    wire [RP_COUNT-1:0]                     d1_si_arlock  = axi_if_master.arlock;
    wire [RP_COUNT-1:0][3:0]                d1_si_arcache = axi_if_master.arcache;
    wire [RP_COUNT-1:0][2:0]                d1_si_arprot  = axi_if_master.arprot;
    wire [RP_COUNT-1:0][3:0]                d1_si_arqos   = axi_if_master.arqos;
    wire [RP_COUNT-1:0]                     d1_si_arvalid = axi_if_master.arvalid;
    wire [RP_COUNT-1:0]                     d1_si_arready;
    assign axi_if_master.arready = d1_si_arready[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]   d1_si_rid;
    wire [RP_COUNT-1:0][D1_AXI_DATA_WIDTH-1:0] d1_si_rdata;
    wire [RP_COUNT-1:0][1:0]                d1_si_rresp;
    wire [RP_COUNT-1:0]                     d1_si_rlast;
    wire [RP_COUNT-1:0]                     d1_si_rvalid;
    wire [RP_COUNT-1:0]                     d1_si_rready = axi_if_master.rready;
    assign axi_if_master.rid    = d1_si_rid[0];
    assign axi_if_master.rdata  = d1_si_rdata[0];
    assign axi_if_master.rresp  = d1_si_rresp[0];
    assign axi_if_master.rlast  = d1_si_rlast[0];
    assign axi_if_master.rvalid = d1_si_rvalid[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]      d2_mi_awid;
    wire [RP_COUNT-1:0][AXI_ADDR_WIDTH-1:0]    d2_mi_awaddr;
    wire [RP_COUNT-1:0][7:0]                   d2_mi_awlen;
    wire [RP_COUNT-1:0][2:0]                   d2_mi_awsize;
    wire [RP_COUNT-1:0][1:0]                   d2_mi_awburst;
    wire [RP_COUNT-1:0]                        d2_mi_awlock;
    wire [RP_COUNT-1:0][3:0]                   d2_mi_awcache;
    wire [RP_COUNT-1:0][2:0]                   d2_mi_awprot;
    wire [RP_COUNT-1:0][3:0]                   d2_mi_awqos;
    wire [RP_COUNT-1:0]                        d2_mi_awvalid;
    wire [RP_COUNT-1:0]                        d2_mi_awready = axi_if_slave.awready;
    assign axi_if_slave.awid    = d2_mi_awid[0];
    assign axi_if_slave.awaddr  = d2_mi_awaddr[0];
    assign axi_if_slave.awlen   = d2_mi_awlen[0];
    assign axi_if_slave.awsize  = d2_mi_awsize[0];
    assign axi_if_slave.awburst = d2_mi_awburst[0];
    assign axi_if_slave.awlock  = d2_mi_awlock[0];
    assign axi_if_slave.awcache = d2_mi_awcache[0];
    assign axi_if_slave.awprot  = d2_mi_awprot[0];
    assign axi_if_slave.awqos   = d2_mi_awqos[0];
    assign axi_if_slave.awvalid = d2_mi_awvalid[0];

    wire [RP_COUNT-1:0][D2_AXI_DATA_WIDTH-1:0] d2_mi_wdata;
    wire [RP_COUNT-1:0][D2_AXI_STRB_WIDTH-1:0] d2_mi_wstrb;
    wire [RP_COUNT-1:0]                        d2_mi_wlast;
    wire [RP_COUNT-1:0]                        d2_mi_wvalid;
    wire [RP_COUNT-1:0]                        d2_mi_wready = axi_if_slave.wready;
    assign axi_if_slave.wdata  = d2_mi_wdata[0];
    assign axi_if_slave.wstrb  = d2_mi_wstrb[0];
    assign axi_if_slave.wlast  = d2_mi_wlast[0];
    assign axi_if_slave.wvalid = d2_mi_wvalid[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]      d2_mi_bid    = axi_if_slave.bid;
    wire [RP_COUNT-1:0][1:0]                   d2_mi_bresp  = axi_if_slave.bresp;
    wire [RP_COUNT-1:0]                        d2_mi_bvalid = axi_if_slave.bvalid;
    wire [RP_COUNT-1:0]                        d2_mi_bready;
    assign axi_if_slave.bready = d2_mi_bready[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]      d2_mi_arid;
    wire [RP_COUNT-1:0][AXI_ADDR_WIDTH-1:0]    d2_mi_araddr;
    wire [RP_COUNT-1:0][7:0]                   d2_mi_arlen;
    wire [RP_COUNT-1:0][2:0]                   d2_mi_arsize;
    wire [RP_COUNT-1:0][1:0]                   d2_mi_arburst;
    wire [RP_COUNT-1:0]                        d2_mi_arlock;
    wire [RP_COUNT-1:0][3:0]                   d2_mi_arcache;
    wire [RP_COUNT-1:0][2:0]                   d2_mi_arprot;
    wire [RP_COUNT-1:0][3:0]                   d2_mi_arqos;
    wire [RP_COUNT-1:0]                        d2_mi_arvalid;
    wire [RP_COUNT-1:0]                        d2_mi_arready = axi_if_slave.arready;
    assign axi_if_slave.arid    = d2_mi_arid[0];
    assign axi_if_slave.araddr  = d2_mi_araddr[0];
    assign axi_if_slave.arlen   = d2_mi_arlen[0];
    assign axi_if_slave.arsize  = d2_mi_arsize[0];
    assign axi_if_slave.arburst = d2_mi_arburst[0];
    assign axi_if_slave.arlock  = d2_mi_arlock[0];
    assign axi_if_slave.arcache = d2_mi_arcache[0];
    assign axi_if_slave.arprot  = d2_mi_arprot[0];
    assign axi_if_slave.arqos   = d2_mi_arqos[0];
    assign axi_if_slave.arvalid = d2_mi_arvalid[0];

    wire [RP_COUNT-1:0][AXI_ID_WIDTH-1:0]      d2_mi_rid    = axi_if_slave.rid;
    wire [RP_COUNT-1:0][D2_AXI_DATA_WIDTH-1:0] d2_mi_rdata  = axi_if_slave.rdata;
    wire [RP_COUNT-1:0][1:0]                   d2_mi_rresp  = axi_if_slave.rresp;
    wire [RP_COUNT-1:0]                        d2_mi_rlast  = axi_if_slave.rlast;
    wire [RP_COUNT-1:0]                        d2_mi_rvalid = axi_if_slave.rvalid;
    wire [RP_COUNT-1:0]                        d2_mi_rready;
    assign axi_if_slave.rready = d2_mi_rready[0];

    wire [255:0] dut1_lp_32b_data;
    wire         dut1_lp_32b_valid;
    wire         dut1_lp_32b_irdy;
    wire         dut1_lp_32b_stallack;

    wire [255:0] dut2_lp_32b_data;
    wire         dut2_lp_32b_valid;
    wire         dut2_lp_32b_irdy;
    wire         dut2_lp_32b_stallack;

    AOU_CORE_TOP #(
        .RP0_AXI_DATA_WD(D1_AXI_DATA_WIDTH),
        .RP1_AXI_DATA_WD(D1_AXI_DATA_WIDTH),
        .RP2_AXI_DATA_WD(D1_AXI_DATA_WIDTH),
        .RP3_AXI_DATA_WD(D1_AXI_DATA_WIDTH),
        .AXI_PEER_DIE_MAX_DATA_WD(512)
    )
    dut1 (
        .I_CLK                  (clk),
        .I_RESETN               (rst_n),
        .I_PCLK                 (pclk),
        .I_PRESETN              (presetn),
        
        // APB
        .I_AOU_APB_SI0_PSEL     (dut1_apb_if.psel),
        .I_AOU_APB_SI0_PENABLE  (dut1_apb_if.penable),
        .I_AOU_APB_SI0_PADDR    (dut1_apb_if.paddr),
        .I_AOU_APB_SI0_PWRITE   (dut1_apb_if.pwrite),
        .I_AOU_APB_SI0_PWDATA   (dut1_apb_if.pwdata),
        .O_AOU_APB_SI0_PRDATA   (dut1_apb_if.prdata),
        .O_AOU_APB_SI0_PREADY   (dut1_apb_if.pready),
        .O_AOU_APB_SI0_PSLVERR  (dut1_apb_if.pslverr),

        // AW
        .I_AOU_TX_AXI_S_AWID    (d1_si_awid),
        .I_AOU_TX_AXI_S_AWADDR  (d1_si_awaddr),
        .I_AOU_TX_AXI_S_AWLEN   (d1_si_awlen),
        .I_AOU_TX_AXI_S_AWSIZE  (d1_si_awsize),
        .I_AOU_TX_AXI_S_AWBURST (d1_si_awburst),
        .I_AOU_TX_AXI_S_AWLOCK  (d1_si_awlock),
        .I_AOU_TX_AXI_S_AWCACHE (d1_si_awcache),
        .I_AOU_TX_AXI_S_AWPROT  (d1_si_awprot),
        .I_AOU_TX_AXI_S_AWQOS   (d1_si_awqos),
        .I_AOU_TX_AXI_S_AWVALID (d1_si_awvalid),
        .O_AOU_TX_AXI_S_AWREADY (d1_si_awready),

        // W
        .I_AOU_TX_AXI_S_WDATA   (d1_si_wdata),
        .I_AOU_TX_AXI_S_WSTRB   (d1_si_wstrb),
        .I_AOU_TX_AXI_S_WLAST   (d1_si_wlast),
        .I_AOU_TX_AXI_S_WVALID  (d1_si_wvalid),
        .O_AOU_TX_AXI_S_WREADY  (d1_si_wready),

        // B
        .O_AOU_RX_AXI_S_BID     (d1_si_bid),
        .O_AOU_RX_AXI_S_BRESP   (d1_si_bresp),
        .O_AOU_RX_AXI_S_BVALID  (d1_si_bvalid),
        .I_AOU_RX_AXI_S_BREADY  (d1_si_bready),

        // AR
        .I_AOU_TX_AXI_S_ARID    (d1_si_arid),
        .I_AOU_TX_AXI_S_ARADDR  (d1_si_araddr),
        .I_AOU_TX_AXI_S_ARLEN   (d1_si_arlen),
        .I_AOU_TX_AXI_S_ARSIZE  (d1_si_arsize),
        .I_AOU_TX_AXI_S_ARBURST (d1_si_arburst),
        .I_AOU_TX_AXI_S_ARLOCK  (d1_si_arlock),
        .I_AOU_TX_AXI_S_ARCACHE (d1_si_arcache),
        .I_AOU_TX_AXI_S_ARPROT  (d1_si_arprot),
        .I_AOU_TX_AXI_S_ARQOS   (d1_si_arqos),
        .I_AOU_TX_AXI_S_ARVALID (d1_si_arvalid),
        .O_AOU_TX_AXI_S_ARREADY (d1_si_arready),

        // R
        .O_AOU_RX_AXI_S_RID     (d1_si_rid),
        .O_AOU_RX_AXI_S_RDATA   (d1_si_rdata),
        .O_AOU_RX_AXI_S_RRESP   (d1_si_rresp),
        .O_AOU_RX_AXI_S_RLAST   (d1_si_rlast),
        .O_AOU_RX_AXI_S_RVALID  (d1_si_rvalid),
        .I_AOU_RX_AXI_S_RREADY  (d1_si_rready),

        .O_AOU_RX_AXI_M_AWID    (),
        .O_AOU_RX_AXI_M_AWADDR  (),
        .O_AOU_RX_AXI_M_AWLEN   (),
        .O_AOU_RX_AXI_M_AWSIZE  (),
        .O_AOU_RX_AXI_M_AWBURST (),
        .O_AOU_RX_AXI_M_AWLOCK  (),
        .O_AOU_RX_AXI_M_AWCACHE (),
        .O_AOU_RX_AXI_M_AWPROT  (),
        .O_AOU_RX_AXI_M_AWQOS   (),
        .O_AOU_RX_AXI_M_AWVALID (),
        .I_AOU_RX_AXI_M_AWREADY (1'b1),
        .O_AOU_RX_AXI_M_WDATA   (),
        .O_AOU_RX_AXI_M_WSTRB   (),
        .O_AOU_RX_AXI_M_WLAST   (),
        .O_AOU_RX_AXI_M_WVALID  (),
        .I_AOU_RX_AXI_M_WREADY  (1'b1),
        .I_AOU_TX_AXI_M_BID     ('0),
        .I_AOU_TX_AXI_M_BRESP   ('0),
        .I_AOU_TX_AXI_M_BVALID  (1'b0),
        .O_AOU_TX_AXI_M_BREADY  (),
        .O_AOU_RX_AXI_M_ARID    (),
        .O_AOU_RX_AXI_M_ARADDR  (),
        .O_AOU_RX_AXI_M_ARLEN   (),
        .O_AOU_RX_AXI_M_ARSIZE  (),
        .O_AOU_RX_AXI_M_ARBURST (),
        .O_AOU_RX_AXI_M_ARLOCK  (),
        .O_AOU_RX_AXI_M_ARCACHE (),
        .O_AOU_RX_AXI_M_ARPROT  (),
        .O_AOU_RX_AXI_M_ARQOS   (),
        .O_AOU_RX_AXI_M_ARVALID (),
        .I_AOU_RX_AXI_M_ARREADY (1'b1),
        .I_AOU_TX_AXI_M_RID     ('0),
        .I_AOU_TX_AXI_M_RDATA   ('0),
        .I_AOU_TX_AXI_M_RRESP   ('0),
        .I_AOU_TX_AXI_M_RLAST   (1'b0),
        .I_AOU_TX_AXI_M_RVALID  (1'b0),
        .O_AOU_TX_AXI_M_RREADY  (),

        .I_FDI_PL_0_VALID            (dut2_lp_32b_valid),
        .I_FDI_PL_0_DATA             (dut2_lp_32b_data),
        .I_FDI_PL_0_FLIT_CANCEL      (1'b0),
        .I_FDI_PL_0_TRDY             (1'b1),
        .I_FDI_PL_0_STALLREQ         (1'b0),
        .I_FDI_PL_0_STATE_STS        (4'h1),
        .O_FDI_LP_0_DATA             (dut1_lp_32b_data),
        .O_FDI_LP_0_VALID            (dut1_lp_32b_valid),
        .O_FDI_LP_0_IRDY             (dut1_lp_32b_irdy),
        .O_FDI_LP_0_STALLACK         (dut1_lp_32b_stallack),

        .INT_REQ_LINKRESET            (),
        .INT_SI0_ID_MISMATCH          (),
        .INT_MI0_ID_MISMATCH          (),
        .INT_EARLY_RESP_ERR           (),
        .INT_ACTIVATE_START           (),
        .INT_DEACTIVATE_START         (),
        .I_INT_FSM_IN_ACTIVE          (1'b1),
        .I_MST_BUS_CLEANY_COMPLETE    (1'b1),
        .I_SLV_BUS_CLEANY_COMPLETE    (1'b1),
        .TIEL_DFT_MODESCAN            (1'b0)
    );

    AOU_CORE_TOP #(
        .RP0_AXI_DATA_WD(D2_AXI_DATA_WIDTH),
        .RP1_AXI_DATA_WD(D2_AXI_DATA_WIDTH),
        .RP2_AXI_DATA_WD(D2_AXI_DATA_WIDTH),
        .RP3_AXI_DATA_WD(D2_AXI_DATA_WIDTH),
        .AXI_PEER_DIE_MAX_DATA_WD(512)
    )
    dut2 (
        .I_CLK                  (clk),
        .I_RESETN               (rst_n),
        .I_PCLK                 (pclk),
        .I_PRESETN              (presetn),

        .I_AOU_APB_SI0_PSEL     (dut2_apb_if.psel),
        .I_AOU_APB_SI0_PENABLE  (dut2_apb_if.penable),
        .I_AOU_APB_SI0_PADDR    (dut2_apb_if.paddr),
        .I_AOU_APB_SI0_PWRITE   (dut2_apb_if.pwrite),
        .I_AOU_APB_SI0_PWDATA   (dut2_apb_if.pwdata),
        .O_AOU_APB_SI0_PRDATA   (dut2_apb_if.prdata),
        .O_AOU_APB_SI0_PREADY   (dut2_apb_if.pready),
        .O_AOU_APB_SI0_PSLVERR  (dut2_apb_if.pslverr),

        .I_AOU_TX_AXI_S_AWID    ('0),
        .I_AOU_TX_AXI_S_AWADDR  ('0),
        .I_AOU_TX_AXI_S_AWLEN   ('0),
        .I_AOU_TX_AXI_S_AWSIZE  ('0),
        .I_AOU_TX_AXI_S_AWBURST ('0),
        .I_AOU_TX_AXI_S_AWLOCK  ('0),
        .I_AOU_TX_AXI_S_AWCACHE ('0),
        .I_AOU_TX_AXI_S_AWPROT  ('0),
        .I_AOU_TX_AXI_S_AWQOS   ('0),
        .I_AOU_TX_AXI_S_AWVALID (1'b0),
        .O_AOU_TX_AXI_S_AWREADY (),
        .I_AOU_TX_AXI_S_WDATA   ('0),
        .I_AOU_TX_AXI_S_WSTRB   ('0),
        .I_AOU_TX_AXI_S_WLAST   (1'b0),
        .I_AOU_TX_AXI_S_WVALID  (1'b0),
        .O_AOU_TX_AXI_S_WREADY  (),
        .O_AOU_RX_AXI_S_BID     (),
        .O_AOU_RX_AXI_S_BRESP   (),
        .O_AOU_RX_AXI_S_BVALID  (),
        .I_AOU_RX_AXI_S_BREADY  (1'b0),
        .I_AOU_TX_AXI_S_ARID    ('0),
        .I_AOU_TX_AXI_S_ARADDR  ('0),
        .I_AOU_TX_AXI_S_ARLEN   ('0),
        .I_AOU_TX_AXI_S_ARSIZE  ('0),
        .I_AOU_TX_AXI_S_ARBURST ('0),
        .I_AOU_TX_AXI_S_ARLOCK  ('0),
        .I_AOU_TX_AXI_S_ARCACHE ('0),
        .I_AOU_TX_AXI_S_ARPROT  ('0),
        .I_AOU_TX_AXI_S_ARQOS   ('0),
        .I_AOU_TX_AXI_S_ARVALID (1'b0),
        .O_AOU_TX_AXI_S_ARREADY (),
        .O_AOU_RX_AXI_S_RID     (),
        .O_AOU_RX_AXI_S_RDATA   (),
        .O_AOU_RX_AXI_S_RRESP   (),
        .O_AOU_RX_AXI_S_RLAST   (),
        .O_AOU_RX_AXI_S_RVALID  (),
        .I_AOU_RX_AXI_S_RREADY  (1'b0),

        // AW
        .O_AOU_RX_AXI_M_AWID    (d2_mi_awid),
        .O_AOU_RX_AXI_M_AWADDR  (d2_mi_awaddr),
        .O_AOU_RX_AXI_M_AWLEN   (d2_mi_awlen),
        .O_AOU_RX_AXI_M_AWSIZE  (d2_mi_awsize),
        .O_AOU_RX_AXI_M_AWBURST (d2_mi_awburst),
        .O_AOU_RX_AXI_M_AWLOCK  (d2_mi_awlock),
        .O_AOU_RX_AXI_M_AWCACHE (d2_mi_awcache),
        .O_AOU_RX_AXI_M_AWPROT  (d2_mi_awprot),
        .O_AOU_RX_AXI_M_AWQOS   (d2_mi_awqos),
        .O_AOU_RX_AXI_M_AWVALID (d2_mi_awvalid),
        .I_AOU_RX_AXI_M_AWREADY (d2_mi_awready),

        // W
        .O_AOU_RX_AXI_M_WDATA   (d2_mi_wdata),
        .O_AOU_RX_AXI_M_WSTRB   (d2_mi_wstrb),
        .O_AOU_RX_AXI_M_WLAST   (d2_mi_wlast),
        .O_AOU_RX_AXI_M_WVALID  (d2_mi_wvalid),
        .I_AOU_RX_AXI_M_WREADY  (d2_mi_wready),

        // B
        .I_AOU_TX_AXI_M_BID     (d2_mi_bid),
        .I_AOU_TX_AXI_M_BRESP   (d2_mi_bresp),
        .I_AOU_TX_AXI_M_BVALID  (d2_mi_bvalid),
        .O_AOU_TX_AXI_M_BREADY  (d2_mi_bready),

        // AR
        .O_AOU_RX_AXI_M_ARID    (d2_mi_arid),
        .O_AOU_RX_AXI_M_ARADDR  (d2_mi_araddr),
        .O_AOU_RX_AXI_M_ARLEN   (d2_mi_arlen),
        .O_AOU_RX_AXI_M_ARSIZE  (d2_mi_arsize),
        .O_AOU_RX_AXI_M_ARBURST (d2_mi_arburst),
        .O_AOU_RX_AXI_M_ARLOCK  (d2_mi_arlock),
        .O_AOU_RX_AXI_M_ARCACHE (d2_mi_arcache),
        .O_AOU_RX_AXI_M_ARPROT  (d2_mi_arprot),
        .O_AOU_RX_AXI_M_ARQOS   (d2_mi_arqos),
        .O_AOU_RX_AXI_M_ARVALID (d2_mi_arvalid),
        .I_AOU_RX_AXI_M_ARREADY (d2_mi_arready),

        // R
        .I_AOU_TX_AXI_M_RID     (d2_mi_rid),
        .I_AOU_TX_AXI_M_RDATA   (d2_mi_rdata),
        .I_AOU_TX_AXI_M_RRESP   (d2_mi_rresp),
        .I_AOU_TX_AXI_M_RLAST   (d2_mi_rlast),
        .I_AOU_TX_AXI_M_RVALID  (d2_mi_rvalid),
        .O_AOU_TX_AXI_M_RREADY  (d2_mi_rready),

        // FDI Loopback
        .I_FDI_PL_0_VALID            (dut1_lp_32b_valid),
        .I_FDI_PL_0_DATA             (dut1_lp_32b_data),
        .I_FDI_PL_0_FLIT_CANCEL      (1'b0),
        .I_FDI_PL_0_TRDY             (1'b1),
        .I_FDI_PL_0_STALLREQ         (1'b0),
        .I_FDI_PL_0_STATE_STS        (4'h1),
        .O_FDI_LP_0_DATA             (dut2_lp_32b_data),
        .O_FDI_LP_0_VALID            (dut2_lp_32b_valid),
        .O_FDI_LP_0_IRDY             (dut2_lp_32b_irdy),
        .O_FDI_LP_0_STALLACK         (dut2_lp_32b_stallack),

        .INT_REQ_LINKRESET            (),
        .INT_SI0_ID_MISMATCH          (),
        .INT_MI0_ID_MISMATCH          (),
        .INT_EARLY_RESP_ERR           (),
        .INT_ACTIVATE_START           (),
        .INT_DEACTIVATE_START         (),
        .I_INT_FSM_IN_ACTIVE          (1'b1),
        .I_MST_BUS_CLEANY_COMPLETE    (1'b1),
        .I_SLV_BUS_CLEANY_COMPLETE    (1'b1),
        .TIEL_DFT_MODESCAN            (1'b0)
    );

endmodule

`endif