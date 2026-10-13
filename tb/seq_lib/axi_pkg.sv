package axi_pkg;


  //Bus Widths
  localparam  int   ADDR_WIDTH = 64;
  localparam  int   DATA_WIDTH = 64;
  localparam  int   ID_WIDTH   = 2;
  localparam  int   ID_WIDTH_S = 5;
  localparam  int   LEN_WIDTH  = 8;         //AWLEN
  localparam  int   SIZE_WIDTH = 3;         //AWSIZE        
  localparam  int   STRB_WIDTH = DATA_WIDTH / 8;
  localparam  int   AWBURST    = 2;
  localparam  int   NUM_MASTERS = 4;
  localparam int BURST_WIDTH =2;
  localparam int RESP_WIDTH =2;
endpackage
