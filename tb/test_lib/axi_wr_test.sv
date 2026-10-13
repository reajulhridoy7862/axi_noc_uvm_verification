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
    reset_seq.start(env.agt[0].seqr);
    
    `uvm_info("WR_TEST", "Reset sequence completed; waiting 10 us before write", UVM_LOW)

    #10us;


    write_seq = axi_write_sequence::type_id::create("write_seq");

    // Test configuration
    write_seq.addr = 64'h201_0001_0000;
    write_seq.data = 64'h1234_5678_ABCD_EF01;
    write_seq.id   = 2'h1;
    write_seq.len  = 8'h00;       // 1 beat

    // Start sequence
    write_seq.start(env.agt[0].seqr);

    `uvm_info("WR_TEST", $sformatf("addr=%0h data=%0h id=%0h ",write_seq.addr, write_seq.data, write_seq.id), UVM_LOW)

    phase.drop_objection(this);

    `uvm_info("WR_TEST", "AXI write sequence has sent to driver", UVM_LOW)


  endtask

endclass
