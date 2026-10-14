module axi_assertion
  import axi_pkg::*;
#(
  parameter int HANDSHAKE_TIMEOUT   = 1000,   
  parameter bit CHECK_X             = 1'b1    
)(
  input logic                    clk,
  input logic                    rst_n,

  input logic [ID_WIDTH-1:0]     awid,
  input logic [ADDR_WIDTH-1:0]   awaddr,
  input logic [LEN_WIDTH-1:0]    awlen,
  input logic [SIZE_WIDTH-1:0]   awsize,
  input logic [1:0]              awburst,
  input logic                    awvalid,
  input logic                    awready,

  input logic [DATA_WIDTH-1:0]   wdata,
  input logic [DATA_WIDTH/8-1:0] wstrb,
  input logic                    wlast,
  input logic                    wvalid,
  input logic                    wready,

  input logic [ID_WIDTH-1:0]     bid,
  input logic [1:0]              bresp,
  input logic                    bvalid,
  input logic                    bready,

  input logic [ID_WIDTH-1:0]     arid,
  input logic [ADDR_WIDTH-1:0]   araddr,
  input logic [LEN_WIDTH-1:0]    arlen,
  input logic [SIZE_WIDTH-1:0]   arsize,
  input logic [1:0]              arburst,
  input logic                    arvalid,
  input logic                    arready,

  input logic [ID_WIDTH-1:0]     rid,
  input logic [DATA_WIDTH-1:0]   rdata,
  input logic [1:0]              rresp,
  input logic                    rlast,
  input logic                    rvalid,
  input logic                    rready
);

  localparam int MAX_SIZE = $clog2(DATA_WIDTH/8);

  `define AXI_CLK_RST @(posedge clk) disable iff (rst_n !== 1'b1)

  // 1. RESET
  a_rst_valids_low : assert property (
    @(posedge clk)
      (rst_n === 1'b0 && $past(rst_n) === 1'b0)
        |-> !((awvalid === 1'b1) || (wvalid === 1'b1) || (arvalid === 1'b1) ||
              (bvalid  === 1'b1) || (rvalid === 1'b1))
  ) else $error("[%m] A VALID signal is high while reset is asserted");

  // 2. X / Z CHECKS (only after reset)
  generate if (CHECK_X) begin : gen_x_checks

    a_x_aw : assert property (`AXI_CLK_RST
      awvalid |-> !$isunknown({awid, awaddr, awlen, awsize, awburst})
    ) else $error("[%m] X/Z on an AW payload signal while AWVALID is high");

    a_x_w : assert property (`AXI_CLK_RST
      wvalid |-> !$isunknown({wstrb, wlast})
    ) else $error("[%m] X/Z on WSTRB/WLAST while WVALID is high");

    a_x_b : assert property (`AXI_CLK_RST
      bvalid |-> !$isunknown({bid, bresp})
    ) else $error("[%m] X/Z on BID/BRESP while BVALID is high");

    a_x_ar : assert property (`AXI_CLK_RST
      arvalid |-> !$isunknown({arid, araddr, arlen, arsize, arburst})
    ) else $error("[%m] X/Z on an AR payload signal while ARVALID is high");

    a_x_r : assert property (`AXI_CLK_RST
      rvalid |-> !$isunknown({rid, rresp, rlast})
    ) else $error("[%m] X/Z on RID/RRESP/RLAST while RVALID is high");

  end endgenerate

  // 3. HANDSHAKE RULES: VALID held until READY, payload stable meanwhile
  a_aw_valid_held : assert property (`AXI_CLK_RST
    (awvalid && !awready) |=> awvalid
  ) else $error("[%m] AWVALID dropped before AWREADY");

  a_aw_stable : assert property (`AXI_CLK_RST
    (awvalid && !awready) |=> $stable({awid, awaddr, awlen, awsize, awburst})
  ) else $error("[%m] AW payload changed while waiting for AWREADY");

  a_w_valid_held : assert property (`AXI_CLK_RST
    (wvalid && !wready) |=> wvalid
  ) else $error("[%m] WVALID dropped before WREADY");

  a_w_stable : assert property (`AXI_CLK_RST
    (wvalid && !wready) |=> $stable({wdata, wstrb, wlast})
  ) else $error("[%m] W payload changed while waiting for WREADY");

  a_b_valid_held : assert property (`AXI_CLK_RST
    (bvalid && !bready) |=> bvalid
  ) else $error("[%m] BVALID dropped before BREADY");

  a_b_stable : assert property (`AXI_CLK_RST
    (bvalid && !bready) |=> $stable({bid, bresp})
  ) else $error("[%m] B payload changed while waiting for BREADY");

  a_ar_valid_held : assert property (`AXI_CLK_RST
    (arvalid && !arready) |=> arvalid
  ) else $error("[%m] ARVALID dropped before ARREADY");

  a_ar_stable : assert property (`AXI_CLK_RST
    (arvalid && !arready) |=> $stable({arid, araddr, arlen, arsize, arburst})
  ) else $error("[%m] AR payload changed while waiting for ARREADY");

  a_r_valid_held : assert property (`AXI_CLK_RST
    (rvalid && !rready) |=> rvalid
  ) else $error("[%m] RVALID dropped before RREADY");

  a_r_stable : assert property (`AXI_CLK_RST
    (rvalid && !rready) |=> $stable({rid, rdata, rresp, rlast})
  ) else $error("[%m] R payload changed while waiting for RREADY");

  // 4. BURST LEGALITY (write address)
  a_aw_burst_legal : assert property (`AXI_CLK_RST
    awvalid |-> (awburst != 2'b11)
  ) else $error("[%m] AWBURST uses the reserved value 2'b11");

  a_aw_size_legal : assert property (`AXI_CLK_RST
    awvalid |-> (awsize <= MAX_SIZE)
  ) else $error("[%m] AWSIZE is wider than the data bus (DATA_WIDTH=%0d)", DATA_WIDTH);

  a_aw_wrap_len : assert property (`AXI_CLK_RST
    (awvalid && awburst == 2'b10) |-> (awlen inside {1, 3, 7, 15})
  ) else $error("[%m] WRAP burst must have 2, 4, 8 or 16 beats (AWLEN=%0d)", awlen);

  a_aw_fixed_len : assert property (`AXI_CLK_RST
    (awvalid && awburst == 2'b00) |-> (awlen <= 15)
  ) else $error("[%m] FIXED burst longer than 16 beats (AWLEN=%0d)", awlen);

  // 5. BURST LEGALITY (read address)
  a_ar_burst_legal : assert property (`AXI_CLK_RST
    arvalid |-> (arburst != 2'b11)
  ) else $error("[%m] ARBURST uses the reserved value 2'b11");

  a_ar_size_legal : assert property (`AXI_CLK_RST
    arvalid |-> (arsize <= MAX_SIZE)
  ) else $error("[%m] ARSIZE is wider than the data bus (DATA_WIDTH=%0d)", DATA_WIDTH);

  a_ar_wrap_len : assert property (`AXI_CLK_RST
    (arvalid && arburst == 2'b10) |-> (arlen inside {1, 3, 7, 15})
  ) else $error("[%m] WRAP burst must have 2, 4, 8 or 16 beats (ARLEN=%0d)", arlen);

  a_ar_fixed_len : assert property (`AXI_CLK_RST
    (arvalid && arburst == 2'b00) |-> (arlen <= 15)
  ) else $error("[%m] FIXED burst longer than 16 beats (ARLEN=%0d)", arlen);

  int unsigned aw_wait, w_wait, ar_wait, b_wait, r_wait, b_idle, r_idle;

  always @(posedge clk) begin
    if (rst_n != 1'b1) begin
       aw_wait = 0; w_wait = 0; ar_wait = 0; b_wait = 0; r_wait = 0;
     end
     else begin
        aw_wait = ((awvalid === 1'b1) && (awready !== 1'b1)) ? aw_wait + 1 : 0;
        w_wait  = ((wvalid  === 1'b1) && (wready  !== 1'b1)) ? w_wait  + 1 : 0;
        ar_wait = ((arvalid === 1'b1) && (arready !== 1'b1)) ? ar_wait + 1 : 0;
        b_wait  = ((bvalid  === 1'b1) && (bready  !== 1'b1)) ? b_wait  + 1 : 0;
        r_wait  = ((rvalid  === 1'b1) && (rready  !== 1'b1)) ? r_wait  + 1 : 0;

        if (aw_wait == HANDSHAKE_TIMEOUT + 1) $error("[%m] AWREADY not asserted within %0d cycles", HANDSHAKE_TIMEOUT);
        if (w_wait  == HANDSHAKE_TIMEOUT + 1) $error("[%m] WREADY not asserted within %0d cycles",  HANDSHAKE_TIMEOUT);
        if (ar_wait == HANDSHAKE_TIMEOUT + 1) $error("[%m] ARREADY not asserted within %0d cycles", HANDSHAKE_TIMEOUT);
        if (b_wait  == HANDSHAKE_TIMEOUT + 1) $error("[%m] BREADY not asserted within %0d cycles",  HANDSHAKE_TIMEOUT);
        if (r_wait  == HANDSHAKE_TIMEOUT + 1) $error("[%m] RREADY not asserted within %0d cycles",  HANDSHAKE_TIMEOUT);
     end
  end

  `undef AXI_CLK_RST

endmodule

