`ifndef V_SEQUENCE_SV
    `define V_SEQUENCE_SV

class v_sequence extends uvm_sequence;
    `uvm_object_utils(v_sequence)
    `uvm_declare_p_sequencer(v_sequencer)

    function new(string name = "v_sequence");
        super.new(name);
        `uvm_info("V_SEQ", "my virtual sequence construction", UVM_HIGH) 
    endfunction

    virtual task pre_body();
    endtask

    virtual task body();
    endtask

endclass

`endif