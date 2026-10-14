
class axi_environment extends uvm_env;

  `uvm_component_utils(axi_environment )

  axi_agent agt[4];
  axi_scoreboard sb;
  axi_ref_model ref_model;
  axi_coverage cov;

  function new(string name = "axi_environment", uvm_component parent = null);
    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT BUILD PHASE", UVM_LOW)

    cov =axi_coverage::type_id::create("cov",this);

    for (int i= 0; i<NUM_MASTERS; i++) begin
      agt[i] = axi_agent::type_id::create($sformatf("agt[%0d]",i), this);
    //  cov[i] =axi_functional_coverage::type_id::create($sformatf("cov[%0d]",i), this);
    end


   // agt = axi_agent::type_id::create("agt", this);

    sb = axi_scoreboard::type_id::create("sb", this);

    ref_model = axi_ref_model::type_id::create("ref_model", this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT CONNECT PHASE", UVM_LOW)
    
    for (int i=0; i<NUM_MASTERS; i++) begin
      agt[i].mon.sb_port.connect(sb.act_imp);
      agt[i].mon.ref_port.connect(ref_model.analysis_export);
    end

    for (int i = 0; i < NUM_MASTERS; i++) begin
      agt[i].mon.sb_port.connect(cov.analysis_export);   
      cov.vifs[i] = agt[i].mon.vif;                     
    end

    

//    agt.mon.sb_port.connect(sb.act_imp);
//    agt.mon.ref_port.connect(ref_model.analysis_export);
    ref_model.exp_port.connect(sb.exp_imp);


  endfunction

  task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(), "INSIDE ENVIRONMENT RUN PHASE", UVM_LOW)
    
  endtask

endclass
