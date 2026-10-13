class axi_wr_rd_test extends axi_base_test;

  `uvm_component_utils(axi_wr_rd_test)

  function new(string name = "axi_wr_rd_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;
    axi_read_sequence  read_seq;

    phase.raise_objection(this);
 
    // RESET
    reset_seq =  axi_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agt[0].seqr);
    
    #10us;    
    // CREATE WRITE SEQUENCE
    write_seq = axi_write_sequence::type_id::create("write_seq");
    write_seq.addr = 64'h201_0000_0010;
    write_seq.data = 64'h1234_5678_9012_3456;
    write_seq.len  = 8'h00;
    write_seq.id   = 2'h1;

    write_seq.start(env.agt[0].seqr);
    #10us; 
    // CREATE READ SEQUENCE
    read_seq =  axi_read_sequence::type_id::create("read_seq");
    read_seq.addr = 64'h201_0000_0010;
    read_seq.len  = 8'h00;
    read_seq.id   = 2'h3;
    read_seq.start(env.agt[3].seqr);

    // START READ + WRITE CONCURRENTLY

    //fork
    //write_seq.start(env.agt[0].seqr);
    //read_seq.start(env.agt[0].seqr);
    //join


    // END TEST
    phase.drop_objection(this);

  endtask

endclass
