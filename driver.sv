
class axi_driver extends uvm_driver#(axi_sequence_item);
  `uvm_component_utils(axi_driver)
  
  virtual axi_slave vif;
  
  function new(string name = "axi_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_slave)::get(this, "", "slave_vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not found for axi_driver") 
    end
  endfunction
  
  // Run Phase
  task run_phase(uvm_phase phase);
    axi_sequence_item trxn;
    forever begin
      seq_item_port.get_next_item(trxn);
       wait(vif.rst_n == 1);
      drive_packet(trxn);
      seq_item_port.item_done();
    end
  endtask

  //Drive Task
  task drive_packet(axi_sequence_item trxn);
  logic [127:0] flit_data [8];
  logic [7:0] tuser;
  logic tlast;
  
  for (int i = 0; i < 8; i++) begin
    flit_data[i] = trxn.data_array[i*128 +: 128];
   tuser = (i == 0) ? 8'h8F : 8'h0F;
   tlast = (i == 7);
    
    @(posedge vif.clk_16B);
    vif.s_axis_tvalid <= 1'b1;
    vif.s_axis_tdata  <= flit_data[i];
    vif.s_axis_tuser  <= tuser;
    vif.s_axis_tid    <= trxn.s_axis_tid;
    vif.s_axis_tlast  <= tlast;
    wait(vif.s_axis_tvalid && vif.s_axis_tready);
    `uvm_info("DRV", $sformatf("Flit %0d: SOP=%0b, TLAST=%0b, ValidBytes=%0d, Data=0x%032h",i+1, tuser[7], tlast, tuser[6:0] + 1, flit_data[i]), UVM_HIGH)
  end
    @(posedge vif.clk_16B);
    vif.s_axis_tvalid <= 1'b0;
    vif.s_axis_tlast  <= 1'b0;

endtask
endclass