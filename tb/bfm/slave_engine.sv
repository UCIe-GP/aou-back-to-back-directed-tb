import aou_tb_pkg::*;

module slave #(   
    parameter int ADDR_WIDTH     = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH     = AXI_DATA_WIDTH,
    parameter int ID_WIDTH       = AXI_ID_WIDTH,
    parameter int STRB_WIDTH     = AXI_STRB_WIDTH,
    parameter int MAX_BURST_LEN  = AXI_MAX_BURST_LEN,
    parameter int PAGE_SIZE      = AXI_PAGE_SIZE_BYTES
)(
    input  logic clk,
    input  logic rst_n,
    axi_S_if.Slave intf
);

    logic [7:0] mymemory[logic [ADDR_WIDTH-1:0]];
    logic [ID_WIDTH-1:0]   captured_id;
    logic [ADDR_WIDTH-1:0] myaddress;
    logic                  aw_received;

    logic [ADDR_WIDTH-1:0] my_address_read;
    logic [ID_WIDTH-1:0]   captured_id_read;
    logic                  ar_received;
    logic [2:0]            captured_arsize;
    int                    counter;
    logic [2:0]            captured_awsize;



    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            intf.resetSlave();
            myaddress        <= '0;
            captured_id      <= '0;
            aw_received      <= 1'b0;
            my_address_read  <= '0;
            captured_id_read <= '0;
            captured_arsize  <= '0;
            ar_received      <= 1'b0;
            counter          <= 0;
            captured_awsize<=0;
        end else begin

            // ------------------------------------------------------------------
            // Write Address Channel (AW)
            // ------------------------------------------------------------------
            if (!aw_received) begin
                intf.awready <= 1'b1;
                if (intf.awvalid && intf.awready) begin
                    captured_id  <= intf.awid;
                    myaddress    <= intf.awaddr;
                    captured_awsize <= intf.awsize;
                    intf.awready <= 1'b0;
                    aw_received  <= 1'b1;
                end
            end

            // ------------------------------------------------------------------
            // Write Data Channel (W)
            // ------------------------------------------------------------------
            intf.wready <= 1'b1;
            if (intf.wvalid && intf.wready) begin
                logic [ADDR_WIDTH-1:0] current_addr;
                logic [ADDR_WIDTH-1:0] bus_aligned_addr;
                int write_bytes_per_beat;

                write_bytes_per_beat = (1 << (aw_received ? captured_awsize : intf.awsize));
                current_addr         = aw_received ? myaddress : intf.awaddr;
                
                // Align to the 64-byte bus boundary (e.g. 0x00, 0x40, 0x80)
                bus_aligned_addr     = current_addr & ~(STRB_WIDTH - 1);

                $display("[MEM WRITE] Addr: 0x%08h | BusAligned: 0x%08h | Strobe: 0x%0h", 
                         current_addr, bus_aligned_addr, intf.wstrb);
                for (int b = 0; b < STRB_WIDTH; ++b) begin
                    if (intf.wstrb[b]) begin
                        mymemory[bus_aligned_addr + b] = intf.wdata[b*8 +: 8];
                    end     
                end

                // Step address pointer by actual transfer size (32 bytes), NOT STRB_WIDTH (64 bytes)
                myaddress <= current_addr + write_bytes_per_beat;

                if (intf.wlast) begin
                    intf.bresp  <= 2'b00; // OKAY
                    intf.bid    <= aw_received ? captured_id : intf.awid;
                    intf.bvalid <= 1'b1;
                    aw_received <= 1'b0;
                    $display("[MEMORY SLAVE] LAST BEAT WAS RECEIVED SUCCESSFULLY..");
                end
            end

            // ------------------------------------------------------------------
            // Write Response Channel (B)
            // ------------------------------------------------------------------
            if (intf.bready && intf.bvalid) begin
                intf.bvalid <= 1'b0;
            end

            // ------------------------------------------------------------------
            // Read Address Channel (AR) - Drives Beat 0
            // ------------------------------------------------------------------
            if (!ar_received) begin
                intf.arready <= 1'b1;
                if (intf.arvalid && intf.arready) begin
                    int bytes_per_beat;
                    int byte_offset;
                    logic [DATA_WIDTH-1:0] rdata_buf;

                    bytes_per_beat  = (1 << intf.arsize);
                    byte_offset     = intf.araddr % STRB_WIDTH;
                    rdata_buf       = '0;

                    captured_id_read <= intf.arid;
                    counter          <= intf.arlen + 1;
                    captured_arsize  <= intf.arsize;
                    ar_received      <= 1'b1;
                    intf.arready     <= 1'b0;

                    // Assemble Beat 0 using blocking assignment
                    for (int b = 0; b < bytes_per_beat; ++b) begin
                        rdata_buf[(byte_offset + b)*8 +: 8] = mymemory.exists(intf.araddr + b) ? 
                                                              mymemory[intf.araddr + b] : 8'h00;
                    end

                    intf.rid    <= intf.arid;
                    intf.rresp  <= 2'b00;
                    intf.rlast  <= (intf.arlen == 0);
                    intf.rdata  <= rdata_buf; 
                    intf.rvalid <= 1'b1;

                    my_address_read <= intf.araddr + bytes_per_beat;
                end
            end

            // ------------------------------------------------------------------
            // Read Data Channel (R) - Advances Beats 1 to N
            // ------------------------------------------------------------------
            if (intf.rvalid && intf.rready) begin
                if (counter == 1) begin
                    intf.rvalid  <= 1'b0;
                    intf.rlast   <= 1'b0;
                    ar_received  <= 1'b0;
                    counter      <= 0;
                end else begin
                    int bytes_per_beat;
                    int byte_offset;
                    logic [DATA_WIDTH-1:0] rdata_buf2;

                    bytes_per_beat = (1 << captured_arsize);
                    byte_offset    = my_address_read % STRB_WIDTH;
                    rdata_buf2     = '0;

                    // Assemble subsequent beats immediately
                    for (int b = 0; b < bytes_per_beat; ++b) begin
                        rdata_buf2[(byte_offset + b)*8 +: 8] = mymemory.exists(my_address_read + b) ? 
                                                               mymemory[my_address_read + b] : 8'h00;
                    end

                    intf.rdata      <= rdata_buf2; 
                    intf.rid        <= captured_id_read;
                    intf.rresp      <= 2'b00;
                    intf.rlast      <= (counter == 2);
                    my_address_read <= my_address_read + bytes_per_beat;
                    counter         <= counter - 1;
                    $display("[MEM READ]  Addr: 0x%08h | Offset: %0d | MemExists: %0b", 
         my_address_read, byte_offset, mymemory.exists(my_address_read));
                end
            end

        end
    end

endmodule