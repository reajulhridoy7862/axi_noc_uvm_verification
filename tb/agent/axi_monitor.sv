
class axi_monitor extends uvm_monitor;

  //Factory Registration
  `uvm_component_utils(axi_monitor)

  uvm_analysis_port #(axi_seq_item) analysis_port;

  //Constructor
  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

 // Build Phase 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    analysis_port = new("analysis_port", this);


    `uvm_info(get_type_name(), "INSIDE MONITOR BUILD PHASE", UVM_LOW)
  endfunction

 // connect Phase 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")

    `uvm_info(get_type_name(), "INSIDE MONITOR CONNECT PHASE", UVM_LOW)
  endfunction

 // RUN Phase 

  task run_phase(uvm_phase phase);


    forever begin


    `uvm_info(get_type_name(), "INSIDE MONITOR RUN PHASE", UVM_LOW)
  endtask
endclass
