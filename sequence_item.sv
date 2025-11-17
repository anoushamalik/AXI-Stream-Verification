class axi_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(axi_sequence_item)
  
  rand logic [127:0] s_axis_tdata;
  rand logic [7:0] s_axis_tuser;    
  rand logic [2:0] s_axis_tid;
  rand logic s_axis_tvalid;       
  rand logic s_axis_tlast;
  logic m_axis_tready;
 
  rand logic [1023:0] data_array;
 
  logic [1023:0] m_axis_tdata;
  logic [10:0] m_axis_tuser;
  logic [2:0] m_axis_tid;
  logic m_axis_tvalid;
  logic m_axis_tlast;
  logic s_axis_tready;
  
      
  function new(string name = "axi_sequence_item");
    super.new(name);
  endfunction
  
endclass : axi_sequence_item