
class ahb_apb_virtual_seq extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(ahb_apb_virtual_seq)
    
    ahb_incr_seq iseq;
    ahb_wrap_seq wseq;
    
    ahb_seqr h_seqr[];
    apb_seqr p_seqr[];
    ahb_apb_virtual_seqr v_seqr;
    ahb_apb_env_config m_cfg;
    
    function new(string name="ahb_apb_virtual_seq");
        super.new(name);
    endfunction
    
    task body();
        if(!uvm_config_db #(ahb_apb_env_config)::get(null,get_full_name(),"m_cfg",m_cfg))
            `uvm_fatal("VSEQ_BODY","Cannot get() m_cfg from uvm_config_db")
        h_seqr=new[m_cfg.no_of_ahb_agt];
        p_seqr=new[m_cfg.no_of_apb_agt];
        
        assert($cast(v_seqr,m_sequencer))    else  begin
            `uvm_error("VSEQ_BODY","Error in $cast of virtual sequencer")
        end
        
        foreach(h_seqr[i])
            h_seqr[i] = v_seqr.h_seqr[i];
        foreach(p_seqr[i])
            p_seqr[i] = v_seqr.p_seqr[i];
    endtask

endclass


class ahb_incr_vseq extends ahb_apb_virtual_seq;

    `uvm_object_utils(ahb_incr_vseq)
    
    ahb_incr_seq iseq;
    
    function new(string name="ahb_incr_vseq");
        super.new(name);
    endfunction
    
    task body();
        super.body();
        iseq=ahb_incr_seq::type_id::create("iseq");
        foreach(h_seqr[i])
            iseq.start(h_seqr[i]);
        
    endtask

endclass


class ahb_wrap_vseq extends ahb_apb_virtual_seq;

    `uvm_object_utils(ahb_wrap_vseq)
    
    ahb_wrap_seq wseq;
    
    function new(string name="ahb_wrap_vseq");
        super.new(name);
    endfunction
    
    task body();
        super.body();
        wseq=ahb_wrap_seq::type_id::create("wseq");
        foreach(h_seqr[i])
            wseq.start(h_seqr[i]);
        
    endtask

endclass
