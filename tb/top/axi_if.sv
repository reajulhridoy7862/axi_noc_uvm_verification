interface axi_if(input logic clk, input logic rst_n);

  import axi_pkg::*;

 // logic rst_n;

  // Write Address Channel
  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [LEN_WIDTH-1:0]  awlen;
  logic [SIZE_WIDTH-1:0] awsize;
  logic [1:0]            awburst;
  logic [3:0]            awcache;
  logic                  awlock;
  logic [2:0]            awprot;
  logic [3:0]            awqos;
  logic [3:0]            awregion;
  logic                  awvalid;
  logic                  awready;

  // Write Data Channel
  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wlast;
  logic                  wvalid;
  logic                  wready;

  // Write Response Channel
  logic [ID_WIDTH-1:0] bid;
  logic [1:0]           bresp;
  logic                 bvalid;
  logic                 bready;

  // Read Address Channel
  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [LEN_WIDTH-1:0]  arlen;
  logic [SIZE_WIDTH-1:0] arsize;
  logic [1:0]            arburst;
  logic [3:0]            arcache;
  logic                  arlock;
  logic [2:0]            arprot;
  logic [3:0]            arqos;
  logic [3:0]            arregion;
  logic                  arvalid;
  logic                  arready;

  // Read Data Channel
  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;
  
  initial begin
    // Write address channel
    awid     = '0;
    awaddr   = '0;
    awlen    = '0;
    awsize   = '0;
    awburst  = 2'b01;
    awcache  = 4'b0011;
    awlock   = 1'b0;
    awprot   = 3'b000;
    awqos    = 4'b0000;
    awregion = 4'b0000;
    awvalid  = 1'b0;

    // Write data channel
    wdata  = '0;
    wstrb  = '0;
    wlast  = 1'b0;
    wvalid = 1'b0;

    // Write response channel
    bready = 1'b1;

    // Read address channel
    arid     = '0;
    araddr   = '0;
    arlen    = '0;
    arsize   = '0;
    arburst  = 2'b01;
    arcache  = 4'b0011;
    arlock   = 1'b0;
    arprot   = 3'b000;
    arqos    = 4'b0000;
    arregion = 4'b0000;
    arvalid  = 1'b0;

    // Read response channel
    rready = 1'b1;
  end
endinterface
