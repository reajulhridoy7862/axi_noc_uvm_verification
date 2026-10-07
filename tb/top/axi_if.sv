interface axi_if(input logic clk);
  import axi_pkg::*;

  logic rst_n;

  // Write Address Channel (AW)
  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [LEN_WIDTH-1:0]  awlen;
  logic [SIZE_WIDTH-1:0] awsize;
  logic [1:0]            awburst;
  logic                  awvalid;
  logic                  awready = 1;

  // Write Data Channel (W)
  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wlast;
  logic                  wvalid;
  logic                  wready = 1;

  // Write Response Channel (B)
  logic [ID_WIDTH-1:0]   bid;
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // Read Address Channel (AR)
  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [LEN_WIDTH-1:0]  arlen;
  logic [SIZE_WIDTH-1:0] arsize;
  logic [1:0]            arburst;
  logic                  arvalid;
  logic                  arready = 1;

  // Read Data Channel (R)
  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;

endinterface


