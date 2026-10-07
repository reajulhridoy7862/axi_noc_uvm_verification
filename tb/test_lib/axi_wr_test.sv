class axi_wr_test extends axi_base_test;

  `uvm_component_utils(axi_wr_test)

  function new(string name = "axi_wr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;

    phase.raise_objection(this);

    `uvm_info("WR_TEST", "Starting AXI write test", UVM_LOW)
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agt.seqr);

    write_seq = axi_write_sequence::type_id::create("write_seq");

    // Test configuration
    write_seq.addr = 32'h0000_1000;
    write_seq.data = 32'h1234_5678;
    write_seq.id   = 4'h1;
    write_seq.len  = 8'h00;       // 1 beat

    // Start sequence
    write_seq.start(env.agt.seqr);

    `uvm_info("WR_TEST", "AXI write test completed", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass
