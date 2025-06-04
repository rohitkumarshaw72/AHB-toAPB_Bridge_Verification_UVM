
class ahb_agent extends uvm_agent;

    `uvm_component_utils(ahb_agent)
    
    ahb_config ahb_cfg;
    ahb_monitor monh;
    ahb_seqr h_seqr;
    ahb_driver drvh;
    
    function new(string name="ahb_agent",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",ahb_cfg))
            `uvm_fatal("AHB_CONFIG","Cannot get() ahb_cfg from uvm_config_db, have you set() it?")
        monh=ahb_monitor::type_id::create("monh",this);
        if(ahb_cfg.is_active==UVM_ACTIVE)  begin
            drvh=ahb_driver::type_id::create("drvh",this);
            h_seqr=ahb_seqr::type_id::create("h_seqr",this);
        end
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        if(ahb_cfg.is_active==UVM_ACTIVE)  begin
            drvh.seq_item_port.connect(h_seqr.seq_item_export);
        end
    endfunction

endclass
