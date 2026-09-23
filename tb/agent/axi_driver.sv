
class axi_driver extends uvm_driver#(axi_seq_item);

  //Factory Registration
  `uvm_component_utils(axi_driver)


  //Constructor
  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

 // Build Phase 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    

    `uvm_info(get_type_name(), "INSIDE DRIVER BUILD PHASE", UVM_LOW)
  endfunction

 // connect Phase 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "INSIDE DRIVER CONNECT PHASE", UVM_LOW)
  endfunction

 // RUN Phase 

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "INSIDE DRIVER RUN PHASE", UVM_LOW)
  endtask

endclass
