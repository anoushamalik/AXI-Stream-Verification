class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)
  
  axi_env env;
  axi_sequence test_seq;
  
  //Constructor
  function new(string name = "axi_test", uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env",this);
    test_seq = axi_sequence::type_id::create("test_seq",this);
  endfunction : build_phase
  

  //Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    test_seq.start(env.act_agnt.seqr);
     env.scb.finished.wait_trigger();
    phase.drop_objection(this);
  endtask : run_phase
endclass : axi_test