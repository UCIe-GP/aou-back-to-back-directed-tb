`ifndef AOU_BASE_VSEQ_SV
    `define AOU_BASE_VSEQ_SV

class aou_base_vseq extends uvm_sequence;
    `uvm_object_utils(aou_base_vseq)
    `uvm_declare_p_sequencer(v_sequencer)

    apb_sequencer          apb_sqr_d1;
    apb_sequencer          apb_sqr_d2;

    axi_master_sequencer   axi_m_d1_sqr;  // Tx_Die1
    axi_slave_sequencer    axi_s_d1_sqr;  // Rx_Die1

    axi_master_sequencer   axi_m_d2_sqr;  // Tx_Die2
    axi_slave_sequencer    axi_s_d2_sqr;  // Rx_Die2
    
    link_sequencer         link_sqr;

    function new(string name = "aou_base_vseq");
        super.new(name);
        `uvm_info("V_SEQ", "my virtual sequence construction", UVM_HIGH) 
    endfunction

    virtual task pre_body();
        // connected agents sequencers to the sequencers handles of the virtual sequences.
        apb_sqr_d1 = p_sequencer.apb_sqr_d1;
        apb_sqr_d2 = p_sequencer.apb_sqr_d2;

        axi_m_d1_sqr = p_sequencer.axi_m_d1_sqr;
        axi_s_d1_sqr = p_sequencer.axi_s_d1_sqr;

        axi_m_d2_sqr = p_sequencer.axi_m_d2_sqr;
        axi_s_d2_sqr = p_sequencer.axi_s_d2_sqr;

        link_sqr = p_sequencer.link_sqr;
    endtask

    virtual task body();
    endtask

    // HELPER TASKS

    // write_reg(reg, val)
    task write_reg();
    // TODO
    endtask

    // read_reg(reg, val) 
    task read_reg();
    // TODO
    endtask

    // wait_for_reset().
    task wait_for_reset();
    // TODO
    endtask

endclass

`endif