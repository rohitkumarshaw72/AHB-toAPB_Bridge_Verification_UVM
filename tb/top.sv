
module top;

    import uvm_pkg::*;
    import ahb_apb_pkg::*;
    
    bit Hclk;
    
    always
        #5 Hclk = ~Hclk;
    
    ahb_apb_if in(Hclk);
    
    rtl_top DUV(.Hclk(Hclk),
                    .Hresetn(in.Hresetn),
                    .Htrans(in.Htrans),
                    .Hsize(in.Hsize),
                    .Hreadyin(in.Hreadyin),
                    .Hwdata(in.Hwdata),
                    .Haddr(in.Haddr),
                    .Hwrite(in.Hwrite),
                    .Hrdata(in.Hrdata),
                    .Hresp(in.Hresp),
                    .Hreadyout(in.Hreadyout),
                    
                    .Prdata(in.Prdata),
                    .Pselx(in.Pselx),
                    .Pwrite(in.Pwrite),
                    .Penable(in.Penable),
                    .Paddr(in.Paddr),
                    .Pwdata(in.Pwdata)
    );
    
    initial  begin
        `ifdef VCS
            $fsdbDumpvars(0, top);
        `endif
        
        uvm_config_db #(virtual ahb_apb_if)::set(null,"*","vif",in);
        
        run_test();
    end
    
    property assert_AHB;
        @(posedge Hclk)    (in.Hreadyout==0)  |=>  $stable(in.Haddr) && $stable(in.Htrans) && $stable(in.Hsize) && $stable(in.Hwrite);
    endproperty
    
    property assert_APB;
        @(posedge Hclk)    (in.Pselx==1)  |->  in.Pselx == 4'b0001 || 4'b0010 || 4'b0100 || 4'b1000;
    endproperty
    
    assert property(assert_AHB);
    assert property(assert_APB);

endmodule
