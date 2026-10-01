import axi_test_lib_pkg::*;


`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  bit clk;
  axi_if intf(clk);

  initial begin
    clk = 0;
    forever #(5) clk = ~clk;
  end 

  initial begin
    run_test("dummy_test");
 end 


  initial begin 
    uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top.env.agt.*", "vif", intf);
  end 

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(1, tb_top);
  end 

endmodule

