
class apb_agent extends uvm_agent;

    `uvm_component_utils(apb_agent)
    
    apb_config apb_cfg;
    apb_monitor monh;
    apb_seqr p_seqr;
    apb_driver drvh;
    
    function new(string name="apb_agent",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(apb_config)::get(this,"","apb_config",apb_cfg))
            `uvm_fatal("APB_CONFIG","Cannot get() apb_cfg from uvm_config_db, have you set() it?")
        
        monh=apb_monitor::type_id::create("monh",this);
        
        if(apb_cfg.is_active==UVM_ACTIVE)  begin
            drvh=apb_driver::type_id::create("drvh",this);
            p_seqr=apb_seqr::type_id::create("p_seqr",this);
        end
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        if(apb_cfg.is_active==UVM_ACTIVE)  begin
            drvh.seq_item_port.connect(p_seqr.seq_item_export);
        end
    endfunction

endclass
