//Sequencer Class
class axi_sequencer extends uvm_sequencer#(axi_sequence_item);
  `uvm_component_utils(axi_sequencer)
  
  function new(string name = "axi_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase
    
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase
   
endclass : axi_sequencer