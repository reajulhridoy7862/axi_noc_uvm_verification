class axi_monitor extends uvm_monitor;

  `uvm_component_utils(axi_monitor)

  virtual axi_if vif;

  uvm_analysis_port #(axi_seq_item) sb_port;
  uvm_analysis_port #(axi_seq_item) ref_port;

  // Write pipeline
  axi_seq_item aw_queue[$];       
  axi_seq_item w_burst_q[$];      
  axi_seq_item cur_w;             
  axi_seq_item wr_pending [logic [ID_WIDTH-1:0]][$];  

  // Read pipeline
  axi_seq_item rd_pending [logic [ID_WIDTH-1:0]][$];   

  int unsigned num_writes;
  int unsigned num_reads;

  // Constructor
  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sb_port  = new("sb_port",  this);
    ref_port = new("ref_port", this);

    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  // Run phase: ONE process, fixed channel order every cycle
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "INSIDE MONITOR RUN PHASE", UVM_LOW)

    forever begin
      @(posedge vif.clk);

      if (vif.rst_n !== 1'b1) begin
        flush_state();
        continue;
      end

      capture_aw_channel();
      capture_w_channel();
      capture_ar_channel();
      capture_b_channel();  
      capture_r_channel();
    end
  endtask

  // AW
  function void capture_aw_channel();
   axi_seq_item tr;

    if (vif.awvalid && vif.awready) begin
      tr = axi_seq_item::type_id::create("aw_tr");

      tr.kind    = axi_seq_item::AXI_WRITE;
      tr.awid    = vif.awid;
      tr.awaddr  = vif.awaddr;
      tr.awlen   = vif.awlen;
      tr.awsize  = vif.awsize;
      tr.awburst = vif.awburst;

      aw_queue.push_back(tr);

      `uvm_info("MON_AW", $sformatf("AW HANDSHAKE: ID=%0d ADDR=%h LEN=%0d SIZE=%0d BURST=%0d",
                vif.awid, vif.awaddr, vif.awlen, vif.awsize, vif.awburst), UVM_MEDIUM)

      pair_write();
    end
  endfunction

  // W: collect beats until WLAST, then pair with an AW
  function void capture_w_channel();
    if (vif.wvalid && vif.wready) begin

      if (cur_w == null)
        cur_w = axi_seq_item::type_id::create("w_burst");

      cur_w.wdata_q.push_back(vif.wdata);
      cur_w.wstrb_q.push_back(vif.wstrb);

      `uvm_info("MON_W", $sformatf("W HANDSHAKE: DATA=%h STRB=%h WLAST=%0d BEAT=%0d",
                vif.wdata, vif.wstrb, vif.wlast, cur_w.wdata_q.size() - 1), UVM_HIGH)

      if (vif.wlast) begin
        w_burst_q.push_back(cur_w);
        cur_w = null;
        pair_write();
      end
    end
  endfunction

  // Nth AW is matched with Nth W burst (W has no ID in AXI4)
  function void pair_write();
    axi_seq_item aw_tr, w_tr;

    while (aw_queue.size() > 0 && w_burst_q.size() > 0) begin
      aw_tr = aw_queue.pop_front();
      w_tr  = w_burst_q.pop_front();

      if (w_tr.wdata_q.size() != aw_tr.awlen + 1)
        `uvm_error("MON_WLAST",$sformatf("Write ID=%0d ADDR=%h: AWLEN=%0d expects %0d beats, but WLAST came after %0d", aw_tr.awid, aw_tr.awaddr, aw_tr.awlen, aw_tr.awlen + 1, w_tr.wdata_q.size()))

      aw_tr.wdata_q = w_tr.wdata_q;
      aw_tr.wstrb_q = w_tr.wstrb_q;

      wr_pending[aw_tr.awid].push_back(aw_tr);
    end
  endfunction

  // AR
  function void capture_ar_channel();
    axi_seq_item tr;

    if (vif.arvalid && vif.arready) begin
      tr = axi_seq_item::type_id::create("ar_tr");

      tr.kind    = axi_seq_item::AXI_READ;
      tr.arid    = vif.arid;
      tr.araddr  = vif.araddr;
      tr.arlen   = vif.arlen;
      tr.arsize  = vif.arsize;
      tr.arburst = vif.arburst;

      rd_pending[tr.arid].push_back(tr);

      `uvm_info("MON_AR", $sformatf("AR HANDSHAKE: ID=%0d ADDR=%h LEN=%0d SIZE=%0d BURST=%0d",
                vif.arid, vif.araddr, vif.arlen, vif.arsize, vif.arburst), UVM_MEDIUM)
    end
  endfunction

  // B: match by BID (any order), publish the complete write
  function void capture_b_channel();
    axi_seq_item tr;

    if (vif.bvalid && vif.bready) begin

      if (!wr_pending.exists(vif.bid) || wr_pending[vif.bid].size() == 0) begin
        `uvm_error("MON_B", $sformatf("B response for BID=%0d with no matching completed write (AW+W)", vif.bid))
      end
      else begin
        tr = wr_pending[vif.bid].pop_front();       // oldest write with this ID
        if (wr_pending[vif.bid].size() == 0)
          wr_pending.delete(vif.bid);

        tr.bid   = vif.bid;
        tr.bresp = vif.bresp;

        `uvm_info("MON_B", $sformatf("B HANDSHAKE: BID=%0d BRESP=%0d", vif.bid, vif.bresp), UVM_MEDIUM)

        num_writes++;
        send_transaction(tr);
      end
    end
  endfunction

  // R: append beats by RID, publish at RLAST
  function void capture_r_channel();
    axi_seq_item tr;

    if (vif.rvalid && vif.rready) begin

      if (!rd_pending.exists(vif.rid) || rd_pending[vif.rid].size() == 0) begin
        `uvm_error("MON_R", $sformatf("R beat for RID=%0d with no matching AR", vif.rid))
      end
      else begin
        tr = rd_pending[vif.rid][0];                // oldest read with this ID

        tr.rid = vif.rid;
        tr.rdata_q.push_back(vif.rdata);
        tr.rresp_q.push_back(vif.rresp);
        tr.rlast = vif.rlast;

        `uvm_info("MON_R", $sformatf("R HANDSHAKE: RID=%0d DATA=%h RRESP=%0d RLAST=%0d",
                  vif.rid, vif.rdata, vif.rresp, vif.rlast), UVM_HIGH)

        if (vif.rlast) begin
          if (tr.rdata_q.size() != tr.arlen + 1)
            `uvm_error("MON_RLAST", $sformatf("Read ID=%0d ADDR=%h: ARLEN=%0d expects %0d beats, but RLAST came after %0d", tr.arid, tr.araddr, tr.arlen, tr.arlen + 1, tr.rdata_q.size()))

          // Remove it, so the next read with this ID starts clean
          void'(rd_pending[vif.rid].pop_front());
          if (rd_pending[vif.rid].size() == 0)
            rd_pending.delete(vif.rid);

          num_reads++;
          send_transaction(tr);
        end
      end
    end
  endfunction

  // Send to scoreboard + reference model (independent copies)
  function void send_transaction(axi_seq_item tr);

    sb_port.write(tr);
    ref_port.write(tr);

    `uvm_info("MONITOR", $sformatf("Transaction sent to SCOREBOARD and REFERENCE MODEL: kind=%s",
              tr.kind.name()), UVM_MEDIUM)
  endfunction

  // Explicit copy: does not depend on do_copy / field macros in axi_seq_item

  // Reset: drop everything in flight
  function void flush_state();
    aw_queue.delete();
    w_burst_q.delete();
    cur_w = null;
    wr_pending.delete();
    rd_pending.delete();
  endfunction

  // End of test: nothing should be left in flight

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("MONITOR", $sformatf("Completed: %0d writes, %0d reads", num_writes, num_reads), UVM_LOW)
  endfunction

endclass
