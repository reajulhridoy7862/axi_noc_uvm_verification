
class axi_environment extends uvm_env;

  `uvm_component_utils(axi_environment )

  axi_agent agt;
  axi_scoreboard sb;

  function new(string name = "axi_environment", uvm_component parent = null);
    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT BUILD PHASE", UVM_LOW)

    agt = axi_agent::type_id::create("agt", this);

    sb = axi_scoreboard::type_id::create("sb", this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT CONNECT PHASE", UVM_LOW)

  endfunction

  task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT RUN PHASE", UVM_LOW)
    
  endtask

endclass
