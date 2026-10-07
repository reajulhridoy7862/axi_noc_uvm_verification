`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class axi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp_exp #(axi_seq_item, axi_scoreboard) exp_imp;
  uvm_analysis_imp_act #(axi_seq_item, axi_scoreboard) act_imp;

  axi_seq_item exp_q[$];
  axi_seq_item act_q[$];

  int wr_pass = 0;
  int wr_fail = 0;
  int rd_pass = 0;
  int rd_fail = 0;

  function new(string name = "axi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_imp = new("exp_imp", this);
    act_imp = new("act_imp", this);
  endfunction

  function void write_exp(axi_seq_item tr);
    exp_q.push_back(tr);
    compare();
  endfunction

  // ACTUAL TRANSACTION
  function void write_act(axi_seq_item tr);
    act_q.push_back(tr);
    compare();
  endfunction

  // COMPARE
  function void compare();
    axi_seq_item exp;
    axi_seq_item act;
    // Nothing to compare yet
    if (exp_q.size() == 0 || act_q.size() == 0)
      return;

    // Take oldest expected and actual transaction
    exp = exp_q.pop_front();
    act = act_q.pop_front();

    if (exp.kind != act.kind) begin

      `uvm_error("SB_KIND", $sformatf( "Transaction type mismatch: EXP=%s ACT=%s", exp.kind.name(), act.kind.name() ))
      return;
    end

    // WRITE

    if (act.kind == axi_seq_item::AXI_WRITE) begin
      compare_write(exp, act);
    end

    // READ
    //
    else if (act.kind == axi_seq_item::AXI_READ) begin
      compare_read(exp, act);
    end

  endfunction

  // WRITE COMPARISON
  function void compare_write( axi_seq_item exp, axi_seq_item act);

    bit pass = 1;
    if (exp.awid != act.awid) begin

      `uvm_error( "SB_WRITE", $sformatf( "WRITE ID mismatch: EXP=%0d ACT=%0d", exp.awid, act.awid))
      pass = 0;
    end

    if (exp.awaddr != act.awaddr) begin

      `uvm_error( "SB_WRITE", $sformatf( "WRITE address mismatch: EXP=%h ACT=%h", exp.awaddr, act.awaddr))
      pass = 0;
    end

    // Check BRESP

    if (exp.bresp !== act.bresp) begin

      `uvm_error( "SB_BRESP", $sformatf( "WRITE ID=%0d: BRESP EXP=%0d ACT=%0d", act.awid, exp.bresp, act.bresp))
      pass = 0;
    end


    // Final result
    if (pass) begin
      wr_pass++;
      `uvm_info( "SB_WRITE", $sformatf("WRITE PASS: ID=%0d ADDR=%h BRESP=%0d", act.awid, act.awaddr, act.bresp),UVM_MEDIUM)
    end
    else begin
      wr_fail++;

    end

  endfunction

  // READ COMPARISON
  function void compare_read( axi_seq_item exp, axi_seq_item act);
    bit pass = 1;
    // Check ID
    if (exp.arid != act.arid) begin

      `uvm_error( "SB_READ", $sformatf( "READ ID mismatch: EXP=%0d ACT=%0d", exp.arid, act.arid ))
      pass = 0;

    end

    // Check address

    if (exp.araddr != act.araddr) begin

      `uvm_error("SB_READ", $sformatf( "READ address mismatch: EXP=%h ACT=%h", exp.araddr, act.araddr))
      pass = 0;

    end

    // Check number of RDATA beats

    if (exp.rdata_q.size() != act.rdata_q.size()) begin

      `uvm_error("SB_RDATA", $sformatf("READ beat count mismatch: EXP=%0d ACT=%0d",exp.rdata_q.size(), act.rdata_q.size() ))
      pass = 0;

    end
    else begin

      // Compare every RDATA beat

      foreach (exp.rdata_q[i]) begin
        if (exp.rdata_q[i] !== act.rdata_q[i]) begin

          `uvm_error( "SB_RDATA", $sformatf( "READ ID=%0d BEAT=%0d: DATA EXP=%h ACT=%h", act.arid, i, exp.rdata_q[i], act.rdata_q[i] ))
          pass = 0;
        end


        // Compare RRESP

        if (exp.rresp_q[i] !== act.rresp_q[i]) begin

          `uvm_error("SB_RRESP", $sformatf( "READ ID=%0d BEAT=%0d: RESP EXP=%0d ACT=%0d", act.arid, i, exp.rresp_q[i], act.rresp_q[i] ))
          pass = 0;

        end

      end

    end


    // Final result

    if (pass) begin
      rd_pass++;

      `uvm_info( "SB_READ", $sformatf( "READ PASS: ID=%0d ADDR=%h", act.arid, act.araddr
        ), UVM_MEDIUM
      )

    end
    else begin

      rd_fail++;

    end

  endfunction


  // CHECK PHASE

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (exp_q.size() != 0) begin

      `uvm_error( "SB_END", $sformatf( "%0d expected transaction(s) were not matched", exp_q.size() ))
    end

    if (act_q.size() != 0) begin

      `uvm_error("SB_END", $sformatf( "%0d actual transaction(s) were not matched", act_q.size() ) )

    end

  endfunction


  // REPORT PHASE

  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info( "SB_REPORT", $sformatf("WRITE: PASS=%0d FAIL=%0d | READ: PASS=%0d FAIL=%0d", wr_pass, wr_fail, rd_pass, rd_fail ), UVM_LOW)
  endfunction

endclass
