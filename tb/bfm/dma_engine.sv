import aou_tb_pkg::*;
module dma_engine #(
    parameter int ADDR_WIDTH = AXI_ADDR_WIDTH,
    parameter int DATA_WIDTH = AXI_DATA_WIDTH,
    parameter int ID_WIDTH   = AXI_ID_WIDTH,
    parameter int STRB_WIDTH = AXI_STRB_WIDTH
)(
    input clk,
    input rst_n,
    axi_if.Master intf
);

    logic [DATA_WIDTH-1:0] image[$];
    int id = 0;
    logic [7:0] awlen;
    logic [1:0] response;
    logic [ADDR_WIDTH:0] base;
    int fd;
    int status;
    logic [DATA_WIDTH-1:0] data;
    initial begin
        fd = $fopen("image.hex", "r");
        if(fd == 0) begin
            $error("Failed to open image.hex");
        end else begin
            while ($fscanf(fd, "%h", data) == 1) begin
                image.push_back(data);
            end
        end

        $fclose(fd);

        $display("Queue size loaded: %0d elements", image.size());
        foreach (image[i]) begin
            $display("image[%0d] = 0x%h", i, image[i]);
        end



        wait(rst_n);
        base = 'h8000_0000
        while(image.size() > 0) begin
            awlen = image.size() - 1;
            intf.write_burst(++id, base, awlen, image, response);
        end
    end
endmodule