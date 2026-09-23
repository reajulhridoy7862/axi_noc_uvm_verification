package axi_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import axi_seq_lib_pkg::*;

  `include "axi_driver.sv"
  `include "axi_monitor.sv"
  `include "axi_sequencer.sv"
  `include "axi_agent.sv"

endpackage
