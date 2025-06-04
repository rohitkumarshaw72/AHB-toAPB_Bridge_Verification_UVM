
class ahb_apb_env_config extends uvm_object;

    `uvm_object_utils(ahb_apb_env_config)
    
    bit has_hagent = 1;
    bit has_pagent = 1;
    int no_of_ahb_agt = 1;
    int no_of_apb_agt = 1;
    bit has_scoreboard = 1;
    bit has_virtual_sequencer = 1;
    
    ahb_config ahb_cfg[];
    apb_config apb_cfg[];
    
    function new(string name="ahb_apb_env_config");
        super.new(name);
    endfunction
    

endclass
