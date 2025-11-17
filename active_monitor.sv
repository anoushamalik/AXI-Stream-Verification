//Active Monitor
class active_monitor extends uvm_monitor;
  `uvm_component_utils(active_monitor)
  
  uvm_analysis_port #(axi_sequence_item) active_monitor_port;
  virtual axi_slave vif;
  
  function new(string name = "active_monitor", uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  //Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    active_monitor_port = new("active_monitor_port",this);
    if(!uvm_config_db#(virtual axi_slave)::get(this, "", "slave_vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not found for active_monitor")
    end
  endfunction : build_phase

  //Run Phase
  task run_phase(uvm_phase phase);
  axi_sequence_item tr;
  axi_sequence_item pkt;
  logic [1023:0] packet_data;
  int flit_count = 0;

  forever begin
    @(posedge vif.clk_16B);
    if (vif.s_axis_tvalid && vif.s_axis_tready) begin
      tr = axi_sequence_item::type_id::create("tr", this);
      tr.s_axis_tdata  = vif.s_axis_tdata;
      tr.s_axis_tuser  = vif.s_axis_tuser;
      tr.s_axis_tid    = vif.s_axis_tid;
      tr.s_axis_tlast  = vif.s_axis_tlast;
      tr.s_axis_tready = vif.s_axis_tready;
      
     `uvm_info("ACT_MON",$sformatf("Captured Flit: tdata=0x%h, tuser=0x%h, tid=%0d, tlast=%0b, tready=%0b", tr.s_axis_tdata, tr.s_axis_tuser,tr.s_axis_tid, tr.s_axis_tlast, tr.s_axis_tready),UVM_HIGH)
     
      packet_data[flit_count*128 +: 128] = tr.s_axis_tdata;
      flit_count++;

      if (tr.s_axis_tlast) begin
      pkt = axi_sequence_item::type_id::create("pkt", this);
      pkt.data_array  = packet_data;
      pkt.s_axis_tid  = tr.s_axis_tid;
      pkt.s_axis_tlast = tr.s_axis_tlast;
      
        active_monitor_port.write(pkt);
        
        `uvm_info("ACT_MON", $sformatf("Packet sent to scoreboard (tid=%0d, tlast=%0b,data=0x%0h)",pkt.s_axis_tid, pkt.s_axis_tlast,pkt.data_array), UVM_LOW)

        flit_count  = 0;
        packet_data = '0;
    end
  end
  end
endtask

endclass : active_monitor