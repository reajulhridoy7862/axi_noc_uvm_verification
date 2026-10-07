class axi_burst_read_test extends axi_base_test;

  `uvm_component_utils(axi_burst_read_test)

  function new(string name = "axi_burst_read_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_read_sequence  read_seq;

    phase.raise_objection(this);


    // 1. Reset DUT
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agt.seqr);

    // 2. Generate burst READ request
    read_seq = axi_read_sequence::type_id::create("read_seq");

    read_seq.addr = 32'h0000_1000;
    read_seq.id   = 4'h1;

    read_seq.len  = 8'h04;

    read_seq.start(env.agt.seqr);


    // 3. Finish test
    phase.drop_objection(this);

  endtask

endclass
