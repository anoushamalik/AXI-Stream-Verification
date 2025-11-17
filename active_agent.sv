class active_agent extends uvm_agent;
  `uvm_component_utils(active_agent)
  
  //Handles
  axi_driver drv;
  axi_sequencer seqr;
  active_monitor act_mon;
  
  function new(string name = "active_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  //Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = axi_driver::type_id::create("drv",this);
    seqr = new("seqr",this);
    act_mon = active_monitor::type_id::create("act_mon",this);
  endfunction : build_phase
  
  //Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
     drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction : connect_phase
  
  
endclass : active_agent