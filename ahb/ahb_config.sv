
class ahb_config extends uvm_object;

    `uvm_object_utils(ahb_config)
    
    virtual ahb_apb_if vif;
    
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    static int hdrv_data_count = 0;
    static int hmon_data_count = 0;
    
    function new(string name="ahb_config");
        super.new(name);
    endfunction

endclass
