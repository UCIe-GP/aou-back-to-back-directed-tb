// ============================================================================
// File: tb/packages/aou_tb_pkg.sv
// Description: Global verification parameters, structures, and types matching
//              the Tenstorrent AOU DUT default configuration.
// ============================================================================
package aou_tb_pkg;

  // --------------------------------------------------------------------------
  // AXI Bus Default Parameters
  // --------------------------------------------------------------------------
  parameter int AXI_ADDR_WIDTH = 32;
  parameter int AXI_DATA_WIDTH = 64;
  parameter int AXI_ID_WIDTH   = 4;

  parameter int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  // --------------------------------------------------------------------------
  // FDI / UCIe Interface Configuration
  // --------------------------------------------------------------------------
  parameter int FDI_DATA_WIDTH = 256;

  // --------------------------------------------------------------------------
  // Verification Environment Constraints
  // --------------------------------------------------------------------------
  // Default to 1 for initial sequential bringup. Increase for pipelined runs.
  parameter int DEFAULT_MAX_OUTSTANDING = 1;

  // --------------------------------------------------------------------------
  // Transaction Structures
  // --------------------------------------------------------------------------
  // // AW Address Descriptor
  // typedef struct packed {
  //   logic [AXI_ID_WIDTH-1:0]   id;
  //   logic [AXI_ADDR_WIDTH-1:0] addr;
  //   logic [7:0]                len;   // AWLEN = beats - 1
  //   logic [2:0]                size;  // AWSIZE
  //   logic [1:0]                burst; // AWBURST
  // } aw_desc_t;

  // // W Payload Beat
  // typedef struct packed {
  //   logic [AXI_DATA_WIDTH-1:0] data;
  //   logic [AXI_STRB_WIDTH-1:0] strb;
  //   logic                      last;
  // } w_beat_t;

  // // In-Flight Tracking Packet (for B channel response matching)
  // typedef struct packed {
  //   logic [AXI_ID_WIDTH-1:0]   id;
  //   logic [AXI_ADDR_WIDTH-1:0] addr;
  //   logic [7:0]                len;
  // } in_flight_txn_t;

endpackage : aou_tb_pkg