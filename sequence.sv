
class axi_sequence extends uvm_sequence#(axi_sequence_item);
  `uvm_object_utils(axi_sequence)
  
  int num_packets;
  
  function new(string name = "axi_sequence");
    super.new(name);
  endfunction : new
  
  //Task Body
  task body(); 
    if (!$value$plusargs("num_packets=%d", num_packets)) begin
      $display("No num_packets specified, using default: %0d", num_packets);
    end else begin
      $display("User specified: %0d packets", num_packets);
    end
    $display("Running %0d packets...", num_packets);
    
    repeat (num_packets) 
      begin
      axi_sequence_item trxn;
      trxn = axi_sequence_item::type_id::create("trxn"); 
      start_item(trxn);
      trxn.randomize();
      finish_item(trxn);
    end
  endtask
endclass