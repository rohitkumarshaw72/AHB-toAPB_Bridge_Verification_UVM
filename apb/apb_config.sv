
class apb_config extends uvm_object;

    `uvm_object_utils(apb_config)
    
    virtual ahb_apb_if vif;
    
    static int pdrv_data_count=0;
    static int pmon_data_count=0;
    
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    function new(string name="apb_config");
        super.new(name);
    endfunction

endclass
