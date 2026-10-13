
class axi_agent extends uvm_agent;

  `uvm_component_utils(axi_agent)

  axi_driver drv;
  axi_sequencer seqr;
  axi_monitor mon;
  int unsigned master_id;

  function new(string name = "axi_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(int unsigned)::get(this, "", "master_id", master_id))
      `uvm_fatal("NO_MASTER_ID", "Master ID not configured")

    `uvm_info(get_type_name(), "INSIDE AGENT BUILD PHASE", UVM_LOW)

    drv = axi_driver::type_id::create("drv", this);

    mon = axi_monitor::type_id::create("mon", this);

    seqr = axi_sequencer::type_id::create("seqr", this);

    uvm_config_db#(int unsigned)::set(this,"drv","master_id",master_id);
    uvm_config_db#(int unsigned)::set(this,"mon","master_id",master_id);

    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    `uvm_info(get_type_name(), "INSIDE AGENT CONNECT PHASE", UVM_LOW)
    drv.seq_item_port.connect(seqr.seq_item_export);

  endfunction


  task run_phase(uvm_phase phase);
    
    `uvm_info(get_type_name(), "INSIDE AGENT RUN PHASE", UVM_LOW)
  endtask
endclass





