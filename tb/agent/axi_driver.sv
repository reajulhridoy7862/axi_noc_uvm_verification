
class axi_driver extends uvm_driver#(axi_seq_item);

  //Factory Registration
  `uvm_component_utils(axi_driver)
  virtual axi_if vif;
  axi_seq_item aw_queue[$];
  axi_seq_item w_queue[$];

  axi_seq_item ar_queue[$];
  localparam int READY_TIMEOUT = 100;
  axi_seq_item outstanding_write [logic [ID_WIDTH-1:0]];
  axi_seq_item outstanding_read  [logic [ID_WIDTH-1:0]];
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
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")


  endfunction

 // RUN Phase 

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "INSIDE DRIVER RUN PHASE", UVM_LOW)
    
    forever begin
      seq_item_port.get_next_item(req);

      case(req.kind)

        axi_seq_item::AXI_RESET: begin
          drive_reset();
        end

        axi_seq_item::AXI_WRITE: begin
          fork
            drive_aw(req);
            drive_w(req);
          join
        end
        
       axi_seq_item::AXI_READ: begin
          drive_ar(req);
        end

      endcase
      seq_item_port.item_done();
    end
  endtask
  
  task drive_reset();
    vif.rst_n <= 1'b0;
    @(posedge vif.clk);
    vif.rst_n <=1'b1;
  endtask


  task drive_aw(axi_seq_item req);
    bit aw_handshake = 0;
    vif.awid  <=req.awid;
    vif.awaddr  <= req.awaddr;
    vif.awlen   <= req.awlen;
    vif.awsize    <= req.awsize;
    vif.awburst   <= req.awburst;
    vif.awvalid   <= 1'b1;

    `uvm_info("DRIVER:AW_DRIVE", $sformatf("AWADDR=0x%08h AWID= %0d AWLEN=%0b AW_BURST=%0b AWVALID=%0b",req.awaddr, req.awid, req.awlen, req.awburst, vif.awvalid), UVM_LOW)
    for (int i = 0; i < 100; i++) begin
      @(posedge vif.clk);
      if (vif.awvalid && vif.awready) begin
        aw_handshake = 1;
        break;
      end
    end

    if (aw_handshake != 1)
      `uvm_fatal("AXI_TIMEOUT", "AWREADY was not asserted within 100 clock cycle")
    vif.awvalid <= 1'b0;

  endtask

  task drive_w(axi_seq_item req);
    bit w_handshake = 0;
    
    for (int i=0; i <= req.awlen ; i++) begin
      w_handshake = 0;
      vif.wdata <= req.wdata_q[i];
      vif.wstrb <= req.wstrb;
      vif.wlast <= (i == req.awlen);

      vif.wvalid  <= 1'b1;

      for (int j=0; j <100; j++) begin
        @(posedge vif.clk);
        if (vif.wvalid && vif.wready) begin
          w_handshake = 1;
          break;
        end

      end

      if (w_handshake !=1)
        `uvm_fatal("AXI_TIMEOUT", "WREADY was not asserted within 100 clock cycle")
      vif.wvalid <=1'b0;
    end
  endtask

  task drive_ar(axi_seq_item req);

    bit ar_handshake = 0;
    vif.arid        <= req.arid;
    vif.araddr      <= req.araddr;
    vif.arlen         <= req.arlen;
    vif.arsize        <= req.arsize;
    vif.arburst       <= req.arburst;

    vif.arvalid       <= 1'b1;

    for (int i = 0; i < 100; i++) begin
      @(posedge vif.clk);
      if (vif.arvalid && vif.arready) begin
        ar_handshake = 1;
        break;
      end 
    end 

    if (ar_handshake != 1)
      `uvm_fatal("AXI_TIMEOUT", "ARREADY was not asserted within 100 clock cycle")
    vif.arvalid <= 1'b0;

  endtask

endclass
