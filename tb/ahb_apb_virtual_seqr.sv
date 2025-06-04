
class ahb_apb_virtual_seqr extends uvm_sequencer;

    `uvm_component_utils(ahb_apb_virtual_seqr)
    
    ahb_seqr h_seqr[];
    apb_seqr p_seqr[];
    ahb_apb_env_config m_cfg;
    
    function new(string name="ahb_apb_virtual_seqr",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
            `uvm_fatal("VSEQR_CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
        h_seqr = new[m_cfg.no_of_ahb_agt];
        p_seqr = new[m_cfg.no_of_apb_agt];
    endfunction

endclass
