class axi_reset_test extends axi_base_test;
  
  `uvm_component_utils(axi_reset_test)

  axi_environment env;

  function new(string name = "axi_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;

    phase.raise_objection(this);

    `uvm_info("RESET_TEST", "Starting AXI reset test", UVM_LOW)

    reset_seq = axi_reset_sequence::type_id::create("reset_seq");

    reset_seq.start(env.agt.seqr);

    `uvm_info("RESET_TEST","AXI reset test completed", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass


