
class passive_monitor extends uvm_monitor;
  `uvm_component_utils(passive_monitor)

  uvm_analysis_port#(axi_sequence_item) passive_monitor_port;

  virtual axi_master vif;

  function new(string name="passive_monitor", uvm_component parent=null);
    super.new(name, parent);
    passive_monitor_port = new("passive_monitor_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_master)::get(this, "", "master_vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not found for passive_monitor")
    end
  endfunction

  task run_phase(uvm_phase phase);
    axi_sequence_item tr;
    forever begin
      @(posedge vif.clk_128B);
      
      if (vif.m_axis_tvalid && vif.m_axis_tready) begin
        tr = axi_sequence_item::type_id::create("tr", this);
        tr.m_axis_tid    = vif.m_axis_tid;
        tr.m_axis_tlast  = vif.m_axis_tlast;
        tr.m_axis_tuser  = vif.m_axis_tuser;  
        tr.m_axis_tvalid = 1'b1;
        tr.data_array    = vif.m_axis_tdata;  
        passive_monitor_port.write(tr);
        
        `uvm_info("PASSIVE_MON",$sformatf("Packet sent to scoreboard (master side): TID=%0d, TLAST=%0b, Data=0x%0256h",tr.m_axis_tid, tr.m_axis_tlast, tr.data_array),UVM_HIGH)

      end
    end
  endtask
endclass
