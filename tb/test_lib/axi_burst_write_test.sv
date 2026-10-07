class axi_burst_write_test extends axi_base_test;

  `uvm_component_utils(axi_burst_write_test)

  function new(string name = "axi_burst_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;

    phase.raise_objection(this);

    // RESET DUT
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    `uvm_info("BURST_WRITE_TEST", "Starting DUT reset", UVM_LOW)
    reset_seq.start(env.agt.seqr);
  
    // CREATE BURST WRITE
    write_seq = axi_write_sequence::type_id::create("write_seq");

    write_seq.addr = 32'h0000_1000;
    write_seq.data = 32'h1000_0000;
    write_seq.id   = 4'h1;
    write_seq.len  = 8'h04;


    `uvm_info("BURST_WRITE_TEST", $sformatf("Starting burst write: ADDR=%h AWLEN=%0d BEATS=%0d", write_seq.addr, write_seq.len, write_seq.len + 1), UVM_LOW)

    // START BURST WRITE
    write_seq.start(env.agt.seqr);
    `uvm_info("BURST_WRITE_TEST", "Burst write completed", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass
