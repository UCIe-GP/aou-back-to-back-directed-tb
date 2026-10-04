// ============================================================================
// File: tb/bfm/dma_engine.sv
// Description: Fully parameterized DMA Engine. Encapsulates file loading and
//              bus transmission into modular automatic tasks.
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
    input logic clk,
    input logic rst_n,
    axi_if.Master intf
);

  // Internal storage queues
  logic [DATA_WIDTH-1:0] image_buffer[$];
  int                    txn_id_counter = 0;

  // --------------------------------------------------------------------------
  // Task: Load Image File into Queue
  // Fully agnostic to word size ($bits(data) handles line width).
  // --------------------------------------------------------------------------
  task automatic load_image_file(
      input string file_path
  );
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

  // --------------------------------------------------------------------------
  // Task: Transfer Image Payload Across AXI Bus
  // Handles 4KB boundary splitting and maximum burst length capping dynamically.
  // --------------------------------------------------------------------------
  task automatic transfer_image(
      input logic [ADDR_WIDTH-1:0] start_addr
  );
    logic [ADDR_WIDTH-1:0] curr_addr;
    logic [1:0]            bresp_status;
    int                    bytes_per_beat;

    bytes_per_beat = DATA_WIDTH / 8;
    curr_addr      = start_addr;

    if (image_buffer.size() == 0) begin
      $error("[DMA ERROR] Transfer attempted with empty image buffer.");
      return;
    end

    $display("[DMA] Starting payload transfer to Base Addr: 0x%0h", curr_addr);

    while (image_buffer.size() > 0) begin
      int words_remaining;
      int bytes_to_page_boundary;
      int max_words_to_boundary;
      int burst_beats;
      logic [DATA_WIDTH-1:0] payload_chunk[$];

      words_remaining = image_buffer.size();

      // Dynamic 4KB boundary calculation
      bytes_to_page_boundary = PAGE_SIZE - (curr_addr % PAGE_SIZE);
      max_words_to_boundary  = bytes_to_page_boundary / bytes_per_beat;

      // Determine legal burst beat count
      burst_beats = words_remaining;
      if (burst_beats > max_words_to_boundary) burst_beats = max_words_to_boundary;
      if (burst_beats > MAX_BURST_LEN)          burst_beats = MAX_BURST_LEN;

      // Slice payload chunk for this burst
      payload_chunk.delete();
      for (int i = 0; i < burst_beats; i++) begin
        payload_chunk.push_back(image_buffer.pop_front());
      end

      txn_id_counter++;
      $display("[DMA] Issuing Burst Txn #%0d | Addr: 0x%0h | Beats: %0d (%0d Bytes)", 
               txn_id_counter, curr_addr, burst_beats, burst_beats * bytes_per_beat);

      // Call interface write_burst task (AWLEN = burst_beats - 1)
      intf.write_burst(
          .txn_id(txn_id_counter),
          .base_addr(curr_addr),
          .burst_len(burst_beats - 1),
          .payload(payload_chunk),
          .response(bresp_status)
      );

      if (bresp_status != 2'b00) begin
        $error("[DMA ERROR] Txn #%0d failed with BRESP = 2'b%0b at Addr 0x%0h", 
               txn_id_counter, bresp_status, curr_addr);
        $finish;
      end

      // Advance target address
      curr_addr += (burst_beats * bytes_per_beat);
    end

    $display("[DMA] Transfer completed successfully. End Addr: 0x%0h", curr_addr);
  endtask

  // --------------------------------------------------------------------------
  // Main Execution Thread
  // --------------------------------------------------------------------------
  initial begin
    intf.reset_master();
    wait(rst_n);
    repeat (2) @(posedge clk);

    // Load file and execute transfer using package default base address
    load_image_file("image.hex");
    transfer_image(DEFAULT_IMAGE_BASE_ADDR);
  end

endmodule