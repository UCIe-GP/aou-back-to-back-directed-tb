module tb_top ();

logic clk;
logic rst_n;

// CLOCK GENERATION
initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
end

// RESET
initial begin
    rst_n = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
end


endmodule