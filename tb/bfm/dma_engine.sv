// ============================================================================
// File: tb/bfm/dma_engine.sv
// Description: DMA Engine, loads the image, executes write transfers, and 
//              verifies read-back data over AXI.
// ============================================================================
import aou_tb_pkg::*;

module dma_engine #(
    parameter int ADDR_WIDTH     = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH     = AXI_DATA_WIDTH,
    parameter int ID_WIDTH       = AXI_ID_WIDTH,
    parameter int STRB_WIDTH     = AXI_STRB_WIDTH,
    parameter int MAX_BURST_LEN  = AXI_MAX_BURST_LEN,
    parameter int PAGE_SIZE     = AXI_PAGE_SIZE_BYTES
)(
    input clk,
    input rst_n,
    axi_M_if.Master intf
);

    // ---------------------------------
    // INTERNAL TRACKING VARIABLES
    // ---------------------------------
    logic [DATA_WIDTH-1:0] image_buffer[$];
    int id = 0;

    // --------------------------------------------------------
    // task to Load the image into the internal buffer 
    // --------------------------------------------------------
    task automatic load_image(input string file_path);
        int fd; 
        logic [DATA_WIDTH-1:0] data_word;

        image_buffer.delete();

        fd = $fopen(file_path, "r");
        if (fd == 0) begin
            $fatal(1, "[DMA ERROR] Failed to open image file: %s", file_path);
        end

        while ($fscanf(fd, "%h", data_word) == 1) begin
            image_buffer.push_back(data_word);
        end
        $fclose(fd);

        $display("[DMA] Successfully loaded %0d words (%0d bytes) from %s", 
                 image_buffer.size(), image_buffer.size() * (DATA_WIDTH/8), file_path);
    endtask   

    // --------------------------------------------------
    // task to start image transfer and read verification
    // --------------------------------------------------
    task automatic transfer_image(input logic [ADDR_WIDTH-1:0] base_addr);
        logic [ADDR_WIDTH-1:0] curr_addr;
        logic [1:0]            bresp_status;
        logic [1:0]            rresp_status;
        int                    bytes_per_beat;

        bytes_per_beat = DATA_WIDTH / 8;
        curr_addr = base_addr;

        if (image_buffer.size() == 0) begin
            $error("[DMA ERROR] Transfer attempted with empty image buffer.");
            return;
        end

        $display("[DMA] Starting payload transfer to Base Addr: 0x%0h", curr_addr);

        while (image_buffer.size() > 0) begin
            int beats_remaining; 
            int bytes_to_page_boundary; 
            int max_beats_before_boundary; 
            int burst_beats; 
            logic [DATA_WIDTH-1:0] payload_chunk[$];
            logic [DATA_WIDTH-1:0] read_back_chunk[$];

            beats_remaining = image_buffer.size();

            // 4KB boundary calculation
            bytes_to_page_boundary    = PAGE_SIZE - (curr_addr % PAGE_SIZE);
            max_beats_before_boundary = bytes_to_page_boundary / bytes_per_beat;

            // Determine burst beat count
            burst_beats = beats_remaining;
            if (burst_beats > max_beats_before_boundary) burst_beats = max_beats_before_boundary;
            if (burst_beats > MAX_BURST_LEN) burst_beats = MAX_BURST_LEN;

            // Extract payload chunk for write transaction
            payload_chunk.delete();
            for (int i = 0; i < burst_beats; i++) begin
                payload_chunk.push_back(image_buffer.pop_front());
            end

            id++;
            $display("[DMA] Issuing Write Burst Txn #%0d | Addr: 0x%0h | Beats: %0d (%0d Bytes)", 
                     id, curr_addr, burst_beats, burst_beats * bytes_per_beat);

            // 1. Issue Write Burst
            intf.write_burst(
                .txn_id(id),
                .base_addr(curr_addr),
                .burst_len(burst_beats - 1),
                .payload(payload_chunk),
                .response(bresp_status)
            );

            if (bresp_status != 2'b00) begin
                $error("[DMA ERROR] Write Txn #%0d failed with BRESP = 2'b%0b at Addr 0x%0h", 
                       id, bresp_status, curr_addr);
                $finish;
            end

            // 2. Issue Read Burst for Verification
            $display("[DMA] Issuing Read Burst Txn #%0d | Addr: 0x%0h | Beats: %0d", 
                     id, curr_addr, burst_beats);

            intf.read_burst(
                .txn_id(id),
                .base_addr(curr_addr),
                .burst_len(burst_beats - 1),
                .payload(read_back_chunk),
                .response(rresp_status)
            );

            if (rresp_status != 2'b00) begin
                $error("[DMA ERROR] Read Txn #%0d failed with RRESP = 2'b%0b at Addr 0x%0h", 
                       id, rresp_status, curr_addr);
                $finish;
            end

            // 3. Data Comparison
            if (read_back_chunk.size() != payload_chunk.size()) begin
                $error("[DMA MISMATCH] Txn #%0d length error! Expected %0d beats, got %0d beats", 
                       id, payload_chunk.size(), read_back_chunk.size());
            end else begin
                for (int b = 0; b < payload_chunk.size(); b++) begin
                    if (read_back_chunk[b] !== payload_chunk[b]) begin
                        $error("[DMA MISMATCH] Txn #%0d Beat %0d | Expected: 0x%16h | Got: 0x%16h", 
                               id, b, payload_chunk[b], read_back_chunk[b]);
                    end else begin
                        $display("[DMA MATCH] Txn #%0d Beat %0d | Data: 0x%16h", 
                                 id, b, read_back_chunk[b]);
                    end
                end
            end

            // Increment target address
            curr_addr += (burst_beats * bytes_per_beat);
        end

        $display("[DMA] Transfer and verification completed successfully. End Addr: 0x%0h", curr_addr);
    endtask

    initial begin
        // intf.reset_master();
        // wait(rst_n);
        // repeat (2) @(posedge clk);

        // load_image("image.hex");
        // transfer_image(DEFAULT_IMAGE_BASE_ADDR);
    end

endmodule