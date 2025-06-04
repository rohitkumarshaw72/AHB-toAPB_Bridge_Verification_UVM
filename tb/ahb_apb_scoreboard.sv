
class ahb_apb_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(ahb_apb_scoreboard)
    
    uvm_tlm_analysis_fifo #(ahb_xtn) fifo_ahb[];
    uvm_tlm_analysis_fifo #(apb_xtn) fifo_apb[];
    
    ahb_xtn htxn;
    apb_xtn ptxn;
    ahb_apb_env_config m_cfg;
    
    static int data_from_ahb=0;
    static int data_from_apb=0;
    static int matched_data=0;
    static int mismatched_data=0;
    
    extern function new(string name="ahb_apb_scoreboard",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task compare(int Haddr, Paddr, Hdata, Pdata);
    extern task check_data(ahb_xtn htxn, apb_xtn ptxn);
    extern function void report_phase(uvm_phase phase);
    
    covergroup ahb_cg;
    
        option.per_instance=1;
        HADDR  :  coverpoint htxn.Haddr  {
                                          bins slave0  =  {[32'h8000_0000:32'h8000_03ff]};
                                          bins slave1  =  {[32'h8400_0000:32'h8400_03ff]};
                                          bins slave2  =  {[32'h8800_0000:32'h8800_03ff]};
                                          bins slave3  =  {[32'h8c00_0000:32'h8c00_03ff]};
        }
        HSIZE  :  coverpoint htxn.Hsize  {
                                          bins size_1byte  =  {3'b000};
                                          bins size_2byte  =  {3'b001};
                                          bins size_4byte  =  {3'b010};
        }
        HWRITE  :  coverpoint htxn.Hwrite  {
                                            bins read = {0};
                                            bins write  = {1};
        }
        HTRANS  :  coverpoint htxn.Htrans  {
                                            bins non_seq = {2'b10};
                                            bins seq = {2'b11};
        }
        HCRS  :  cross HADDR, HSIZE, HWRITE, HTRANS;
    
    endgroup
    
    
    covergroup apb_cg;
        
        option.per_instance=1;
        PADDR  :  coverpoint ptxn.Paddr  {
                                          bins slave0  =  {[32'h8000_0000:32'h8000_03ff]};
                                          bins slave1  =  {[32'h8400_0000:32'h8400_03ff]};
                                          bins slave2  =  {[32'h8800_0000:32'h8800_03ff]};
                                          bins slave3  =  {[32'h8c00_0000:32'h8c00_03ff]};
        }
        PSELX  :  coverpoint ptxn.Pselx  {
                                          bins b1  =  {4'b0001};
                                          bins b2  =  {4'b0010};
                                          bins b4  =  {4'b0100};
                                          bins b8  =  {4'b1000};
        }
        PWRITE  :  coverpoint ptxn.Pwrite  {
                                            bins read = {0};
                                            bins write  = {1};
        }
        PCRS  :  cross PADDR, PSELX, PWRITE;
        
    endgroup
    
endclass


function ahb_apb_scoreboard::new(string name="ahb_apb_scoreboard",uvm_component parent);
    super.new(name,parent);
    ahb_cg=new();
    apb_cg=new();
endfunction

function void ahb_apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
        `uvm_fatal("SB-ENV_CFG","No update")
    fifo_ahb=new[m_cfg.no_of_ahb_agt];
    fifo_apb=new[m_cfg.no_of_apb_agt];
    
    foreach(fifo_ahb[i])
        fifo_ahb[i]=new($sformatf("fifo_ahb[%0d]",i),this);
    foreach(fifo_apb[i])
        fifo_apb[i]=new($sformatf("fifo_apb[%0d]",i),this);
endfunction


task ahb_apb_scoreboard::run_phase(uvm_phase phase);
    forever  begin
        fork
            begin
                fifo_ahb[0].get(htxn);
                `uvm_info("SB_AHB","Printing AHB data",UVM_LOW)
                htxn.print();
                data_from_ahb++;
                ahb_cg.sample();
            end
            
            begin
                fifo_apb[0].get(ptxn);
                `uvm_info("SB_APB","Printing APB data",UVM_LOW)
                ptxn.print();
                data_from_apb++;
                apb_cg.sample();
            end
        join
        check_data(htxn,ptxn);
    end
endtask


task ahb_apb_scoreboard::compare(int Haddr, Paddr, Hdata, Pdata);
    if(Haddr==Paddr)  begin
        $display("Address matched successfully");
        matched_data++;
    end
    else  begin
        $display("Address comparison failed");
        mismatched_data++;
    end
    if(Hdata==Pdata)  begin
        $display("Data matched successfully");
        matched_data++;
    end
    else  begin
        $display("Data comparison failed");
        mismatched_data++;
    end
endtask


task ahb_apb_scoreboard::check_data(ahb_xtn htxn, apb_xtn ptxn);
    if(htxn.Hwrite==1)  begin
        if(htxn.Hsize==2'b00)  begin
            if(htxn.Haddr[1:0]==2'b00)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[7:0],ptxn.Pwdata);
            if(htxn.Haddr[1:0]==2'b01)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[15:8],ptxn.Pwdata);
            if(htxn.Haddr[1:0]==2'b10)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[23:16],ptxn.Pwdata);
            if(htxn.Haddr[1:0]==2'b11)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[31:24],ptxn.Pwdata);
        end
        if(htxn.Hsize==2'b01)  begin
            if(htxn.Haddr[1:0]==2'b00)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[15:0],ptxn.Pwdata);
            if(htxn.Haddr[1:0]==2'b10)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata[31:16],ptxn.Pwdata);
        end
        if(htxn.Hsize==2'b10)
            compare(htxn.Haddr,ptxn.Paddr,htxn.Hwdata,ptxn.Pwdata);
    end
    
    if(htxn.Hwrite==0)  begin
        if(htxn.Hsize==2'b00)  begin
            if(htxn.Haddr[1:0]==2'b00)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[7:0]);
            if(htxn.Haddr[1:0]==2'b01)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[15:8]);
            if(htxn.Haddr[1:0]==2'b10)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[23:16]);
            if(htxn.Haddr[1:0]==2'b11)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[31:24]);
        end
        if(htxn.Hsize==2'b01)  begin
            if(htxn.Haddr[1:0]==2'b00)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[15:0]);
            if(htxn.Haddr[1:0]==2'b10)
                compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata[31:16]);
        end
        if(htxn.Hsize==2'b10)
            compare(htxn.Haddr,ptxn.Paddr,htxn.Hrdata,ptxn.Prdata);
    end
endtask


function void ahb_apb_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("\nData from AHB: %0d \nData from APB: %0d  \nTotal data matched: %0d  \nTotal data mismatched: %0d",data_from_ahb,data_from_apb,matched_data,mismatched_data);
endfunction