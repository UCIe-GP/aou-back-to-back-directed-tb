`ifndef AOU_ENV_SV
`define AOU_ENV_SV

class aou_env extends uvm_env;
    `uvm_component_utils(aou_env)

    // Configuration objects
    axi_master_agent_cfg axi_m_d1_cfg;
    axi_slave_agent_cfg  axi_s_d1_cfg;
    axi_master_agent_cfg axi_m_d2_cfg;
    axi_slave_agent_cfg  axi_s_d2_cfg;

    apb_agent_cfg        apb_d1_cfg;
    apb_agent_cfg        apb_d2_cfg;
    link_agent_cfg       link_cfg;

    // Agents
    apb_agent        apb_agent_d1;
    apb_agent        apb_agent_d2;

    axi_master_agent axi_m_agent_d1;
    axi_slave_agent  axi_s_agent_d1;

    axi_master_agent axi_m_agent_d2;
    axi_slave_agent  axi_s_agent_d2;

    link_agent       D2D_link_agent;

    v_sequencer      v_sqr;


    function new(string name = "aou_env", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("aou_env", "aou_env constructor", UVM_HIGH)
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Creating Components
        apb_agent_d1  = apb_agent::type_id::create("apb_agent_d1", this);
        apb_agent_d2  = apb_agent::type_id::create("apb_agent_d2", this);

        axi_m_agent_d1  = axi_master_agent::type_id::create("axi_m_agent_d1", this);
        axi_s_agent_d1  = axi_slave_agent::type_id::create("axi_s_agent_d1", this);

        axi_m_agent_d2  = axi_master_agent::type_id::create("axi_m_agent_d2", this);
        axi_s_agent_d2  = axi_slave_agent::type_id::create("axi_s_agent_d2", this);

        D2D_link_agent = link_agent::type_id::create("D2D_link_agent", this);

        v_sqr = v_sequencer::type_id::create("v_sqr", this);

        // Retreiving from Config DB.

        // Die 1 configuration objects
        if (!uvm_config_db#(axi_master_agent_cfg)::get(this, "", "axi_m_d1_cfg", axi_m_d1_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get axi_m_d1_cfg from uvm_config_db")
        end
        if (!uvm_config_db#(axi_slave_agent_cfg)::get(this, "", "axi_s_d1_cfg", axi_s_d1_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get axi_s_d1_cfg from uvm_config_db")
        end
        if (!uvm_config_db#(apb_agent_cfg)::get(this, "", "apb_d1_cfg", apb_d1_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get apb_d1_cfg from uvm_config_db")
        end

        uvm_config_db#(axi_master_agent_cfg)::set(this, "axi_m_agent_d1", "axi_master_configuration", axi_m_d1_cfg);
        uvm_config_db#(axi_slave_agent_cfg)::set(this, "axi_s_agent_d1", "axi_slave_configuration", axi_s_d1_cfg);
        uvm_config_db#(apb_agent_cfg)::set(this, "apb_agent_d1", "apb_configuration", apb_d1_cfg);

        // Die 2 configuration objects
        if (!uvm_config_db#(axi_master_agent_cfg)::get(this, "", "axi_m_d2_cfg", axi_m_d2_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get axi_m_d2_cfg from uvm_config_db")
        end
        if (!uvm_config_db#(axi_slave_agent_cfg)::get(this, "", "axi_s_d2_cfg", axi_s_d2_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get axi_s_d2_cfg from uvm_config_db")
        end
        if (!uvm_config_db#(apb_agent_cfg)::get(this, "", "apb_d2_cfg", apb_d2_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get apb_d2_cfg from uvm_config_db")
        end

        uvm_config_db#(axi_master_agent_cfg)::set(this, "axi_m_agent_d2", "axi_master_configuration", axi_m_d2_cfg);
        uvm_config_db#(axi_slave_agent_cfg)::set(this, "axi_s_agent_d2", "axi_slave_configuration", axi_s_d2_cfg);
        uvm_config_db#(apb_agent_cfg)::set(this, "apb_agent_d2", "apb_configuration", apb_d2_cfg);

        // Link Configuration object
        if (!uvm_config_db#(link_agent_cfg)::get(this, "", "link_cfg", link_cfg)) begin
            `uvm_fatal(get_type_name(), "Failed to get link_cfg from uvm_config_db")
        end
        uvm_config_db#(link_agent_cfg)::set(this, "D2D_link_agent", "link_cfg", link_cfg);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        v_sqr.apb_sqr_d1 = apb_agent_d1.apb_sqr;
        v_sqr.apb_sqr_d2 = apb_agent_d2.apb_sqr;

        v_sqr.axi_m_d1_sqr = axi_m_agent_d1.axi_m_sqr;
        v_sqr.axi_s_d1_sqr = axi_s_agent_d1.axi_s_sqr;

        v_sqr.axi_m_d2_sqr = axi_m_agent_d2.axi_m_sqr;
        v_sqr.axi_s_d2_sqr = axi_s_agent_d2.axi_s_sqr;

        v_sqr.link_sqr = D2D_link_agent.link_sqr;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

`endif