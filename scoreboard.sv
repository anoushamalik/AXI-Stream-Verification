`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)
  
  // Ports
  uvm_analysis_imp_input #(axi_sequence_item, axi_scoreboard) input_scoreboard_port;
  uvm_analysis_imp_output #(axi_sequence_item, axi_scoreboard) output_scoreboard_port;
  
  axi_sequence_item temp_queue[$];    
  axi_sequence_item expected_queue[$]; 
  axi_sequence_item actual_queue[$];  
  
  // Counters
  int packets_compared = 0;
  int packets_passed   = 0;
  int packets_failed   = 0;

  uvm_event finished;
  
  int expected_packet = 0;    
  int temp_packet= 0; 
  int actual_packet = 0;
  
  // Constructor
  function new(string name="axi_scoreboard", uvm_component parent);
    super.new(name, parent);
    finished = new("finished");
  endfunction

  // Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    input_scoreboard_port  = new("input_scoreboard_port", this);
    output_scoreboard_port = new("output_scoreboard_port", this);
  endfunction
  
   // Write Function
  function void write_input(axi_sequence_item item);
    axi_sequence_item input_item;
    temp_packet++;
    `uvm_info("SCB_INPUT", $sformatf("Received 128 Bytes active packet %0d/%0d - TID=%0d, Data=0x%064h", temp_packet, expected_packet,item.s_axis_tid, item.data_array), UVM_HIGH)
    input_item = axi_sequence_item::type_id::create("input_item");
    input_item.s_axis_tid = item.s_axis_tid;
    input_item.data_array = item.data_array;
    temp_queue.push_back(input_item);
    store_expected();
    check(); 
  endfunction

  function void write_output(axi_sequence_item item);
    axi_sequence_item output_item;
    actual_packet++;
    `uvm_info("SCB", $sformatf("Received 128B passive packet %0d/%0d - TID=%0d, Data=0x%0256h",actual_packet,expected_packet, item.m_axis_tid,item.data_array),UVM_HIGH)
    output_item = axi_sequence_item::type_id::create("output_item");
    output_item.m_axis_tid = item.m_axis_tid;
    output_item.data_array = item.data_array;
    actual_queue.push_back(output_item);
    compare();
    check();
  endfunction
  
  
  //Store Expected Data
    function void store_expected();
    axi_sequence_item active_pkt, expected_pkt;
    logic [1023:0] expected_data;
    logic [127:0] input_chunk_16B, reversed_chunk_16B;
      if (temp_queue.size() == 0) 
      return;
    active_pkt = temp_queue.pop_front();
    
    `uvm_info("SCB", $sformatf("Processing active packet - TID=%0d", active_pkt.s_axis_tid), UVM_HIGH)
    `uvm_info("SCB_DEBUG", $sformatf("Active packet data: 0x%0256h", active_pkt.data_array), UVM_HIGH)
    
    for (int chunk = 0; chunk < 8; chunk++) begin
      input_chunk_16B    = active_pkt.data_array[chunk*128 +: 128];
      reversed_chunk_16B = byte_reverse_16B(input_chunk_16B);
      expected_data[chunk*128 +: 128] = reversed_chunk_16B;
    end
    
    expected_pkt = axi_sequence_item::type_id::create("expected_pkt");
    expected_pkt.s_axis_tid = active_pkt.s_axis_tid;
    expected_pkt.data_array = expected_data; 
    expected_queue.push_back(expected_pkt);
    
      `uvm_info("SCB", $sformatf("Expected packet created and queued - TID=%0d, DATA=0x%0256h", expected_pkt.s_axis_tid,expected_pkt.data_array), UVM_HIGH)
    compare();
  endfunction

 // Byte reverse
  function logic [127:0] byte_reverse_16B(logic [127:0] input_chunk);
    logic [127:0] reversed_chunk;
    for (int byte_idx = 0; byte_idx < 16; byte_idx++) begin
      reversed_chunk[byte_idx*8 +: 8] = input_chunk[(15-byte_idx)*8 +: 8];
    end
    return reversed_chunk;
  endfunction

   //Check Function
  function void check();
    if (temp_packet >= expected_packet && 
        actual_packet >= expected_packet &&
        packets_compared >= expected_packet &&
        expected_queue.size() == 0 && 
        actual_queue.size() == 0) begin
        
      `uvm_info("SCB_COMPLETE", $sformatf("All %0d packets processed successfully!", expected_packet), UVM_HIGH)
      `uvm_info("SCB_COMPLETE", $sformatf("Final stats - Passed: %0d, Failed: %0d", packets_passed, packets_failed), UVM_HIGH)
      finished.trigger();
    end
  endfunction
  
  // Compare packets
  function void compare();
    axi_sequence_item expected_pkt, actual_pkt;
    bit match = 1;
    if (expected_queue.size() == 0 || actual_queue.size() == 0) begin
      `uvm_info("SCB_DEBUG", $sformatf("Waiting for packets: Expected=%0d, Actual=%0d",expected_queue.size(), actual_queue.size()), UVM_HIGH)
      return;
    end
    expected_pkt = expected_queue.pop_front();
    actual_pkt   = actual_queue.pop_front();
    packets_compared++;
    
    `uvm_info("SCB", $sformatf("=== Comparing Packet %0d ===", packets_compared), UVM_HIGH)
    `uvm_info("SCB", $sformatf("Expected TID=%0d, Actual TID=%0d", expected_pkt.s_axis_tid, actual_pkt.m_axis_tid), UVM_HIGH)
    if (expected_pkt.data_array !== actual_pkt.data_array) begin
      match = 0;
      `uvm_error("SCB", $sformatf("Data mismatch: Expected=0x%0256h, Actual=0x%0256h",expected_pkt.data_array, actual_pkt.data_array))
    end
    if (match) begin
      packets_passed++;
      `uvm_info("SCB", $sformatf("Packet %0d comparison PASSED", packets_compared), UVM_HIGH)
    end else begin
      packets_failed++;
      `uvm_error("SCB", $sformatf("Packet %0d comparison FAILED", packets_compared))
    end
    if (expected_queue.size() > 0 && actual_queue.size() > 0) begin
      compare();
    end
  endfunction
  

//Report Phase
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_REPORT", $sformatf("Simulation Complete: Correct: %0d, Errors: %0d", packets_passed, packets_failed), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("Remaining Queues: Expected_queue: %0d, Actual_queue: %0d",expected_queue.size(), actual_queue.size()), UVM_LOW)
  endfunction
  
endclass : axi_scoreboard