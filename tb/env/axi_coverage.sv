import axi_pkg::*;

class axi_coverage extends uvm_subscriber #(axi_seq_item);

  `uvm_component_utils(axi_coverage)

  localparam int BYTES    = DATA_WIDTH / 8;
  localparam int MAX_SIZE = $clog2(BYTES);      

  logic [ADDR_WIDTH-1:0] bram0_base = 64'h201_0000_0000;   
  logic [ADDR_WIDTH-1:0] bram0_end  = 64'h201_0001_ffff;
  logic [ADDR_WIDTH-1:0] bram1_base = 64'h201_4000_0000;
  logic [ADDR_WIDTH-1:0] bram1_end  = 64'h201_4001_FFFF;
 
  virtual axi_if vifs [NUM_MASTERS];

  int unsigned         cv_master;
  bit                  cv_is_write;
  bit [LEN_WIDTH-1:0]  cv_len;
  bit [2:0]            cv_size;
  bit [1:0]            cv_burst;
  bit [ID_WIDTH-1:0]   cv_id;
  bit [1:0]            cv_resp;
  int unsigned         cv_region;      
  bit                  cv_addr_valid;

  
  bit          ev_aw, ev_w, ev_b, ev_ar, ev_r, ev_r_last;   
  bit          cv_wlast, cv_rlast;
  int unsigned cv_wr_out, cv_rd_out, cv_aw_before_b, cv_ar_before_r;

  int unsigned wr_out  [NUM_MASTERS];
  int unsigned rd_out  [NUM_MASTERS];
  int unsigned aw_since_b [NUM_MASTERS];   // AW handshakes since the previous B handshake
  int unsigned ar_since_r [NUM_MASTERS];   // AR handshakes since the previous RLAST handshake

  int unsigned num_writes;
  int unsigned num_reads;


  covergroup cg_kind;
    option.per_instance = 1;
    cp_master     : coverpoint cv_master  { bins m[] = {[0:NUM_MASTERS-1]}; }
    cp_write_read : coverpoint cv_is_write { bins WRITE = {1}; bins READ = {0}; }
    x_master_kind : cross cp_master, cp_write_read;
  endgroup

  covergroup cg_write;
    option.per_instance = 1;

    cp_awlen : coverpoint cv_len {
      bins len_0      = {0};
      bins len_1      = {1};
      bins len_2_3    = {[2:3]};
      bins len_4_7    = {[4:7]};
      bins len_8_15   = {[8:15]};
      bins len_16_255 = {[16:255]};
    }

    cp_awburst : coverpoint cv_burst {
      bins FIXED = {0};
      bins INCR  = {1};
      bins WRAP  = {2};
      illegal_bins reserved = {3};
    }

    cp_awid : coverpoint cv_id {
     
      bins id_values[] = {[0:3]};
    }

    cp_bresp : coverpoint cv_resp {
      bins OKAY   = {0};
      bins EXOKAY = {1};
      bins SLVERR = {2};
      bins DECERR = {3};
    }
  endgroup

  covergroup cg_read;
    option.per_instance = 1;

    cp_arlen : coverpoint cv_len {
      bins len_0      = {0};
      bins len_1      = {1};
      bins len_2_3    = {[2:3]};
      bins len_4_7    = {[4:7]};
      bins len_8_15   = {[8:15]};
      bins len_16_255 = {[16:255]};
    }

    cp_arsize : coverpoint cv_size {
      bins sz[] = {[0:MAX_SIZE]};
      illegal_bins over_width = {[MAX_SIZE+1:7]};
    }

    cp_arburst : coverpoint cv_burst {
      bins FIXED = {0};
      bins INCR  = {1};
      bins WRAP  = {2};
      illegal_bins reserved = {3};
    }

    cp_arid : coverpoint cv_id { option.auto_bin_max = 4; }
  endgroup

  // Plan 9: read response, sampled per R beat
  covergroup cg_rresp;
    option.per_instance = 1;
    cp_rresp : coverpoint cv_resp {
      bins OKAY   = {0};
      bins EXOKAY = {1};
      bins SLVERR = {2};
      bins DECERR = {3};
    }
  endgroup

  covergroup cg_burst_type;
    option.per_instance = 1;
    cp_fixed_burst     : coverpoint cv_burst { bins fixed = {0}; }
    cp_increment_burst : coverpoint cv_burst { bins incr  = {1}; }
    cp_wrap_burst      : coverpoint cv_burst { bins wrap  = {2}; }
    cp_kind            : coverpoint cv_is_write { bins WRITE = {1}; bins READ = {0}; }
    cp_burst_kind      : coverpoint cv_burst { bins FIXED = {0}; bins INCR = {1}; bins WRAP = {2}; }
    x_kind_burst       : cross cp_kind, cp_burst_kind;
  endgroup

 /* covergroup cg_address;
    option.per_instance = 1;
    cp_address_range : coverpoint cv_region { bins low = {0}; bins mid = {1}; bins high = {2}; }
    cp_kind          : coverpoint cv_is_write { bins WRITE = {1}; bins READ = {0}; }
    x_kind_range     : cross cp_kind, cp_address_range;
  endgroup
*/

  covergroup cg_address;
    option.per_instance = 1;

    cp_address_range : coverpoint cv_region {
      bins bram0_low    = {0};
      bins bram0_mid    = {1};
      bins bram0_high   = {2};

      bins bram1_low    = {3};
      bins bram1_mid    = {4};
      bins bram1_high   = {5};

      bins invalid      = {6};
    }

    cp_kind : coverpoint cv_is_write {
      bins WRITE = {1};
      bins READ  = {0};
    }

    x_kind_range : cross cp_kind, cp_address_range;

  endgroup


  covergroup cg_channel;
    option.per_instance = 1;

    cp_aw_handshake : coverpoint ev_aw { bins hit = {1}; }
    cp_w_handshake  : coverpoint ev_w  { bins hit = {1}; }
    cp_b_handshake  : coverpoint ev_b  { bins hit = {1}; }
    cp_ar_handshake : coverpoint ev_ar { bins hit = {1}; }
    cp_r_handshake  : coverpoint ev_r  { bins hit = {1}; }

    cp_wlast : coverpoint cv_wlast iff (ev_w) { bins not_last = {0}; bins last = {1}; }
    cp_rlast : coverpoint cv_rlast iff (ev_r) { bins not_last = {0}; bins last = {1}; }

  endgroup

  covergroup cg_outstanding;
    option.per_instance = 1;

    cp_write_outstanding : coverpoint cv_wr_out iff (ev_aw) {
      bins one = {1}; bins two = {2}; bins three_four = {[3:4]}; bins five_plus = {[5:$]};
    }
    cp_read_outstanding : coverpoint cv_rd_out iff (ev_ar) {
      bins one = {1}; bins two = {2}; bins three_four = {[3:4]}; bins five_plus = {[5:$]};
    }

    cp_multiple_aw : coverpoint cv_aw_before_b iff (ev_b) {
      bins single = {1}; bins two = {2}; bins three_four = {[3:4]}; bins five_plus = {[5:$]};
    }
    cp_multiple_ar : coverpoint cv_ar_before_r iff (ev_r_last) {
      bins single = {1}; bins two = {2}; bins three_four = {[3:4]}; bins five_plus = {[5:$]};
    }
  endgroup

  function new(string name = "axi_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_kind        = new();
    cg_write       = new();
    cg_read        = new();
    cg_rresp       = new();
    cg_burst_type  = new();
    cg_address     = new();
    cg_channel     = new();
    cg_outstanding = new();
  endfunction

  function void write(axi_seq_item t);

    if (t.kind == axi_seq_item::AXI_RESET)
      return;

    cv_master = t.master_id;
    if (cv_master >= NUM_MASTERS) begin
      `uvm_error("COV", $sformatf("master_id=%0d is out of range (NUM_MASTERS=%0d)", cv_master, NUM_MASTERS))
      return;
    end

    if (t.kind == axi_seq_item::AXI_WRITE) begin
      cv_is_write   = 1;
      cv_len        = t.awlen;
      cv_size       = t.awsize;
      cv_burst      = t.awburst;
      cv_id         = t.awid;
      cv_resp       = t.bresp;
      cv_region     = classify(t.awaddr);
      cv_addr_valid = (cv_region != 3);

      cg_kind.sample();
      cg_write.sample();
      cg_burst_type.sample();
      cg_address.sample();
      num_writes++;
    end

    else if (t.kind == axi_seq_item::AXI_READ) begin
      cv_is_write   = 0;
      cv_len        = t.arlen;
      cv_size       = t.arsize;
      cv_burst      = t.arburst;
      cv_id         = t.arid;
      cv_region     = classify(t.araddr);
      cv_addr_valid = (cv_region != 6);

      cg_kind.sample();
      cg_read.sample();
      cg_burst_type.sample();
      cg_address.sample();

      foreach (t.rresp_q[i]) begin
        cv_resp = t.rresp_q[i];
        cg_rresp.sample();
      end
      num_reads++;
    end
  endfunction

  function int unsigned classify(logic [ADDR_WIDTH-1:0] a);

    logic [ADDR_WIDTH-1:0] size;
    logic [ADDR_WIDTH-1:0] third;
    logic [ADDR_WIDTH-1:0] off;

    // BRAM0
    if (a >= bram0_base && a <= bram0_end) begin

      size  = bram0_end - bram0_base + 1;
      third = size / 3;
      off   = a - bram0_base;

      if (off < third)
        return 0;  // BRAM0: Low

      if (off < 2 * third)
        return 1;  // BRAM0: Middle

      return 2;    // BRAM0: High
    end

    // BRAM1
    if (a >= bram1_base && a <= bram1_end) begin

      size  = bram1_end - bram1_base + 1;
      third = size / 3;
      off   = a - bram1_base;

      if (off < third)
        return 3;  // BRAM1: Low

      if (off < 2 * third)
        return 4;  // BRAM1: Middle

      return 5;    // BRAM1: High
    end

    //   Invalid address
    return 6;

  endfunction


  /*function int unsigned classify(logic [ADDR_WIDTH-1:0] a);
    logic [ADDR_WIDTH-1:0] size, third, off;

    if (a < mem_base || a > mem_end)
      return 3;

    size  = mem_end - mem_base + 1;
    third = size / 3;
    off   = a - mem_base;

    if (off < third)     return 0;
    if (off < 2 * third) return 1;
    return 2;
  endfunction*/

  task run_phase(uvm_phase phase);

    for (int m = 0; m < NUM_MASTERS; m++) begin
      if (vifs[m] == null)
        `uvm_fatal("COV_NOVIF", $sformatf("vifs[%0d] was not assigned by the env", m))
    end

    for (int m = 0; m < NUM_MASTERS; m++) begin
      fork
        automatic int mi = m;
        sample_master(mi);
      join_none
    end

    wait fork;
  endtask

  task sample_master(int m);
    virtual axi_if v;
    v = vifs[m];

    forever begin
      @(posedge v.clk);

      if (v.rst_n !== 1'b1) begin
        clear_state(m);
        continue;
      end

      ev_aw     = (v.awvalid === 1'b1) && (v.awready === 1'b1);
      ev_w      = (v.wvalid  === 1'b1) && (v.wready  === 1'b1);
      ev_b      = (v.bvalid  === 1'b1) && (v.bready  === 1'b1);
      ev_ar     = (v.arvalid === 1'b1) && (v.arready === 1'b1);
      ev_r      = (v.rvalid  === 1'b1) && (v.rready  === 1'b1);
      ev_r_last = ev_r && (v.rlast === 1'b1);

      cv_wlast = (v.wlast === 1'b1);
      cv_rlast = (v.rlast === 1'b1);

      if (ev_aw) begin wr_out[m]++; aw_since_b[m]++; end
      if (ev_ar) begin rd_out[m]++; ar_since_r[m]++; end

      cv_wr_out      = wr_out[m];
      cv_rd_out      = rd_out[m];
      cv_aw_before_b = aw_since_b[m];
      cv_ar_before_r = ar_since_r[m];

      if (ev_aw || ev_w || ev_b || ev_ar || ev_r) begin
        cg_channel.sample();
        cg_outstanding.sample();
      end

      if (ev_b) begin
        if (wr_out[m] > 0) wr_out[m]--;
        aw_since_b[m] = 0;
      end
      if (ev_r_last) begin
        if (rd_out[m] > 0) rd_out[m]--;
        ar_since_r[m] = 0;
      end
    end
  endtask

  function void clear_state(int m);
    wr_out[m]  = 0;  rd_out[m] = 0;
    aw_since_b[m] = 0;  ar_since_r[m] = 0;
  endfunction

  // Report
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("COV", $sformatf("Sampled %0d writes and %0d reads", num_writes, num_reads), UVM_LOW)
    `uvm_info("COV", $sformatf("cg_kind        : %6.2f%%", cg_kind.get_inst_coverage()),        UVM_LOW)
    `uvm_info("COV", $sformatf("cg_write       : %6.2f%%", cg_write.get_inst_coverage()),       UVM_LOW)
    `uvm_info("COV", $sformatf("cg_read        : %6.2f%%", cg_read.get_inst_coverage()),        UVM_LOW)
    `uvm_info("COV", $sformatf("cg_rresp       : %6.2f%%", cg_rresp.get_inst_coverage()),       UVM_LOW)
    `uvm_info("COV", $sformatf("cg_burst_type  : %6.2f%%", cg_burst_type.get_inst_coverage()),  UVM_LOW)
    `uvm_info("COV", $sformatf("cg_address     : %6.2f%%", cg_address.get_inst_coverage()),     UVM_LOW)
    `uvm_info("COV", $sformatf("cg_channel     : %6.2f%%", cg_channel.get_inst_coverage()),     UVM_LOW)
    `uvm_info("COV", $sformatf("cg_outstanding : %6.2f%%", cg_outstanding.get_inst_coverage()), UVM_LOW)
  endfunction

endclass
