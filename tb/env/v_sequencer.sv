`ifndef V_SEQUENCER_SV
`define V_SEQUENCER_SV

class v_sequencer extends uvm_sequencer;
    `uvm_component_utils(v_sequencer)

    apb_sequencer          apb_sqr_d1;
    apb_sequencer          apb_sqr_d2;
    
    axi_master_sequencer   axi_m_d1_sqr;  // Tx_Die1
    axi_slave_sequencer    axi_s_d1_sqr;  // Rx_Die1

    axi_master_sequencer   axi_m_d2_sqr;  // Tx_Die2
    axi_slave_sequencer    axi_s_d2_sqr;  // Rx_Die2
    
    link_sequencer         link_sqr;

    // TODO Handles for 2 Dies RAL Blocks

    function new(string name = "v_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("v_sequencer", "Constructing virtual sequencer", UVM_HIGH) 
    endfunction

  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
  
endclass

`endif