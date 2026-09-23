
class axi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi_scoreboard)

//  uvm_analysis_imp #(axi_seq_item, axi_scoreboard) analysis_imp;

  //Constructor

  function new(string name = "axi_scoreboard", uvm_component parent = null);

    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  //  analysis_imp = new("analysis_imp", this);

    `uvm_info(get_type_name(), "INSIDE SCOREBOARD BUILD PHASE", UVM_LOW)
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "INSIDE SCOREBOARD CONNECT PHASE", UVM_LOW)

  endfunction

  task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(), "INSIDE SCOREBOARD RUN PHASE", UVM_LOW)

  endtask
endclass
