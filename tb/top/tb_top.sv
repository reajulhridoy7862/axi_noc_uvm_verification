import axi_test_lib_pkg::*;


`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

module tb_top;

  bit clk;
  
  axi_if intf[NUM_MASTERS](clk, crif.rst_n);
  clk_rst_if crif (clk);

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_axi_assertions

    axi_assertion u_axi_assertion (
      .clk     (clk),
      .rst_n   (intf[i].rst_n),

      .awid    (intf[i].awid),
      .awaddr  (intf[i].awaddr),
      .awlen   (intf[i].awlen),
      .awsize  (intf[i].awsize),
      .awburst (intf[i].awburst),
      .awvalid (intf[i].awvalid),
      .awready (intf[i].awready),
      .wdata   (intf[i].wdata),
      .wstrb   (intf[i].wstrb),
      .wlast   (intf[i].wlast),
      .wvalid  (intf[i].wvalid),
      .wready  (intf[i].wready),
      .bid     (intf[i].bid),
      .bresp   (intf[i].bresp),
      .bvalid  (intf[i].bvalid),
      .bready  (intf[i].bready),
      .arid    (intf[i].arid),
      .araddr  (intf[i].araddr),
      .arlen   (intf[i].arlen),
      .arsize  (intf[i].arsize),
      .arburst (intf[i].arburst),
      .arvalid (intf[i].arvalid),
      .arready (intf[i].arready),
      .rid     (intf[i].rid),
      .rdata   (intf[i].rdata),
      .rresp   (intf[i].rresp),
      .rlast   (intf[i].rlast),
      .rvalid  (intf[i].rvalid),
      .rready  (intf[i].rready)
    );

  end


  bram_wrapper_sim_wrapper dut (

    .axi_clk_in_0_0        (clk),
    .axi_rst_in_0_n_0  (intf[0].rst_n),

    .S00_AXI_0_awid     (intf[0].awid),
    .S00_AXI_0_awaddr   (intf[0].awaddr),
    .S00_AXI_0_awlen    (intf[0].awlen),
    .S00_AXI_0_awsize   (intf[0].awsize),
    .S00_AXI_0_awburst  (intf[0].awburst),
    .S00_AXI_0_awvalid  (intf[0].awvalid),
    .S00_AXI_0_awready  (intf[0].awready),

    .S00_AXI_0_wdata    (intf[0].wdata),
    .S00_AXI_0_wstrb    (intf[0].wstrb),
    .S00_AXI_0_wlast    (intf[0].wlast),
    .S00_AXI_0_wvalid   (intf[0].wvalid),
    .S00_AXI_0_wready   (intf[0].wready),

    .S00_AXI_0_bid      (intf[0].bid),
    .S00_AXI_0_bresp    (intf[0].bresp),
    .S00_AXI_0_bvalid   (intf[0].bvalid),
    .S00_AXI_0_bready   (intf[0].bready),

    .S00_AXI_0_arid     (intf[0].arid),
    .S00_AXI_0_araddr   (intf[0].araddr),
    .S00_AXI_0_arlen    (intf[0].arlen),
    .S00_AXI_0_arsize   (intf[0].arsize),
    .S00_AXI_0_arburst  (intf[0].arburst),
    .S00_AXI_0_arvalid  (intf[0].arvalid),
    .S00_AXI_0_arready  (intf[0].arready),

    .S00_AXI_0_rid      (intf[0].rid),
    .S00_AXI_0_rdata    (intf[0].rdata),
    .S00_AXI_0_rresp    (intf[0].rresp),
    .S00_AXI_0_rlast    (intf[0].rlast),
    .S00_AXI_0_rvalid   (intf[0].rvalid),
    .S00_AXI_0_rready   (intf[0].rready),


    .S00_AXI_0_awcache  (intf[0].awcache),
    .S00_AXI_0_awlock   (intf[0].awlock),
    .S00_AXI_0_awprot   (intf[0].awprot),
    .S00_AXI_0_awqos    (intf[0].awqos),
    .S00_AXI_0_awregion (intf[0].awregion),
  
    .S00_AXI_0_arcache  (intf[0].arcache),
    .S00_AXI_0_arlock   (intf[0].arlock),
    .S00_AXI_0_arprot   (intf[0].arprot),
    .S00_AXI_0_arqos    (intf[0].arqos),
    .S00_AXI_0_arregion (intf[0].arregion),
    // MASTER 1 -> S01_AXI_0

    .S01_AXI_0_awid     (intf[1].awid),
    .S01_AXI_0_awaddr   (intf[1].awaddr),
    .S01_AXI_0_awlen    (intf[1].awlen),
    .S01_AXI_0_awsize   (intf[1].awsize),
    .S01_AXI_0_awburst  (intf[1].awburst),
    .S01_AXI_0_awvalid  (intf[1].awvalid),
    .S01_AXI_0_awready  (intf[1].awready),

    .S01_AXI_0_wdata    (intf[1].wdata),
    .S01_AXI_0_wstrb    (intf[1].wstrb),
    .S01_AXI_0_wlast    (intf[1].wlast),
    .S01_AXI_0_wvalid   (intf[1].wvalid),
    .S01_AXI_0_wready   (intf[1].wready),

    .S01_AXI_0_bid      (intf[1].bid),
    .S01_AXI_0_bresp    (intf[1].bresp),
    .S01_AXI_0_bvalid   (intf[1].bvalid),
    .S01_AXI_0_bready   (intf[1].bready),

    .S01_AXI_0_arid     (intf[1].arid),
    .S01_AXI_0_araddr   (intf[1].araddr),
    .S01_AXI_0_arlen    (intf[1].arlen),
    .S01_AXI_0_arsize   (intf[1].arsize),
    .S01_AXI_0_arburst  (intf[1].arburst),
    .S01_AXI_0_arvalid  (intf[1].arvalid),
    .S01_AXI_0_arready  (intf[1].arready),

    .S01_AXI_0_rid      (intf[1].rid),
    .S01_AXI_0_rdata    (intf[1].rdata),
    .S01_AXI_0_rresp    (intf[1].rresp),
    .S01_AXI_0_rlast    (intf[1].rlast),
    .S01_AXI_0_rvalid   (intf[1].rvalid),
    .S01_AXI_0_rready   (intf[1].rready),

    .S01_AXI_0_awcache  (intf[1].awcache),
    .S01_AXI_0_awlock   (intf[1].awlock),
    .S01_AXI_0_awprot   (intf[1].awprot),
    .S01_AXI_0_awqos    (intf[1].awqos),
    .S01_AXI_0_awregion (intf[1].awregion),
  
    .S01_AXI_0_arcache  (intf[1].arcache),
    .S01_AXI_0_arlock   (intf[1].arlock),
    .S01_AXI_0_arprot   (intf[1].arprot),
    .S01_AXI_0_arqos    (intf[1].arqos),
    .S01_AXI_0_arregion (intf[1].arregion),

    // MASTER 2 -> S02_AXI_0

    .S02_AXI_0_awid     (intf[2].awid),
    .S02_AXI_0_awaddr   (intf[2].awaddr),
    .S02_AXI_0_awlen    (intf[2].awlen),
    .S02_AXI_0_awsize   (intf[2].awsize),
    .S02_AXI_0_awburst  (intf[2].awburst),
    .S02_AXI_0_awvalid  (intf[2].awvalid),
    .S02_AXI_0_awready  (intf[2].awready),

    .S02_AXI_0_wdata    (intf[2].wdata),
    .S02_AXI_0_wstrb    (intf[2].wstrb),
    .S02_AXI_0_wlast    (intf[2].wlast),
    .S02_AXI_0_wvalid   (intf[2].wvalid),
    .S02_AXI_0_wready   (intf[2].wready),

    .S02_AXI_0_bid      (intf[2].bid),
    .S02_AXI_0_bresp    (intf[2].bresp),
    .S02_AXI_0_bvalid   (intf[2].bvalid),
    .S02_AXI_0_bready   (intf[2].bready),

    .S02_AXI_0_arid     (intf[2].arid),
    .S02_AXI_0_araddr   (intf[2].araddr),
    .S02_AXI_0_arlen    (intf[2].arlen),
    .S02_AXI_0_arsize   (intf[2].arsize),
    .S02_AXI_0_arburst  (intf[2].arburst),
    .S02_AXI_0_arvalid  (intf[2].arvalid),
    .S02_AXI_0_arready  (intf[2].arready),

    .S02_AXI_0_rid      (intf[2].rid),
    .S02_AXI_0_rdata    (intf[2].rdata),
    .S02_AXI_0_rresp    (intf[2].rresp),
    .S02_AXI_0_rlast    (intf[2].rlast),
    .S02_AXI_0_rvalid   (intf[2].rvalid),
    .S02_AXI_0_rready   (intf[2].rready),

    .S02_AXI_0_awcache  (intf[2].awcache),
    .S02_AXI_0_awlock   (intf[2].awlock),
    .S02_AXI_0_awprot   (intf[2].awprot),
    .S02_AXI_0_awqos    (intf[2].awqos),
    .S02_AXI_0_awregion (intf[2].awregion),
  
    .S02_AXI_0_arcache  (intf[2].arcache),
    .S02_AXI_0_arlock   (intf[2].arlock),
    .S02_AXI_0_arprot   (intf[2].arprot),
    .S02_AXI_0_arqos    (intf[2].arqos),
    .S02_AXI_0_arregion (intf[2].arregion),

    // MASTER 3 -> S03_AXI_0

    .S03_AXI_0_awid     (intf[3].awid),
    .S03_AXI_0_awaddr   (intf[3].awaddr),
    .S03_AXI_0_awlen    (intf[3].awlen),
    .S03_AXI_0_awsize   (intf[3].awsize),
    .S03_AXI_0_awburst  (intf[3].awburst),
    .S03_AXI_0_awvalid  (intf[3].awvalid),
    .S03_AXI_0_awready  (intf[3].awready),

    .S03_AXI_0_wdata    (intf[3].wdata),
    .S03_AXI_0_wstrb    (intf[3].wstrb),
    .S03_AXI_0_wlast    (intf[3].wlast),
    .S03_AXI_0_wvalid   (intf[3].wvalid),
    .S03_AXI_0_wready   (intf[3].wready),

    .S03_AXI_0_bid      (intf[3].bid),
    .S03_AXI_0_bresp    (intf[3].bresp),
    .S03_AXI_0_bvalid   (intf[3].bvalid),
    .S03_AXI_0_bready   (intf[3].bready),

    .S03_AXI_0_arid     (intf[3].arid),
    .S03_AXI_0_araddr   (intf[3].araddr),
    .S03_AXI_0_arlen    (intf[3].arlen),
    .S03_AXI_0_arsize   (intf[3].arsize),
    .S03_AXI_0_arburst  (intf[3].arburst),
    .S03_AXI_0_arvalid  (intf[3].arvalid),
    .S03_AXI_0_arready  (intf[3].arready),

    .S03_AXI_0_rid      (intf[3].rid),
    .S03_AXI_0_rdata    (intf[3].rdata),
    .S03_AXI_0_rresp    (intf[3].rresp),
    .S03_AXI_0_rlast    (intf[3].rlast),
    .S03_AXI_0_rvalid   (intf[3].rvalid),
    .S03_AXI_0_rready   (intf[3].rready),

    .S03_AXI_0_awcache  (intf[3].awcache),
    .S03_AXI_0_awlock   (intf[3].awlock),
    .S03_AXI_0_awprot   (intf[3].awprot),
    .S03_AXI_0_awqos    (intf[3].awqos),
    .S03_AXI_0_awregion (intf[3].awregion),

    .S03_AXI_0_arcache  (intf[3].arcache),
    .S03_AXI_0_arlock   (intf[3].arlock),
    .S03_AXI_0_arprot   (intf[3].arprot),
    .S03_AXI_0_arqos    (intf[3].arqos),
    .S03_AXI_0_arregion (intf[3].arregion)


  );


  initial begin
    clk = 0;
    forever #(1.666685) clk = ~clk;
  end 

  initial begin
    run_test("dummy_test");
  end 

  //initial begin 
  //  rst_n = 1'b0;
  //  #10
  //  rst_n = 1'b1;
  //end

  initial begin
      uvm_config_db#(virtual clk_rst_if)::set(null, "*", "rst_vif", crif); 
      // Driver
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[0].drv","vif",intf[0]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[1].drv","vif",intf[1]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[2].drv","vif",intf[2]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[3].drv","vif",intf[3]);
      
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[0].mon","vif",intf[0]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[1].mon","vif",intf[1]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[2].mon","vif",intf[2]);
      uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.env.agt[3].mon","vif",intf[3]);
  end 

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(1, tb_top);
  end 


  task automatic init_sideband(virtual axi_if vif);
    vif.awcache  = 4'b0011;
    vif.awlock   = 1'b0;
    vif.awprot   = 3'b000;
    vif.awqos    = 4'b0000;
    vif.awregion = 4'b0000;

    vif.arcache  = 4'b0011;
    vif.arlock   = 1'b0;
    vif.arprot   = 3'b000;
    vif.arqos    = 4'b0000;
    vif.arregion = 4'b0000;
  endtask

  initial begin
    init_sideband(intf[0]);
    init_sideband(intf[1]);
    init_sideband(intf[2]);
    init_sideband(intf[3]);
  end

  /*always @(intf[0].rst_n) begin
    intf[1].rst_n = intf[0].rst_n;
    intf[2].rst_n = intf[0].rst_n;
    intf[3].rst_n = intf[0].rst_n;
  end
  always @(intf[1].rst_n) begin
    intf[0].rst_n = intf[1].rst_n;
    intf[2].rst_n = intf[1].rst_n;
    intf[3].rst_n = intf[1].rst_n;
  end
  always @(intf[2].rst_n) begin
    intf[0].rst_n = intf[2].rst_n;
    intf[1].rst_n = intf[2].rst_n;
    intf[3].rst_n = intf[2].rst_n;
  end
  always @(intf[3].rst_n) begin
    intf[0].rst_n = intf[3].rst_n;
    intf[1].rst_n = intf[3].rst_n;
    intf[2].rst_n = intf[3].rst_n;
  end*/

endmodule

