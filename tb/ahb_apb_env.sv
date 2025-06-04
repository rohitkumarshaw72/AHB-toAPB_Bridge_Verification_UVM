
class ahb_apb_env extends uvm_env;
    
    `uvm_component_utils(ahb_apb_env)
    
    ahb_top htop;
    apb_top ptop;
    
    ahb_apb_virtual_seqr v_seqr;
    ahb_apb_scoreboard sb;
    
    ahb_apb_env_config m_cfg;
    
    function new(string name="ahb_apb_env",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
            `uvm_fatal("ENV_CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
        
        if(m_cfg.has_hagent)  begin
            htop=ahb_top::type_id::create("htop",this);
        end
        
        if(m_cfg.has_pagent)  begin
            ptop=apb_top::type_id::create("ptop",this);
        end
        
        if(m_cfg.has_virtual_sequencer)  begin
            v_seqr=ahb_apb_virtual_seqr::type_id::create("v_seqr",this);
        end
        
        if(m_cfg.has_scoreboard)  begin
            sb=ahb_apb_scoreboard::type_id::create("sb",this);
        end
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        for(int i=0;i<m_cfg.no_of_ahb_agt;i++)  begin
            v_seqr.h_seqr[i] = htop.agth[i].h_seqr;
            htop.agth[i].monh.hmon_ap.connect(sb.fifo_ahb[i].analysis_export);
        end
        for(int i=0;i<m_cfg.no_of_apb_agt;i++)  begin
            v_seqr.p_seqr[i] = ptop.agth[i].p_seqr;
            ptop.agth[i].monh.pmon_ap.connect(sb.fifo_apb[i].analysis_export);
        end
        super.connect_phase(phase);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        m_cfg=ahb_apb_env_config::type_id::create("m_cfg");
    endfunction
    
endclass
