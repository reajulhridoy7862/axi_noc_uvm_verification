import axi_pkg::*;
class axi_driver extends uvm_driver #(axi_seq_item);

  `uvm_component_utils(axi_driver)

  virtual axi_if vif;

  localparam int READY_TIMEOUT = 100;  
  localparam int RESET_CYCLES  = 3;

  // Queues between coordinator and channel threads
  axi_seq_item aw_queue[$];
  axi_seq_item w_queue [$];
  axi_seq_item ar_queue[$];

  // Outstanding transactions: one queue per ID (same-ID responses are in order)
  axi_seq_item outstanding_write [logic [ID_WIDTH-1:0]][$];
  axi_seq_item outstanding_read  [logic [ID_WIDTH-1:0]][$];

  // Pending counts (accepted from sequencer, response not yet fully received)
  int pending_wr;
  int pending_rd;

  uvm_phase run_ph;

  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    run_ph = phase;
    init_signals();

    fork
      coordinator();
      aw_thread();
      w_thread();
      ar_thread();
      b_thread();
      r_thread();
    join
  endtask

  task init_signals();
    vif.awvalid <= 1'b0;
    vif.wvalid  <= 1'b0;
    vif.wlast   <= 1'b0;
    vif.arvalid <= 1'b0;
    vif.bready  <= 1'b1;   
    vif.rready  <= 1'b1;
  endtask

  // Coordinator: sequencer -> queues (zero time)
  task coordinator();
    axi_seq_item req;

    forever begin
      seq_item_port.get_next_item(req);

      case (req.kind)

        axi_seq_item::AXI_RESET: begin
          drive_reset();
        end

        axi_seq_item::AXI_WRITE: begin
          pending_wr++;
          run_ph.raise_objection(this, "write pending");
          aw_queue.push_back(req);
          w_queue.push_back(req);
          `uvm_info("AXI_WRITE", "Applying AXI WRITE", UVM_LOW)
        end

        axi_seq_item::AXI_READ: begin
          pending_rd++;
          run_ph.raise_objection(this, "read pending");
          ar_queue.push_back(req);
          `uvm_info("AXI_READ", "Applying AXI read", UVM_LOW)
        end

        default: `uvm_error("AXI_DRIVER", "Unknown transaction type")
      endcase

      seq_item_port.item_done();
    end
  endtask

  // AW channel
  task aw_thread();
    axi_seq_item req;
    bit handshake;


    forever begin
      wait (aw_queue.size() > 0);
      @(posedge vif.clk);
      
      req = aw_queue.pop_front();
      handshake = 0;
      
      `uvm_info("AXI_AW", $sformatf("Driving AW: ID=%0d ADDR=%h LEN=%0d", req.awid, req.awaddr, req.awlen), UVM_LOW)
      vif.awid    <= req.awid;
      vif.awaddr  <= req.awaddr;
      vif.awlen   <= req.awlen;
      vif.awsize  <= req.awsize;
      vif.awburst <= req.awburst;
      vif.awvalid <= 1'b1;

      for (int i = 0; i < READY_TIMEOUT; i++) begin
        @(posedge vif.clk);
        if (vif.awvalid && vif.awready) begin
          handshake = 1;
          break;
        end
      end

      if (!handshake)
        `uvm_fatal("AXI_AW_TIMEOUT", $sformatf("AWREADY not asserted within %0d cycles", READY_TIMEOUT))

      vif.awvalid <= 1'b0;

      outstanding_write[req.awid].push_back(req);

      `uvm_info("AXI_AW", $sformatf("AW handshake: ID=%0d ADDR=%h LEN=%0d", req.awid, req.awaddr, req.awlen), UVM_LOW)
    end
  endtask

  // W channel (runs independently of AW)
  task w_thread();
    axi_seq_item req;
    bit handshake;

    forever begin
      wait (w_queue.size() > 0);
      @(posedge vif.clk);
      
      req = w_queue.pop_front();

      for (int i = 0; i <= req.awlen; i++) begin   // AWLEN+1 beats
        handshake = 0;

        `uvm_info("AXI_W", $sformatf("W beat: ID=%0d beats=%0d wdata=%0h wlast=%0b", req.awid, i, req.wdata_q[i], (i== req.awlen)), UVM_LOW)

        vif.wdata  <= req.wdata_q[i];
        vif.wstrb  <= req.wstrb_q[i];
        vif.wlast  <= (i == req.awlen);
        vif.wvalid <= 1'b1;

        for (int j = 0; j < READY_TIMEOUT; j++) begin
          @(posedge vif.clk);
          if (vif.wvalid && vif.wready) begin
            handshake = 1;
            break;
          end
        end

        if (!handshake)
          `uvm_fatal("AXI_W_TIMEOUT", $sformatf("WREADY not asserted within %0d cycles", READY_TIMEOUT))

        vif.wvalid <= 1'b0;   
      end

      vif.wlast <= 1'b0;

      `uvm_info("AXI_W", $sformatf("W burst done: ID=%0d beats=%0d", req.awid, req.awlen + 1), UVM_LOW)
    end
  endtask

  // AR channel
  task ar_thread();
    axi_seq_item req;
    bit handshake;

    forever begin
      wait (ar_queue.size() > 0);
      @(posedge vif.clk);
      
      req = ar_queue.pop_front();
      handshake = 0;

      vif.arid    <= req.arid;
      vif.araddr  <= req.araddr;
      vif.arlen   <= req.arlen;
      vif.arsize  <= req.arsize;
      vif.arburst <= req.arburst;
      vif.arvalid <= 1'b1;
      `uvm_info("AXI_AR", $sformatf("DRIVING AR: ID=%0d ADDR=%h LEN=%0d", req.arid, req.araddr, req.arlen), UVM_LOW)

      for (int i = 0; i < READY_TIMEOUT; i++) begin
        @(posedge vif.clk);
        if (vif.arvalid && vif.arready) begin
          handshake = 1;
          break;
        end
      end

      if (!handshake)
        `uvm_fatal("AXI_AR_TIMEOUT", $sformatf("ARREADY not asserted within %0d cycles", READY_TIMEOUT))

      vif.arvalid <= 1'b0;

      outstanding_read[req.arid].push_back(req);

      `uvm_info("AXI_AR", $sformatf("AR handshake DONE: ID=%0d ADDR=%h LEN=%0d", req.arid, req.araddr, req.arlen), UVM_MEDIUM)
    end
  endtask

  // B channel: matches responses by BID, any order
  task b_thread();
    axi_seq_item req;

    forever begin
      
      @(posedge vif.clk);                       // a clock edge every iteration
      
      if (vif.rst_n && vif.bvalid && vif.bready) begin

        if (!outstanding_write.exists(vif.bid) || outstanding_write[vif.bid].size() == 0) begin
          `uvm_error("AXI_B", $sformatf("Unexpected BID=%0d", vif.bid))
        end
        else begin
          req       = outstanding_write[vif.bid].pop_front();
          req.bid   = vif.bid;
          req.bresp = vif.bresp;

          if (outstanding_write[vif.bid].size() == 0)
            outstanding_write.delete(vif.bid);

          `uvm_info("AXI_B", $sformatf("B response: BID=%0d BRESP=%0d",
                    vif.bid, vif.bresp), UVM_MEDIUM)

          pending_wr--;
          run_ph.drop_objection(this, "write complete");
        end
      end
    end
  endtask

  // R channel: matches beats by RID, interleaving allowed
  task r_thread();
    axi_seq_item req;

    forever begin
      @(posedge vif.clk);       

      if (vif.rst_n && vif.rvalid && vif.rready) begin

        if (!outstanding_read.exists(vif.rid) || outstanding_read[vif.rid].size() == 0) begin
          `uvm_error("AXI_R", $sformatf("Unexpected RID=%0d", vif.rid))
        end
        else begin
          req = outstanding_read[vif.rid][0];   // oldest transaction for this ID
          req.rid = vif.rid;
          req.rdata_q.push_back(vif.rdata);
          req.rresp_q.push_back(vif.rresp);
          req.rlast = vif.rlast;

          `uvm_info("AXI_R", $sformatf("R beat: RID=%0d DATA=%h RLAST=%0d",
                    vif.rid, vif.rdata, vif.rlast), UVM_HIGH)

          if (vif.rlast) begin
            void'(outstanding_read[vif.rid].pop_front());
            if (outstanding_read[vif.rid].size() == 0)
              outstanding_read.delete(vif.rid);

            pending_rd--;
            run_ph.drop_objection(this, "read complete");
          end
        end
      end
    end
  endtask

  // Reset: hold several cycles, flush driver state
  task drive_reset();
    `uvm_info("AXI_RESET", "Applying AXI reset", UVM_LOW)

    vif.rst_n <= 1'b0;
    repeat (RESET_CYCLES) @(posedge vif.clk);
    vif.rst_n <= 1'b1;
    `uvm_info("AXI_RESET", "release AXI reset", UVM_LOW)
    // Drop objections for anything that was still pending, then clear state
    if (pending_wr + pending_rd > 0)
      run_ph.drop_objection(this, "reset flush", pending_wr + pending_rd);

    pending_wr = 0;
    pending_rd = 0;
    aw_queue.delete();
    w_queue.delete();
    ar_queue.delete();
    outstanding_write.delete();
    outstanding_read.delete();
  endtask

endclass
