class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  
  //Handles
  active_agent act_agnt;
  passive_agent pas_agnt;
  axi_scoreboard scb;
  
  function new(string name = "axi_env", uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  //Build Phase
  function void build_phase(uvm_phase phase);
    act_agnt = active_agent::type_id::create("act_agnt",this);
    pas_agnt = passive_agent::type_id::create("pas_agnt",this);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "act_agnt", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "pas_agnt", "is_active", UVM_PASSIVE);
    scb = axi_scoreboard::type_id::create("axi_scoreboard",this);
    super.build_phase(phase);
  endfunction : build_phase
  
  //Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    act_agnt.act_mon.active_monitor_port.connect(scb.input_scoreboard_port);
    pas_agnt.pas_mon.passive_monitor_port.connect(scb.output_scoreboard_port);
  endfunction : connect_phase
  
  
endclass : axi_env