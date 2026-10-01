class axi_wr_rd_test extends axi_base_test;
  `uvm_component_utils(axi_wr_rd_test)

  function new(string name ="axi_wr_rd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;
    
    phase.raise_objection(this);
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agt.seqr);

    write_seq = axi_write_sequence::type_id::create("write_seq");
    write_seq.addr = 32'h1111_1111;
    write_seq.data = 32'h12345678;
    write_seq.len  = 8'h00;
    write_seq.id   = 4'h2;

    write_seq.start(env.agt.seqr);

    phase.drop_objection(this);

  endtask

endclass



