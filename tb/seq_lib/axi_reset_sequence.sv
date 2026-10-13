class axi_reset_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_reset_sequence)

  function new(string name ="axi_reset_sequence");
    super.new(name);
  endfunction

  task body();
    axi_seq_item req;
    
    req = axi_seq_item::type_id::create("req");

    start_item(req);
    req.kind  = axi_seq_item::AXI_RESET;

    finish_item(req);
  endtask
endclass
    

