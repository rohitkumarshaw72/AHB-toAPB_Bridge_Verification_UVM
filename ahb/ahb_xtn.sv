
class ahb_xtn extends uvm_sequence_item;

    `uvm_object_utils(ahb_xtn)
    
    bit Hresetn;
    rand bit Hwrite;
    rand bit [2:0] Hsize;
    rand bit [1:0] Htrans;
    rand bit [31:0] Haddr;
    rand bit [2:0] Hburst;
    rand bit [31:0] Hwdata;
    bit [31:0] Hrdata;
    bit [1:0] Hresp;
    bit Hreadyin, Hreadyout;
    rand bit [9:0] hlength; //as 2^10 = 1024 locations, so it is 10 bit data
    //based on start and bound addresses, hlength will be randomized
    
    constraint valid_Haddr  {  Haddr inside  {  [32'h8000_0000  :  32'h8000_03ff],
                                                [32'h8400_0000  :  32'h8400_03ff],
                                                [32'h8800_0000  :  32'h8800_03ff],
                                                [32'h8c00_0000  :  32'h8c00_03ff]};  }
    constraint valid_size  {Hsize inside {[0:2]}; }
    constraint aligned_Haddr  {  Hsize == 1 -> Haddr%2==0;
                                  Hsize == 2 -> Haddr%4==0;  }
    constraint bound_Haddr  {  (Haddr%1024) + ((2**Hsize) * hlength) <= 1023;  }
    constraint length_Hburst {  Hburst==0  ->  hlength==1;
                                Hburst==2  ->  hlength==4;
                                Hburst==3  ->  hlength==4;
                                Hburst==4  ->  hlength==8;
                                Hburst==5  ->  hlength==8;
                                Hburst==6  ->  hlength==16;
                                Hburst==7  ->  hlength==16;  }
    
    
    function new(string name="ahb_xtn");
        super.new(name);
    endfunction
    
    function void do_print(uvm_printer printer);
        super.do_print(printer);
        
        //string name        bitstream value    size    radix_for_printing
        printer.print_field("Hresetn",  this.Hresetn,  1,  UVM_DEC);
        printer.print_field("Hwrite",  this.Hwrite,  1,  UVM_DEC);
        printer.print_field("Hsize",  this.Hsize,  3,  UVM_BIN);
        printer.print_field("Htrans",  this.Htrans,  2,  UVM_BIN);
        printer.print_field("Haddr",  this.Haddr,  32,  UVM_HEX);
        printer.print_field("Hburst",  this.Hburst,  3,  UVM_BIN);
        printer.print_field("Hwdata",  this.Hwdata,  32,  UVM_HEX);
        printer.print_field("Hrdata",  this.Hrdata,  32,  UVM_HEX);
       // printer.print_field("Hresp",  this.Hresp,  2,  UVM_BIN);
        printer.print_field("Hreadyin",  this.Hreadyin,  1,  UVM_DEC);
        printer.print_field("Hreadyout",  this.Hreadyout,  1,  UVM_DEC);
        printer.print_field("hlength",  this.hlength,  10,  UVM_HEX);
        
    endfunction

endclass
