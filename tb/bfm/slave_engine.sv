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
    logic[ADDR_WIDTH-1:0] myaddress;
    logic aw_received;

    always@(posedge clk or negedge rst_n) begin 
        //if reset works
        if(!rst_n) begin
            intf.resetSlave();
            myaddress <= 0;
            captured_id <= 0;
            aw_received <= 0;
        end else begin 
        //address ready handshake
        if(!aw_received) begin
            intf.awready<=1;
            if(intf.awvalid&&intf.awready) begin
                captured_id<=intf.awid;
                myaddress<=intf.awaddr;
                intf.awready <= 0;
                aw_received <= 1;
                $display("[MEMORY SLAVE] START ADDRESS OF THE BURST %0d IS RECEIVED SUCCESSFULLY. ADDRESS:%0h", intf.awid, intf.awaddr);
            end
        end
        //write 
        intf.wready<=1;
        if(intf.wvalid&&intf.wready) begin
            logic [ADDR_WIDTH-1:0] current_addr;
            current_addr = aw_received? myaddress : intf.awaddr;
            $display("[MEMORY SLAVE] WRITING DATA BEAT STARTING FROM MEMORY ADDRESS:%0h", current_addr);
            for(int b=0;b<STRB_WIDTH;++b) begin
                if(intf.wstrb[b]) begin
                    mymemory[current_addr+b]=intf.wdata[b*8+:8];
                end     
            end
            myaddress <= current_addr + STRB_WIDTH;
            $display("[MEMORY SLAVE] WRITING DATA BEAT FINISHED AT ADDRESS:%0h", current_addr + STRB_WIDTH);
            if(intf.wlast==1) begin
                intf.bresp <= 2'b00;
                intf.bid<= aw_received ? captured_id : intf.awid;
                intf.bvalid<=1;
                aw_received <= 0;
                $display("[MEMORY SLAVE] LAST BEAT WAS RECEIVED SUCCESSFULLY..");
            end
        end
        //response
        if(intf.bready&&intf.bvalid)begin
                $display("[MEMORY SLAVE] RESPONSE WRITTEN SUCCESSFULLY.");
                intf.bvalid<=0;
            end
        end
    end
endmodule 
