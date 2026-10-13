import axi_pkg::*;

class axi_read_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_read_sequence)

  logic [ADDR_WIDTH-1:0]  addr;
  logic [ID_WIDTH-1:0]    id; 
  logic [LEN_WIDTH-1:0]   len;

  function new(string name = "axi_read_sequence");
    super.new(name);
  endfunction

  task body();

    axi_seq_item req;
    req = axi_seq_item::type_id::create("req");

    start_item(req);
    
    req.kind = axi_seq_item::AXI_READ;
    req.arid = id; 
    req.araddr = addr;
    req.arlen = len;
    req.arsize = 3'd3;
    req.arburst = 2'b01;
    finish_item(req);

  endtask
   

endclass

