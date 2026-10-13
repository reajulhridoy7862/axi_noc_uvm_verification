interface clk_rst_if (input logic clk);

  logic rst_n = 1'b0;

  task automatic apply_reset(int unsigned cycles = 5);
    rst_n <= 1'b0;
    repeat (cycles) @(posedge clk);
    rst_n <= 1'b1;
    @(posedge clk);
  endtask

endinterface
