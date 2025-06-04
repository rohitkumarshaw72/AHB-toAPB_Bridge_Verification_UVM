
class ahb_apb_test extends uvm_test;

    `uvm_component_utils(ahb_apb_test)
    
    ahb_apb_env envh;
    ahb_apb_env_config m_cfg;
    ahb_config ahb_cfg[];
    apb_config apb_cfg[];
    
    int no_of_ahb_agt = 1;
    int no_of_apb_agt = 1;
    
    function new(string name="ahb_apb_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void config_bridge();
        begin
            ahb_cfg = new[no_of_ahb_agt];
            foreach(ahb_cfg[i])  begin
                ahb_cfg[i]=ahb_config::type_id::create($sformatf("ahb_cfg[%0d]",i));
                if(!uvm_config_db #(virtual ahb_apb_if)::get(this,"","vif",ahb_cfg[i].vif))
                    `uvm_fatal("AHB_VIF_CONFIG","Cannot get() vif from uvm_config_db, have you set() it?")
                ahb_cfg[i].is_active = UVM_ACTIVE;
                m_cfg.ahb_cfg[i] = ahb_cfg[i];
            end
        end
        
        begin
            apb_cfg = new[no_of_apb_agt];
            foreach(apb_cfg[i])  begin
                apb_cfg[i]=apb_config::type_id::create($sformatf("apb_cfg[%0d]",i));
                if(!uvm_config_db #(virtual ahb_apb_if)::get(this,"","vif",apb_cfg[i].vif))
                    `uvm_fatal("APB_VIF_CONFIG","Cannot get() vif from uvm_config_db, have you set() it?")
                apb_cfg[i].is_active = UVM_ACTIVE;
                m_cfg.apb_cfg[i] = apb_cfg[i];
            end
        end
        
        m_cfg.no_of_ahb_agt = no_of_ahb_agt;
        m_cfg.no_of_apb_agt = no_of_apb_agt;
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_cfg=ahb_apb_env_config::type_id::create("m_cfg");
        if(m_cfg.has_hagent)  begin
            m_cfg.ahb_cfg = new[no_of_ahb_agt];
        end
        if(m_cfg.has_pagent)  begin
            m_cfg.apb_cfg = new[no_of_apb_agt];
        end
        config_bridge();
        uvm_config_db #(ahb_apb_env_config)::set(this,"*","ahb_apb_env_config",m_cfg);
        envh=ahb_apb_env::type_id::create("envh",this);
    endfunction

endclass



class ahb_incr_test extends ahb_apb_test;

    `uvm_component_utils(ahb_incr_test)
    
    ahb_incr_seq iseq;
    
    function new(string name="ahb_incr_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TEST","Printing UVM TB Topology",UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction
    
    task run_phase(uvm_phase phase);
        iseq=ahb_incr_seq::type_id::create("iseq");
        phase.raise_objection(this);
        iseq.start(envh.htop.agth[0].h_seqr);
        #100;
        phase.drop_objection(this);
    endtask

endclass



class ahb_wrap_test extends ahb_apb_test;

    `uvm_component_utils(ahb_wrap_test)
    
    ahb_wrap_seq wseq;
    
    function new(string name="ahb_wrap_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TEST","Printing UVM TB Topology",UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction
    
    task run_phase(uvm_phase phase);
        wseq=ahb_wrap_seq::type_id::create("wseq");
        phase.raise_objection(this);
        wseq.start(envh.htop.agth[0].h_seqr);
        #100;
        phase.drop_objection(this);
    endtask

endclass