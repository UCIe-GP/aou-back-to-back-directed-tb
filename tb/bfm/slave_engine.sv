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
    logic[ADDR_WIDTH-1:0] my_address_read;
    logic[ID_WIDTH-1:0] captured_id_read;
    logic ar_received;
    int counter;
    logic [7:0] awlen_internal;


    always@(posedge clk or negedge rst_n) begin 
        //if reset works
        if(!rst_n) begin
            intf.resetSlave();
            myaddress <= 0;
            captured_id <= 0;
            aw_received <= 0;
            ar_received<=0;
            counter<=0;
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
                intf.bid <= aw_received ? captured_id : intf.awid;
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

        //read address
        if(!ar_received)begin
            intf.arready <= 1;
            if(intf.arvalid&&intf.arready)begin
                $display("[MEMORY SLAVE] READ ADDRESS HANDSHAKE START");
                captured_id_read<=intf.arid;
                counter<=intf.arlen+1;//total number of beats
                awlen_internal <= intf.arlen;
                ar_received<=1;
                intf.arready<=0;

                //for first beat only
                $display("[MEMORY SLAVE] POPULATING READ CHANNEL WITH FIRST BEAT DATA");
                intf.rid<=intf.arid;
                intf.rresp<=2'b00;
                intf.rlast<=(intf.arlen==0); //for single beat 
                for(int b=0;b<STRB_WIDTH;++b)begin
                    intf.rdata[b*8+:8]<=mymemory[intf.araddr+b];
                end
                intf.rvalid<=1;
                $display("[MEMORY SLAVE] READ CHANNEL HAS FIRST BEAT DATA..");
                my_address_read<=intf.araddr+STRB_WIDTH;//if there is another beat 
                $display("[MEMORY SLAVE] READ HANDSHAKE OCCURED"); 
            end
        end


        // SLAVE START SENDING DATA TO MASTER
        if(intf.rready&&intf.rvalid)begin
            $strobe("[MEMORY SLAVE] BEAT %0d WAS SENT SUCCESSFULLY..", awlen_internal - counter + 1);
            counter--;
            if(counter==0) begin
                $strobe("[MEMORY SLAVE] READ BURST COMPLETED.");
                //burst completion
                intf.rvalid<=0;
                intf.rlast<=0;
                ar_received<=0;
                counter<=0;
            end else begin
            $strobe("[MEMORY SLAVE] SENDING BEAT %0d", awlen_internal - counter + 1);
            //multiple beats are being sent 
            // logic[ADDR_WIDTH-1:0] current_address;
            // logic[DATA_WIDTH-1:0] read_temp;
            for(int b=0;b<STRB_WIDTH;++b)begin
                intf.rdata[b*8+:8]<=mymemory[my_address_read+b];
            end
            my_address_read<=my_address_read+STRB_WIDTH;//for next beat (new based address)
            intf.rlast<=(counter==1)?1:0;
            intf.rresp<=0;
            intf.rid<=ar_received?captured_id_read:intf.arid;
            $strobe("[MEMORY SLAVE] POPULATED READ CHANNEL WITH BEAT %0d | rlast %0b | counter %0d", awlen_internal - counter + 1, intf.rlast, counter);
            end
        end
        /**
            [11,22,33,44,55,66] arlen 5, counter = 6 
        */
    end
endmodule 
