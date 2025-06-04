
class ahb_seq extends uvm_sequence #(ahb_xtn);

    `uvm_object_utils(ahb_seq)
       
    function new(string name="ahb_seq");
        super.new(name);
    endfunction

endclass


class ahb_incr_seq extends ahb_seq;

    `uvm_object_utils(ahb_incr_seq)
    
    bit [31:0] haddr;
    bit hwrite;
    bit [2:0] hsize;
    bit [2:0] hburst;
    bit [9:0] hlength;
    
    function new(string name="ahb_incr_seq");
        super.new(name);
    endfunction
    
    task body();
        req=ahb_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with  {
            Htrans == 2'b10;                                        //non_seq
            Hburst inside {1,3,5,7};  });    //incr
        finish_item(req);
        
        haddr = req.Haddr;
        hwrite = req.Hwrite;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hlength = req.hlength;
        
        for(int i=1; i<hlength+1; i++)  begin
            start_item(req);
            assert(req.randomize() with  {
                Htrans== 2'b11;                            //seq
                Hsize==hsize;
                Hwrite==1;
                Hburst==hburst;
                Haddr==(haddr+(2**hsize));  });
            finish_item(req);
            haddr=req.Haddr;    //updating the local haddr
        end
    endtask

endclass



class ahb_wrap_seq extends ahb_seq;

    `uvm_object_utils(ahb_wrap_seq)
  
    bit [31:0] start_addr, bound_addr;
    bit [31:0] haddr;
    bit hwrite;
    bit [2:0] hsize;
    bit [2:0] hburst;
    bit [9:0] hlength;
  
    function new(string name="ahb_wrap_seq");
        super.new(name);
    endfunction
  
    task body();
  
        req=ahb_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with  {
              Htrans == 2'b10;                                //non_seq
              Hburst inside {3'b010, 3'b100, 3'b110};  });    //wrap
        finish_item(req);
        
        haddr = req.Haddr;
        hwrite = req.Hwrite;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hlength = req.hlength;
        
        start_addr=int'((haddr/((2**hsize)*hlength)))*((2**hsize)*hlength);
        bound_addr=start_addr+((2**hsize)*(hlength+1));
        haddr=req.Haddr+(2**hsize);
        
        for(int i=1; i<hlength; i++)  begin
            if(haddr==bound_addr)
                haddr=start_addr;
            start_item(req);
            assert(req.randomize() with  {
                Htrans== 2'b11;                            //seq
                Hsize==hsize;
                Hwrite==hwrite;
                Hburst==hburst;
                Haddr==haddr;  });
            finish_item(req);
            haddr=req.Haddr+(2**hsize);    //updating the local haddr
        end

    endtask

endclass
