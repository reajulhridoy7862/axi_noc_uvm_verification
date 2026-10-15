class axi_burst_write_read_test extends axi_base_test;

  `uvm_component_utils(axi_burst_write_read_test)

  function new(string name = "axi_burst_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;
    axi_read_sequence read_seq;

    phase.raise_objection(this);

    // RESET DUT
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    `uvm_info("BURST_WRITE_TEST", "Starting DUT reset", UVM_LOW)
    reset_seq.start(env.agt[0].seqr);
  
    // CREATE BURST WRITE
    #10us;
    write_seq = axi_write_sequence::type_id::create("write_seq");

    write_seq.addr = 64'h201_0000_0000;
    write_seq.data = 64'hffff_ffff_ffff_ffff;
    write_seq.id   = 2'h1;
    write_seq.len  = 8'h08;


    `uvm_info("BURST_WRITE_TEST", $sformatf("Starting burst write: ADDR=%h AWLEN=%0d BEATS=%0d", write_seq.addr, write_seq.len, write_seq.len + 1), UVM_LOW)

    // START BURST WRITE
    write_seq.start(env.agt[0].seqr);
    `uvm_info("BURST_WRITE_TEST", "Burst write sequence completed", UVM_LOW)
    
        // 2. Generate burst READ request

    #10us;
    read_seq = axi_read_sequence::type_id::create("read_seq");

    read_seq.addr = 64'h201_0000_0000;
    read_seq.id   = 8'h1;

    read_seq.len  = 8'h08;

    read_seq.start(env.agt[0].seqr);



    phase.drop_objection(this);

  endtask

endclass
