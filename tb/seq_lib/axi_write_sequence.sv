import axi_pkg::*;

class axi_write_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_write_sequence)

  logic [ADDR_WIDTH-1:0]  addr;
  logic [DATA_WIDTH-1:0]  data;
  logic [ID_WIDTH-1:0]    id;
  logic [LEN_WIDTH-1:0]   len;

  function new(string name = "axi_write_sequence");
    super.new(name);
  endfunction

  task body();

    axi_seq_item req;
    req = axi_seq_item::type_id::create("req");

    start_item(req);
    
    req.kind = axi_seq_item::AXI_WRITE;
    req.awid = id;
    req.awaddr = addr;
    req.awlen = len;
    req.awburst = 2'b01; //incremental
    req.awsize = 3'd2;
    req.build_write_data(data);
    finish_item(req);

  endtask
   

endclass

