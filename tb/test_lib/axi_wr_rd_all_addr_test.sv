class axi_wr_rd_all_addr_test extends axi_base_test;

  `uvm_component_utils(axi_wr_rd_all_addr_test)

  // Assume DUT memory address range
  localparam logic [ADDR_WIDTH-1:0] LOWER_ADDR = 64'h201_0000_0000;
  localparam logic [ADDR_WIDTH-1:0] UPPER_ADDR = 64'h201_0000_00ff;

  function new(string name = "axi_wr_rd_all_addr_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    axi_reset_sequence reset_seq;
    axi_write_sequence write_seq;
    axi_read_sequence  read_seq;

    logic [DATA_WIDTH-1:0] write_data;
    logic [ID_WIDTH-1:0]   id;

    phase.raise_objection(this);

    // RESET
    reset_seq = axi_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agt[0].seqr);

    #10us;

    // WRITE AND READ EACH ADDRESS

    write_data = 64'h1000_0000_1111_1111;
    id         = '0;

    for (logic [ADDR_WIDTH-1:0] addr = LOWER_ADDR;
         addr <= UPPER_ADDR;
         addr += 8) begin


      write_seq = axi_write_sequence::type_id::create("write_seq");

      write_seq.addr = addr;
      write_seq.data = write_data;
      write_seq.id   = id;
      write_seq.len  = 8'h00;  // Single-beat write

      `uvm_info("ADDR_TEST",
        $sformatf("WRITE: ADDR=%h DATA=%h ID=%0d",
                  write_seq.addr, write_seq.data, write_seq.id),
        UVM_LOW)

      write_seq.start(env.agt[0].seqr);
      
      #10;
  

      read_seq = axi_read_sequence::type_id::create("read_seq");

      read_seq.addr = addr;
      read_seq.id   = id;
      read_seq.len  = 8'h00;  // Single-beat read
      
      
      `uvm_info("ADDR_TEST",
        $sformatf("READ: ADDR=%h ID=%0d",
                  read_seq.addr, read_seq.id),
        UVM_LOW)
      
      read_seq.start(env.agt[0].seqr);



      write_data = write_data + 1;
      id         = id + 1'b1;

    end

    `uvm_info("ADDR_TEST",
      "All addresses have completed write-then-read transactions.",
      UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass
