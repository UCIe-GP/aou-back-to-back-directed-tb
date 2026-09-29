`ifndef AOU_BASE_TEST_SV
`define AOU_BASE_TEST_SV

class aou_base_test extends uvm_test;
    `uvm_component_utils(aou_base_test)

    aou_env env;

    axi_master_agent_cfg axi_m_d1_cfg;
    axi_slave_agent_cfg  axi_s_d1_cfg;
    axi_master_agent_cfg axi_m_d2_cfg;
    axi_slave_agent_cfg  axi_s_d2_cfg;

    apb_agent_cfg        apb_d1_cfg;
    apb_agent_cfg        apb_d2_cfg;
    link_agent_cfg       link_cfg;

    // AXI Interfaces for each die
    virtual axi_ifc #() get_axi_m_d1_vif;
    virtual axi_ifc #() get_axi_s_d1_vif;
    virtual axi_ifc #() get_axi_m_d2_vif;
    virtual axi_ifc #() get_axi_s_d2_vif;

    // APB Interfaces
    virtual apb_ifc #() get_apb_d1_vif;
    virtual apb_ifc #() get_apb_d2_vif;

    // Link Interface
    virtual link_ifc #() get_link_vif;

    function new(string name = "aou_base_test", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("aou_base_test", "aou_base_test constructor", UVM_HIGH)
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Creating the components
        env = aou_env::type_id::create("env", this);

        axi_m_d1_cfg = axi_master_agent_cfg::type_id::create("axi_m_d1_cfg");
        axi_s_d1_cfg = axi_slave_agent_cfg::type_id::create("axi_s_d1_cfg");
        apb_d1_cfg   = apb_agent_cfg::type_id::create("apb_d1_cfg");
        axi_m_d2_cfg = axi_master_agent_cfg::type_id::create("axi_m_d2_cfg");
        axi_s_d2_cfg = axi_slave_agent_cfg::type_id::create("axi_s_d2_cfg");
        apb_d2_cfg   = apb_agent_cfg::type_id::create("apb_d2_cfg");
        link_cfg  = link_agent_cfg::type_id::create("link_cfg");

        // Retreiving virtual interfaces from DB
        if (!uvm_config_db#(virtual axi_ifc #())::get(this, "", "axi_master_d1_interface", get_axi_m_d1_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find axi_master_configuration (axi_m_d1_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual axi_ifc #())::get(this, "", "axi_slave_d1_interface", get_axi_s_d1_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find axi_slave_configuration (axi_s_d1_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual axi_ifc #())::get(this, "", "axi_master_d2_interface", get_axi_m_d2_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find axi_master_configuration (axi_m_d2_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual axi_ifc #())::get(this, "", "axi_slave_d2_interface", get_axi_s_d2_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find axi_slave_configuration (axi_s_d2_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual apb_ifc #())::get(this, "", "apb_d1_interface", get_apb_d1_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find apb_configuration (apb_d1_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual apb_ifc #())::get(this, "", "apb_d2_interface", get_apb_d2_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find apb_configuration (apb_d2_vif) in uvm_config_db")
        end

        if (!uvm_config_db#(virtual link_ifc #())::get(this, "", "link_interface", get_link_vif)) begin
            `uvm_fatal("NO_VIF", "Could not find link_configuration (link_vif) in uvm_config_db")
        end

        // Configuring configuration objects.
        axi_m_d1_cfg.is_active = UVM_ACTIVE;
        axi_s_d1_cfg.is_active = UVM_ACTIVE;
        apb_d1_cfg.is_active   = UVM_ACTIVE;

        axi_m_d2_cfg.is_active = UVM_ACTIVE;
        axi_s_d2_cfg.is_active = UVM_ACTIVE;
        apb_d2_cfg.is_active   = UVM_ACTIVE;

        link_cfg.is_active  = UVM_ACTIVE;

        axi_m_d1_cfg.axi_m_vif = get_axi_m_d1_vif;
        axi_s_d1_cfg.axi_s_vif = get_axi_s_d1_vif;
        apb_d1_cfg.apb_vif     = get_apb_d1_vif;

        axi_m_d2_cfg.axi_m_vif = get_axi_m_d2_vif;
        axi_s_d2_cfg.axi_s_vif = get_axi_s_d2_vif;
        apb_d2_cfg.apb_vif     = get_apb_d2_vif;
        link_cfg.link_vif   = get_link_vif;

        uvm_config_db#(axi_master_agent_cfg)::set(this, "env", "axi_m_d1_cfg", axi_m_d1_cfg);
        uvm_config_db#(axi_slave_agent_cfg)::set(this, "env", "axi_s_d1_cfg", axi_s_d1_cfg);

        uvm_config_db#(axi_master_agent_cfg)::set(this, "env", "axi_m_d2_cfg", axi_m_d2_cfg);
        uvm_config_db#(axi_slave_agent_cfg)::set(this, "env", "axi_s_d2_cfg", axi_s_d2_cfg);

        uvm_config_db#(apb_agent_cfg)::set(this, "env", "apb_d1_cfg", apb_d1_cfg);
        uvm_config_db#(apb_agent_cfg)::set(this, "env", "apb_d2_cfg", apb_d2_cfg);

        uvm_config_db#(link_agent_cfg)::set(this, "env", "link_cfg", link_cfg);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        `uvm_info("aou_base_test", "Starting base test execution...", UVM_LOW)
        #1000;
        `uvm_info("aou_base_test", "Base test execution finished.", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass

`endif