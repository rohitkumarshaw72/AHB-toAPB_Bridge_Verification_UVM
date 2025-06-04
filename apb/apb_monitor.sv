
class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)
    
    virtual ahb_apb_if vif;
    apb_config apb_cfg;
    apb_xtn txn;
    uvm_analysis_port #(apb_xtn) pmon_ap;
    
    function new(string name="apb_monitor",uvm_component parent);
        super.new(name,parent);
        pmon_ap = new("pmon_ap",this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(apb_config)::get(this,"","apb_config",apb_cfg))
            `uvm_fatal("APB_MONITOR","Cannot get() apb_cfg from uvm_config_db, have you set() it?")
    endfunction
    
    function void connect_phase(uvm_phase phase);
        vif = apb_cfg.vif;
    endfunction
    
    task run_phase(uvm_phase phase);
        forever  begin
            collect_data();
        end
    endtask
    
    task collect_data();
        txn=apb_xtn::type_id::create("txn");
        
        wait(vif.pmon_cb.Penable==1'b1)
        txn.Paddr = vif.pmon_cb.Paddr;
        txn.Pselx = vif.pmon_cb.Pselx;
        txn.Pwrite = vif.pmon_cb.Pwrite;
        txn.Penable = vif.pmon_cb.Penable;
        if(txn.Pwrite===1'b1)
            txn.Pwdata=vif.pmon_cb.Pwdata;
        else
            txn.Prdata=vif.pmon_cb.Prdata;
	      repeat(2)
        @(vif.pmon_cb);    
        
        `uvm_info("APB_MONITOR","Displaying apb_monitor data",UVM_MEDIUM)
        txn.print();
        pmon_ap.write(txn);
        
        apb_cfg.pmon_data_count++;
        $display("Number of data monitored: %0d",apb_cfg.pmon_data_count);
        
    endtask

endclass
