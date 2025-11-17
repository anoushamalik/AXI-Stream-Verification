class passive_agent extends uvm_agent;
  `uvm_component_utils(passive_agent)
  
  passive_monitor pas_mon;
  
  function new(string name = "passive_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  //Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pas_mon = passive_monitor::type_id::create("pas_mon",this);
  endfunction : build_phase
  
  //Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase
  
endclass : passive_agent