
class axi_base_sequence extends uvm_sequence #(axi_seq_item);
  
  `uvm_object_utils(axi_base_sequence);
  
  function new(string name = "axi_base_sequence");
    super.new(name);

  endfunction


  
  task body();
    `uvm_info(get_type_name(), "INSIDE SEQUENCE BODY", UVM_LOW);
  endtask

endclass


