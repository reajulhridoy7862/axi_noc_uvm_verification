import axi_pkg::*;

class axi_ref_model extends uvm_subscriber #(axi_seq_item);

  `uvm_component_utils(axi_ref_model)

  localparam logic [1:0] RESP_OKAY   = 2'b00;
  localparam logic [1:0] RESP_DECERR = 2'b11;

  localparam int BYTES = DATA_WIDTH / 8;

  // Expected transaction -> scoreboard
  uvm_analysis_port #(axi_seq_item) exp_port;

  // Address map (inclusive range)
  localparam logic [ADDR_WIDTH-1:0] MEM_BASE = 64'h201_0000_0000;
  localparam logic [ADDR_WIDTH-1:0] MEM_END  = 64'h201_0001_ffff;

  // Byte-addressed memory. Bytes never written read back as 0 (BRAM init is all 0)
  logic [7:0] mem [logic [ADDR_WIDTH-1:0]];

  int unsigned num_writes;
  int unsigned num_reads;
  int unsigned num_decerr;

  function new(string name = "axi_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
  endfunction

  // Main entry point: one completed transaction from the monitor
  function void write(axi_seq_item tr);
    axi_seq_item exp_tr;

    if (tr.kind == axi_seq_item::AXI_RESET) begin
      `uvm_info("REF_MODEL", "Ignoring reset transaction", UVM_MEDIUM)
      return;
    end

    // Explicit copy
    exp_tr = copy_item(tr);

    case (exp_tr.kind)
      axi_seq_item::AXI_WRITE: model_write(exp_tr);
      axi_seq_item::AXI_READ : model_read(exp_tr);
      default: begin
        `uvm_error("REF_MODEL", "Unknown AXI transaction type")
        return;
      end
    endcase

    // Send expected result to scoreboard
    exp_port.write(exp_tr);
  endfunction

  // Field-by-field copy
  function axi_seq_item copy_item(axi_seq_item t);
    axi_seq_item c;
    c = axi_seq_item::type_id::create("exp_tr");

    c.master_id = t.master_id;
    c.kind      = t.kind;

    c.awid      = t.awid;
    c.awaddr    = t.awaddr;
    c.awlen     = t.awlen;
    c.awsize    = t.awsize;
    c.awburst   = t.awburst;
    c.wdata_q   = t.wdata_q;
    c.wstrb_q   = t.wstrb_q;
    c.bid       = t.bid;
    c.bresp     = t.bresp;

    c.arid      = t.arid;
    c.araddr    = t.araddr;
    c.arlen     = t.arlen;
    c.arsize    = t.arsize;
    c.arburst   = t.arburst;
    c.rid       = t.rid;
    c.rdata_q   = t.rdata_q;
    c.rresp_q   = t.rresp_q;
    c.rlast     = t.rlast;

    return c;
  endfunction

  // ADDRESS DECODE (start address of the transaction)
  function bit is_valid_address(logic [ADDR_WIDTH-1:0] addr);
    return (addr >= MEM_BASE && addr <= MEM_END);
  endfunction

  // BURST ADDRESS CALCULATION (FIXED / INCR / WRAP)
  function logic [ADDR_WIDTH-1:0] get_beat_address(
    logic [ADDR_WIDTH-1:0] start_addr,
    logic [SIZE_WIDTH-1:0] size,
    logic [LEN_WIDTH-1:0]  len,
    logic [1:0]            burst,
    int                    beat
  );

    int bytes_per_beat;
    int total_bytes;
    logic [ADDR_WIDTH-1:0] aligned_addr;
    logic [ADDR_WIDTH-1:0] wrap_base;
    logic [ADDR_WIDTH-1:0] offset;

    bytes_per_beat = 1 << size;                   // 2^size
    total_bytes    = bytes_per_beat * (len + 1);
    aligned_addr   = (start_addr / bytes_per_beat) * bytes_per_beat;

    case (burst)

      // FIXED
      2'b00: return start_addr;

      // INCR
      2'b01: begin
        if (beat == 0) return start_addr;
        return aligned_addr + beat * bytes_per_beat;
      end

      // WRAP
      2'b10: begin
        if (beat == 0) return start_addr;
        wrap_base = (start_addr / total_bytes) * total_bytes;
        offset    = (aligned_addr - wrap_base + beat * bytes_per_beat) % total_bytes;
        return wrap_base + offset;
      end

      default: begin
        `uvm_error("REF_MODEL", "Reserved AXI burst type")
        return start_addr;
      end
    endcase
  endfunction

  // WRITE MODEL
  function void model_write(axi_seq_item exp_tr);

    logic [ADDR_WIDTH-1:0] addr;
    logic [ADDR_WIDTH-1:0] base;
    logic [ADDR_WIDTH-1:0] byte_addr;

    // Invalid address: no memory update, expect DECERR
    if (!is_valid_address(exp_tr.awaddr)) begin
      exp_tr.bresp = RESP_DECERR;
      num_decerr++;
      `uvm_info("REF_MODEL", $sformatf("WRITE: ID=%0d ADDR=%h -> DECERR",
                exp_tr.awid, exp_tr.awaddr), UVM_MEDIUM)
      return;
    end

    // Process every WDATA beat
    for (int i = 0; i <= exp_tr.awlen; i++) begin
      if (i >= exp_tr.wdata_q.size()) break;   

      addr = get_beat_address(exp_tr.awaddr, exp_tr.awsize, exp_tr.awlen, exp_tr.awburst, i);
      base = (addr / BYTES) * BYTES;           // start of the bus-width word

      // Store only the bytes enabled by WSTRB
      for (int b = 0; b < BYTES; b++) begin
        if (exp_tr.wstrb_q[i][b]) begin
          byte_addr = base + b;
          mem[byte_addr] = exp_tr.wdata_q[i][8*b +: 8];
        end
      end
    end

    exp_tr.bresp = RESP_OKAY;
    num_writes++;

    `uvm_info("REF_MODEL", $sformatf("WRITE: ID=%0d ADDR=%h LEN=%0d -> OKAY",
              exp_tr.awid, exp_tr.awaddr, exp_tr.awlen), UVM_MEDIUM)
  endfunction

  // READ MODEL
  function void model_read(axi_seq_item exp_tr);

    logic [ADDR_WIDTH-1:0] addr;
    logic [ADDR_WIDTH-1:0] base;
    logic [ADDR_WIDTH-1:0] byte_addr;
    logic [DATA_WIDTH-1:0] expected_data;
    logic [DATA_WIDTH-1:0] dut_data [$];
    int                    bpb;
    int                    lo, hi;

    // Keep the DUT's data: lanes the model cannot predict take the DUT value
    dut_data = exp_tr.rdata_q;

    exp_tr.rdata_q.delete();
    exp_tr.rresp_q.delete();

    // Invalid address: expect DECERR on every beat (data is not checked by the scoreboard)
    if (!is_valid_address(exp_tr.araddr)) begin
      for (int i = 0; i <= exp_tr.arlen; i++) begin
        exp_tr.rdata_q.push_back('0);
        exp_tr.rresp_q.push_back(RESP_DECERR);
      end
      num_decerr++;
      `uvm_info("REF_MODEL", $sformatf("READ: ID=%0d ADDR=%h -> DECERR",
                exp_tr.arid, exp_tr.araddr), UVM_MEDIUM)
      return;
    end

    bpb = 1 << exp_tr.arsize;

    for (int i = 0; i <= exp_tr.arlen; i++) begin

      expected_data = (i < dut_data.size()) ? dut_data[i] : '0;

      addr = get_beat_address(exp_tr.araddr, exp_tr.arsize, exp_tr.arlen, exp_tr.arburst, i);
      base = (addr / BYTES) * BYTES;

      // Byte lanes that carry data in this beat
      lo = addr % BYTES;
      hi = ((addr / bpb) * bpb) % BYTES + bpb - 1;
      if (hi >= BYTES) hi = BYTES - 1;

      for (int b = lo; b <= hi; b++) begin
        byte_addr = base + b;
        if (mem.exists(byte_addr))
          expected_data[8*b +: 8] = mem[byte_addr];
        else
          expected_data[8*b +: 8] = 8'h00;       // uninitialized memory = 0
      end

      exp_tr.rdata_q.push_back(expected_data);
      exp_tr.rresp_q.push_back(RESP_OKAY);
    end

    num_reads++;

    `uvm_info("REF_MODEL", $sformatf("READ: ID=%0d ADDR=%h LEN=%0d -> OKAY",
              exp_tr.arid, exp_tr.araddr, exp_tr.arlen), UVM_MEDIUM)
  endfunction

  // REPORT
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("REF_MODEL", $sformatf("Modeled: %0d writes, %0d reads, %0d decode errors",
              num_writes, num_reads, num_decerr), UVM_LOW)
  endfunction

endclass
