// ============================================================================
// File: tb/bfm/dma_engine.sv
// Description: DMA Engine, loads the image, and starts sending it 
// through the AXI.
// ============================================================================
import aou_tb_pkg::*;
module dma_engine #(
    parameter int ADDR_WIDTH     = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH     = AXI_DATA_WIDTH,
    parameter int ID_WIDTH       = AXI_ID_WIDTH,
    parameter int STRB_WIDTH     = AXI_STRB_WIDTH,
    parameter int MAX_BURST_LEN  = AXI_MAX_BURST_LEN,
    parameter int PAGE_SIZE      = AXI_PAGE_SIZE_BYTES
)(
    input clk,
    input rst_n,
    axi_if.Master intf
);

    // ---------------------------------
    // INTERNAL TRACKING VARIABLES
    // ---------------------------------
    logic [DATA_WIDTH-1:0] image_buffer[$];
    int id = 0;

    // --------------------------------------------------------
    // task to Load the image into the buffer internal buffers 
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

        $display("[DMA] Successfully loaded %0d words (%0d bytes) from %s", image_buffer.size(), image_buffer.size() * (DATA_WIDTH/8), file_path);
    endtask   

    // --------------------------------------------------
    // task to start the image transfer on the base addr
    // --------------------------------------------------
    task automatic transfer_image(input logic [ADDR_WIDTH-1:0] base_addr);
        logic [ADDR_WIDTH-1:0] curr_addr;
        logic [1:0]  bresp_status;
        int bytes_per_beat; // the number of bytes that can be sent on the data bus.

        bytes_per_beat = DATA_WIDTH / 8;
        curr_addr = base_addr;

        if (image_buffer.size() == 0) begin
            $error("[DMA ERROR] Transfer attempted with empty image buffer.");
            return;
        end

        $display("[DMA] Starting payload transfer to Base Addr: 0x%0h", curr_addr);

        while (image_buffer.size() > 0) begin
            // The AXI Maximum Burst Length is 4KB, so We need to make sure that we send 4KB-Aligned Bursts.
            // We need to start from a base_addr, calculating the image size, the number of words remaining in the image, 
            // the maximum words to be sent to align with the 4kb rule, then
            // we will send the min(remaining words, 256 beats, maximum-words-for-4kb)

            int beats_remaining; // Number Of beats Remaining in the image
            int bytes_to_page_boundary; // Maximum bytes to sent before hitting the 4kb boundary
            int max_beats_before_boundary; // Maximum beats before the 4kb boundary
            int burst_beats; // the number of beats to be sent, the min between (beats_remaining, max_beats_before_boundary, 256).
            logic [DATA_WIDTH-1:0] payload_chunk[$]; // the burst payload of the image.

            beats_remaining = image_buffer.size();

            // 4KB boundary calculation
            bytes_to_page_boundary = PAGE_SIZE - (curr_addr % PAGE_SIZE);
            max_beats_before_boundary  = bytes_to_page_boundary / bytes_per_beat;

            // Determine burst beat count
            burst_beats = beats_remaining;
            if (burst_beats > max_beats_before_boundary) burst_beats = max_beats_before_boundary;
            if (burst_beats > MAX_BURST_LEN) burst_beats = MAX_BURST_LEN;

            // Get the payload from the image
            payload_chunk.delete();
            for (int i = 0; i < burst_beats; i++) begin
                payload_chunk.push_back(image_buffer.pop_front());
            end

            id++;
            $display("[DMA] Issuing Burst Txn #%0d | Addr: 0x%0h | Beats: %0d (%0d Bytes)", id, curr_addr, burst_beats, burst_beats * bytes_per_beat);

            // Call interface write_burst task (AWLEN = burst_beats - 1)
            intf.write_burst(
                .txn_id(id),
                .base_addr(curr_addr),
                .burst_len(burst_beats - 1),
                .payload(payload_chunk),
                .response(bresp_status)
            );

            if (bresp_status != 2'b00) begin
                $error("[DMA ERROR] Txn #%0d failed with BRESP = 2'b%0b at Addr 0x%0h", id, bresp_status, curr_addr);
                $finish;
            end

            // increment target address by the number of bytes sent
            curr_addr += (burst_beats * bytes_per_beat);
        end

        $display("[DMA] Transfer completed successfully. End Addr: 0x%0h", curr_addr);
    endtask

    initial begin
        intf.reset_master();
        wait(rst_n);
        repeat (2) @(posedge clk);

        // Load file and execute transfer using base address.
        load_image("image.hex");
        transfer_image(DEFAULT_IMAGE_BASE_ADDR);
    end
endmodule