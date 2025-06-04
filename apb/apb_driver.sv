
class apb_driver extends uvm_driver #(apb_xtn);

    `uvm_component_utils(apb_driver)
    
    virtual ahb_apb_if.PDRV_MP vif;
    apb_config apb_cfg;
    
    function new(string name="apb_driver",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(apb_config)::get(this,"","apb_config",apb_cfg))
            `uvm_fatal("APB_DRIVER","Cannot get() ahb_cfg from uvm_config_db, have you set() it?")
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        vif = apb_cfg.vif;
    endfunction
    
    task run_phase(uvm_phase phase);
        forever  begin
           // seq_item_port.get_next_item(req);
            send_to_dut(req);
            //seq_item_port.item_done();
        end
    endtask
    
    task send_to_dut(apb_xtn req1);
	req1=apb_xtn::type_id::create("apb_xtn");
        wait(vif.pdrv_cb.Pselx== 4'b0001 || 4'b0010 || 4'b0100 || 4'b1000)
        @(vif.pdrv_cb);

        if(vif.pdrv_cb.Pwrite==0)
          begin
	    wait(vif.pdrv_cb.Penable==1)
            vif.pdrv_cb.Prdata <= $urandom;
       // @(vif.pdrv_cb);
	end
	repeat(2)
        @(vif.pdrv_cb);
        
        `uvm_info("APB_DRIVER","Displaying apb_driver data",UVM_MEDIUM)
        req1.print();
        
        apb_cfg.pdrv_data_count++;
        $display("Number of data packets driven: %0d",apb_cfg.pdrv_data_count);
    endtask

endclass
