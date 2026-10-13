import axi_pkg::*;
class axi_seq_item extends uvm_sequence_item;

  `uvm_object_utils(axi_seq_item)
  typedef enum {AXI_RESET, AXI_WRITE, AXI_READ} trans_kind;

  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  trans_kind                    kind;
  logic rst_n;
  int unsigned                  master_id;

  //aw channel
  rand logic [ID_WIDTH-1:0]     awid;
  rand logic [ADDR_WIDTH-1:0]   awaddr;
  rand logic [LEN_WIDTH-1:0]    awlen;
  rand logic [SIZE_WIDTH-1:0]   awsize;
  rand logic [1:0]              awburst;

  //write data
  rand logic [DATA_WIDTH-1:0]   wdata_q[$];
  rand logic [STRB_WIDTH-1:0]   wstrb_q[$];
  logic                         wlast;
  
  //write response
  logic [ID_WIDTH-1:0]          bid;
  logic [1:0]                   bresp;

  //read address
  rand logic [ID_WIDTH-1:0]     arid;
  rand logic [ADDR_WIDTH-1:0]   araddr;
  rand logic [LEN_WIDTH-1:0]    arlen;
  rand logic [SIZE_WIDTH-1:0]   arsize;
  rand logic [1:0]              arburst;

  //read data
  logic [DATA_WIDTH-1:0]        rdata_q[$];
  logic [1:0]                   rresp_q[$];
  logic [ID_WIDTH-1:0]          rid;
  logic                         rlast;  



     
  function void build_write_data(logic [31:0] base_data);
     int i;
     int num_beats;
     wdata_q.delete();
     wstrb_q.delete();
     num_beats = awlen + 1;

     for (i = 0; i < num_beats; i++) begin
       wdata_q.push_back(base_data + i);
      wstrb_q.push_back({STRB_WIDTH{1'b1}}); 
     end 

  endfunction

  function int get_write_beats();
    return awlen+1;
  endfunction

  function int get_read_beats();
    return arlen+1;
  endfunction


endclass
