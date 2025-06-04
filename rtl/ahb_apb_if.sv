
interface ahb_apb_if(input bit Hclk);

    logic Hresetn, Hwrite;
    logic [2:0] Hsize;
    logic [1:0] Htrans;
    logic Hreadyin;
    logic Hreadyout;
    
    logic [31:0] Haddr;
    logic [2:0] Hburst;
    logic [1:0] Hresp;
    logic [31:0] Hwdata;
    logic [31:0] Hrdata;
    
    logic Penable, Pwrite, Presetn;
    logic [31:0] Paddr;
    logic [3:0] Pselx;
    logic [31:0] Pwdata;
    logic [31:0] Prdata;
    
    clocking hdrv_cb@(posedge Hclk);
        output Hresetn, Hwrite, Hsize, Htrans, Hreadyin, Haddr, Hburst, Hwdata;
        input Hreadyout, Hresp;
    endclocking
    
    clocking hmon_cb@(posedge Hclk);
        input Hresetn, Hwrite, Hsize, Htrans, Hreadyin, Hreadyout, Haddr, Hburst, Hresp, Hwdata, Hrdata;
    endclocking
    
    clocking pdrv_cb@(posedge Hclk);
        output Prdata;
        input Penable, Pwrite, Pselx, Paddr, Presetn;
    endclocking
    
    clocking pmon_cb@(posedge Hclk);
        input Presetn, Penable, Pwrite, Paddr, Pselx, Pwdata, Prdata;
    endclocking
    
    modport HDRV_MP (clocking hdrv_cb);
    modport HMON_MP (clocking hmon_cb);
    modport PDRV_MP (clocking pdrv_cb);
    modport PMON_MP (clocking pmon_cb);

endinterface
