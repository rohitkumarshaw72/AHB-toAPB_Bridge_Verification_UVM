
class ahb_monitor extends uvm_monitor;

    `uvm_component_utils(ahb_monitor)
    
    virtual ahb_apb_if.HMON_MP vif;
    ahb_config ahb_cfg;
    ahb_xtn txn;
    uvm_analysis_port #(ahb_xtn) hmon_ap;
    
    function new(string name="ahb_monitor",uvm_component parent);
        super.new(name,parent);
        hmon_ap = new("hmon_ap",this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",ahb_cfg))
            `uvm_fatal("AHB_MONITOR","Cannot get() ahb_cfg from uvm_config_db, have you set() it?")
    endfunction
    
    function void connect_phase(uvm_phase phase);
        vif = ahb_cfg.vif;
    endfunction
    
    task run_phase(uvm_phase phase);
        forever  begin
            collect_data();
        end
    endtask
    
    task collect_data();
        txn=ahb_xtn::type_id::create("txn");
        
        wait(vif.hmon_cb.Htrans inside {2'b10, 2'b11} && vif.hmon_cb.Hreadyout==1)    //address_phase

        txn.Htrans = vif.hmon_cb.Htrans;
        txn.Hwrite = vif.hmon_cb.Hwrite;
        txn.Hsize = vif.hmon_cb.Hsize;
        txn.Haddr = vif.hmon_cb.Haddr;
        txn.Hreadyin = vif.hmon_cb.Hreadyin;
        
        @(vif.hmon_cb);
        wait(vif.hmon_cb.Hreadyout==1)    //data_phase
        if(txn.Hwrite === 1'b1)
            txn.Hwdata = vif.hmon_cb.Hwdata;
        else
            txn.Hrdata = vif.hmon_cb.Hrdata;
        
        `uvm_info("AHB_MONITOR","Displaying ahb_monitor data",UVM_MEDIUM)
        txn.print();
        hmon_ap.write(txn);
        
        ahb_cfg.hmon_data_count++;
        $display("Number of data monitored: %0d",ahb_cfg.hmon_data_count);
        
    endtask

endclass
