
class ahb_driver extends uvm_driver #(ahb_xtn);

    `uvm_component_utils(ahb_driver)
    
    virtual ahb_apb_if.HDRV_MP vif;
    ahb_config ahb_cfg;
    
    function new(string name="ahb_driver",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",ahb_cfg))
            `uvm_fatal("AHB_DRIVER","Cannot get() ahb_cfg from uvm_config_db, have you set() it?")
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        vif = ahb_cfg.vif;
    endfunction
    
    task run_phase(uvm_phase phase);
        
        @(vif.hdrv_cb);
        vif.hdrv_cb.Hresetn <= 1'b0;    //reset
        
        //repeat(3)
        @(vif.hdrv_cb);
        vif.hdrv_cb.Hresetn <= 1'b1;    //set
        
        forever  begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
        end
    endtask
    
    task send_to_dut(ahb_xtn req);
        
        wait(vif.hdrv_cb.Hreadyout==1)    //address_phase
        
        vif.hdrv_cb.Hwrite <= req.Hwrite;
        vif.hdrv_cb.Htrans <= req.Htrans;
        vif.hdrv_cb.Hsize <= req.Hsize;
        vif.hdrv_cb.Haddr <= req.Haddr;
        vif.hdrv_cb.Hreadyin <= 1'b1;
        
        @(vif.hdrv_cb);    //data_phase
        wait(vif.hdrv_cb.Hreadyout==1)
        
        if(req.Hwrite === 1'b1)
            vif.hdrv_cb.Hwdata <= req.Hwdata;
        else
            vif.hdrv_cb.Hwdata <= 32'b0;
        
        `uvm_info("AHB_DRIVER","Displaying ahb_driver data",UVM_MEDIUM)
        req.print();
        
        ahb_cfg.hdrv_data_count++;
        $display("Number of data packets driven: %0d",ahb_cfg.hdrv_data_count);
        
    endtask

endclass
