import aou_tb_pkg::*;

module slave #
( parameter int ADDR_WIDTH     = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH     = AXI_DATA_WIDTH,
    parameter int ID_WIDTH       = AXI_ID_WIDTH,
    parameter int STRB_WIDTH     = AXI_STRB_WIDTH,
    parameter int MAX_BURST_LEN  = AXI_MAX_BURST_LEN,
    parameter int PAGE_SIZE      = AXI_PAGE_SIZE_BYTES
)(
    input clk,
    input rst_n,
    axi_if.Slave intf
);
//create memory 
logic [7:0] mymemory[logic[ADDR_WIDTH-1:0]];
logic [ID_WIDTH-1:0] captured_id;
logic[Addr-width-1:0] myaddress;


always@(posedge clk or negedge rst_n)begin 
  //if reset works
  if(!rst_n)begin
    intf.resetSlave();
end
    else begin 
//address ready handshake
awready<=1;
wready<=1;
if(intf.awvalid&&intf.awready)begin
    captured_id<=intf.awid;
    myaddress<=intf.awaddr;
end
//write 
if(intf.wvalid&&intf.wready)begin
    for(int b=0;b<intf.wstr;++b)begin
        mymemory[myaddress+b]<=intf.wdata[b*8+:8];
        if(wlast==1)begin
            intf.bvalid<=1;
        end
    end
end
//response
if(intf.bready&&intf.bvalid)begin
    bresp<=0;
    bid<=captured_id;
end
    end
end
endmodule
