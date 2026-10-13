
class axi_base_test extends uvm_test;

  `uvm_component_utils(axi_base_test)
  axi_environment env;

  function new(string name = "axi_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "INSIDE BASE CLASS BUILD PHASE", UVM_LOW)

    for (int i = 0; i < NUM_MASTERS; i++) begin

      uvm_config_db#(int unsigned)::set(this,$sformatf("env.agt[%0d]",i),"master_id",i);
    end

    env = axi_environment::type_id::create("env", this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    `uvm_info(get_type_name(), "INSIDE BASE CLASS CONNECT PHASE", UVM_LOW)

  endfunction

  task run_phase(uvm_phase phase);
    
    //phase.raise_objection(this);

    `uvm_info(get_type_name(), "INSIDE BASE CLASS RUN PHASE", UVM_LOW)
    

    //phase.drop_objection(this);

  endtask

endclass
