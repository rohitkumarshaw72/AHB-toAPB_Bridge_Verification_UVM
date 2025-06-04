
class ahb_top extends uvm_env;

    `uvm_component_utils(ahb_top);
    
    ahb_agent agth[];
    ahb_apb_env_config m_cfg;
    
    function new(string name="ahb_top",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
            `uvm_fatal(get_type_name(),"ENV: AHB ERROR")
        agth=new[m_cfg.no_of_ahb_agt];
        
        foreach(agth[i])  begin
            agth[i]=ahb_agent::type_id::create($sformatf("agth[%0d]",i),this);
            uvm_config_db #(ahb_config)::set(this,$sformatf("agth[%0d]*",i),"ahb_config",m_cfg.ahb_cfg[i]);
        end
    endfunction

endclass
