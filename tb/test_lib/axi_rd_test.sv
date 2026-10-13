class axi_rd_test extends axi_base_test;

  `uvm_component_utils(axi_rd_test)

  function new(string name = "axi_rd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_read_sequence  read_seq;

    phase.raise_objection(this);

    // RESET DUT
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");

    `uvm_info("RD_TEST", "Starting DUT reset", UVM_LOW)

    reset_seq.start(env.agt[0].seqr);
    #10;

    // CREATE READ SEQUENCE
    read_seq = axi_read_sequence::type_id::create("read_seq");

    read_seq.addr = 64'h201_0000_0000;
    read_seq.id   = 2'h1;
    read_seq.len  = 8'h00;       // 1 beat

    // START READ
    `uvm_info("RD_TEST", "Starting AXI read", UVM_LOW)

    read_seq.start(env.agt[0].seqr);

    `uvm_info("RD_TEST", "AXI read test completed", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass
