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
    reset_seq.start(env.agt.seqr);


    // CREATE WRITE SEQUENCE
    write_seq = axi_write_sequence::type_id::create("write_seq");
    write_seq.addr = 32'h1111_1111;
    write_seq.data = 32'h1234_5678;
    write_seq.len  = 8'h0A;
    write_seq.id   = 4'h2;
    
    // CREATE READ SEQUENCE
    read_seq =  axi_read_sequence::type_id::create("read_seq");
    read_seq.addr = 32'h1111_1111;
    read_seq.len  = 8'h03;
    read_seq.id   = 4'h3;

    // START READ + WRITE CONCURRENTLY

    fork
        write_seq.start(env.agt.seqr);
        read_seq.start(env.agt.seqr);
    join


    // END TEST
    phase.drop_objection(this);

  endtask

endclass
