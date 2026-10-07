import axi_pkg::*;

class axi_ref_model extends uvm_subscriber #(axi_seq_item);

  `uvm_component_utils(axi_ref_model)

  localparam logic [1:0] RESP_OKAY  = 2'b00;
  localparam logic [1:0] RESP_DECERR = 2'b11;

  localparam int BYTES = DATA_WIDTH / 8;

  // Expected transaction -> scoreboard
  uvm_analysis_port #(axi_seq_item) exp_port;


  localparam logic [ADDR_WIDTH-1:0] MEM_BASE = 32'h0000_0000;
  localparam logic [ADDR_WIDTH-1:0] MEM_SIZE = 32'h0001_0000;

  logic [31:0] mem [logic [ADDR_WIDTH-1:0]];

  function new(string name = "axi_ref_model",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
  endfunction

  // Main entry point
  function void write(axi_seq_item tr);
    axi_seq_item exp_tr;
    exp_tr = axi_seq_item::type_id::create("exp_tr");

    exp_tr.copy(tr);

    case (exp_tr.kind)
      axi_seq_item::AXI_WRITE:
        model_write(exp_tr);

      axi_seq_item::AXI_READ:
        model_read(exp_tr);

      default:
        `uvm_error( "REF_MODEL", "Unknown AXI transaction type")
    endcase

    // Send expected result to scoreboard
    exp_port.write(exp_tr);

  endfunction


  // ADDRESS DECODE
  function bit is_valid_address(logic [ADDR_WIDTH-1:0] addr);
    return ( addr >= 000 && addr < 111111  );
  endfunction


  // BURST ADDRESS CALCULATION
  function logic [ADDR_WIDTH-1:0] get_beat_address(
    logic [ADDR_WIDTH-1:0] start_addr,
    logic [SIZE_WIDTH-1:0] size,
    logic [LEN_WIDTH-1:0]  len,
    logic [1:0] burst,
    int beat
  );

    int bytes_per_beat;
    int total_bytes;
    logic [ADDR_WIDTH-1:0] aligned_addr;
    logic [ADDR_WIDTH-1:0] wrap_base;


    bytes_per_beat = 1 << size;   //this is equavalent to 2^size

    total_bytes = bytes_per_beat * (len + 1);

    aligned_addr = (start_addr / bytes_per_beat) * bytes_per_beat;


    case (burst)

      // FIXED
      2'b00: begin
        return start_addr;
      end

      // INCR
      2'b01: begin
        if (beat == 0)
          return start_addr;
        return aligned_addr + beat * bytes_per_beat;
      end


      // WRAP
      2'b10: begin
      end
      
      default: begin
        `uvm_error( "REF_MODEL", "Reserved AXI burst type")
        return start_addr;
      end
    endcase
  endfunction


  // WRITE MODEL

  function void model_write(axi_seq_item exp_tr);

    logic [ADDR_WIDTH-1:0] addr;
    logic [ADDR_WIDTH-1:0] byte_addr;

    // Invalid address
    if (!is_valid_address(exp_tr.awaddr)) begin
      exp_tr.bresp = RESP_DECERR; 
      `uvm_info("REF_MODEL", $sformatf( "WRITE: ID=%0d ADDR=%h -> DECERR", exp_tr.awid, exp_tr.awaddr), UVM_MEDIUM)
      return;

    end
    // Process every WDATA beat

    for (int i = 0; i <= exp_tr.awlen; i++) begin
      addr = get_beat_address(
        exp_tr.awaddr,
        exp_tr.awsize,
        exp_tr.awlen,
        exp_tr.awburst,
        i
      );

      // Store only bytes enabled by WSTRB
      for (int b = 0; b < BYTES; b++) begin
        if (exp_tr.wstrb_q[i][b]) begin
          byte_addr = addr + b; 
          mem[byte_addr] = exp_tr.wdata_q[i][8*b +: 8];
        end
      end
    end


    // Successful write

    exp_tr.bresp = RESP_OKAY;
    `uvm_info( "REF_MODEL", $sformatf( "WRITE: ID=%0d ADDR=%h LEN=%0d -> OKAY", exp_tr.awid, exp_tr.awaddr, exp_tr.awlen), UVM_MEDIUM)
  endfunction


  // READ MODEL

  function void model_read( axi_seq_item exp_tr);

    logic [ADDR_WIDTH-1:0] addr;
    logic [ADDR_WIDTH-1:0] byte_addr;

    logic [DATA_WIDTH-1:0] expected_data;

    exp_tr.rdata_q.delete();
    exp_tr.rresp_q.delete();

    if (!is_valid_address(exp_tr.araddr)) begin

      for (int i = 0; i <= exp_tr.arlen; i++) begin

        exp_tr.rdata_q.push_back('0);
        exp_tr.rresp_q.push_back(RESP_DECERR);
      end

      `uvm_info("REF_MODEL", $sformatf( "READ: ID=%0d ADDR=%h -> DECERR", exp_tr.arid, exp_tr.araddr), UVM_MEDIUM)
      return;

    end



    for (int i = 0; i <= exp_tr.arlen; i++) begin
      expected_data = '0;

      addr = get_beat_address(
        exp_tr.araddr,
        exp_tr.arsize,
        exp_tr.arlen,
        exp_tr.arburst,
        i
      );

      for (int b = 0; b < BYTES; b++) begin

        byte_addr = addr + b;
        if (mem.exists(byte_addr)) begin
          expected_data[8*b +: 8] = mem[byte_addr];

        end
        else begin

          // Uninitialized memory = 0
          expected_data[8*b +: 8] = 8'h00;

        end
      end

      exp_tr.rdata_q.push_back(expected_data);
      exp_tr.rresp_q.push_back(RESP_OKAY);

    end

    `uvm_info("REF_MODEL", $sformatf("READ: ID=%0d ADDR=%h LEN=%0d -> OKAY", exp_tr.arid, exp_tr.araddr, exp_tr.arlen ), UVM_MEDIUM )

  endfunction

  // REPORT
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("REF_MODEL", "Reference model completed successfully", UVM_LOW )

  endfunction

endclass
