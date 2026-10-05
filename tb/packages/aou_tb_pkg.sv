// ============================================================================
// File: tb/packages/aou_tb_pkg.sv
// Description: Centralized verification parameters and configuration constants.
// ============================================================================
package aou_tb_pkg;

  // --------------------------------------------------------------------------
  // AXI Bus Parameters
  // --------------------------------------------------------------------------
  parameter int AXI_ADDR_WIDTH = 32;
  parameter int AXI_DATA_WIDTH = 64;
  parameter int AXI_ID_WIDTH   = 4;
  parameter int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

  // --------------------------------------------------------------------------
  // APB Bus Parameters
  // --------------------------------------------------------------------------
  parameter int APB_ADDR_WIDTH = 32;
  parameter int APB_DATA_WIDTH = 32;

  // --------------------------------------------------------------------------
  // Protocol & Memory Constraints
  // --------------------------------------------------------------------------
  parameter int AXI_MAX_BURST_LEN   = 256;  // AXI4 maximum beats per burst
  parameter int AXI_PAGE_SIZE_BYTES = 4096; // 4KB boundary constraint
  
  // --------------------------------------------------------------------------
  // FDI / UCIe Interface Configuration
  // --------------------------------------------------------------------------
  parameter int FDI_DATA_WIDTH = 256;

  // --------------------------------------------------------------------------
  // Testbench Addressing Defaults
  // --------------------------------------------------------------------------
  parameter logic [AXI_ADDR_WIDTH-1:0] DEFAULT_IMAGE_BASE_ADDR = 32'h8000_0000;

  // --------------------------------------------------------------------------
  // Shared Structs
  // --------------------------------------------------------------------------
  // typedef struct packed {
  //   logic [AXI_ID_WIDTH-1:0]   id;
  //   logic [AXI_ADDR_WIDTH-1:0] addr;
  //   logic [7:0]                len;
  // } in_flight_txn_t;

endpackage : aou_tb_pkg