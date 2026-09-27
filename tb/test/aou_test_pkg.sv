`ifndef AOU_TEST_PKG_SV
`define AOU_TEST_PKG_SV

package aou_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import apb_pkg::*;
    import axi_pkg::*;
    import link_pkg::*;
    import aou_env_pkg::*;
    `include "v_sequence.sv"
    `include "aou_base_test.sv"
    `include "tc01_csr_reset_test.sv"
    `include "tc02_link_bringup_test.sv"
    `include "tc03_smoke_test.sv"
    `include "tc04_image_tx_rx_test.sv"
    `include "tc05_image_rx_tx_test.sv"
    `include "tc06_image_both_directions_test.sv"
    `include "tc07_image_read_back_test.sv"
    `include "tc08_image_sizes_test.sv"
    `include "tc09_fdi_widths_test.sv"
    `include "tc10_burst_variety_test.sv"
    `include "tc11_outstanding_and_ids_test.sv"
    `include "tc12_backpressure_test.sv"
    `include "tc13_link_latency_test.sv"
    `include "tc14_link_stall_test.sv"
    `include "tc15_low_power_test.sv"

endpackage

`endif