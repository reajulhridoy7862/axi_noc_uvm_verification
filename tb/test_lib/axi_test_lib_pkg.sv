package axi_test_lib_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axi_pkg::*;

  import axi_seq_lib_pkg::*;
  import axi_environment_pkg::*;
  `include "axi_base_test.sv"
//  `include "axi_reset_test.sv"
  `include "axi_wr_test.sv"
  `include "axi_wr_rd_test.sv"
  `include "axi_rd_test.sv"
  `include "axi_burst_write_read_test.sv"
//  `include "axi_burst_read_test.sv"
  `include "axi_wr_all_after_rd_all_test.sv"
  `include "axi_wr_rd_all_addr_test.sv"

endpackage
