`timescale 1ns/1ps;

import uvm_pkg::*;
   `include "uvm_macros.svh";

//Include Files
`include "interface.sv";
`include "sequence_item.sv";
`include "sequence.sv";
`include "sequencer.sv";
`include "driver.sv";
`include "active_monitor.sv";
`include "passive_monitor.sv";
`include "active_agent.sv";
`include "passive_agent.sv";
`include "scoreboard.sv";
`include "env.sv";
`include "test.sv"

//Top Module
module top();
  
  logic clk_16B;
  logic clk_128B;
  logic rst_n;
  
  assign s_intf.rst_n = rst_n;
  assign m_intf.rst_n = rst_n;
  
  axi_slave s_intf(.clk_16B(clk_16B));
  axi_master m_intf(.clk_128B(clk_128B));
    
  axis_16B_to_128B dut(
    .clk_16B(s_intf.clk_16B),
    .clk_128B(m_intf.clk_128B),
    .rst_n(rst_n),
    .s_axis_tdata(s_intf.s_axis_tdata),
    .s_axis_tuser(s_intf.s_axis_tuser),
    .s_axis_tid(s_intf.s_axis_tid),
    .s_axis_tvalid(s_intf.s_axis_tvalid),
    .s_axis_tlast(s_intf.s_axis_tlast),
    .m_axis_tready(m_intf.m_axis_tready),
    .m_axis_tdata(m_intf.m_axis_tdata),
    .m_axis_tuser(m_intf.m_axis_tuser),
    .m_axis_tid(m_intf.m_axis_tid),
    .m_axis_tvalid(m_intf.m_axis_tvalid),
    .m_axis_tlast(m_intf.m_axis_tlast),
    .s_axis_tready(s_intf.s_axis_tready)
  );
  
  initial begin
    uvm_config_db#(virtual axi_slave)::set(null,"*","slave_vif",s_intf); 
    uvm_config_db#(virtual axi_master)::set(null,"*","master_vif",m_intf);
    run_test("axi_test");
  end
  
  //Clock Generation
  initial begin
   clk_16B = 0;
    #5;
    forever begin
    #5;
      clk_16B = ~clk_16B;
    end
  end
    
   initial begin
     clk_128B = 0;
     #5
      forever begin
        #40;
      clk_128B = ~clk_128B;
      end
   end
  
  initial begin
    rst_n = 0;
    #100;
    rst_n = 1;
  end
  
  initial begin
    $dumpfile("axi.vcd"); 
    $dumpvars();
  end

  always @(posedge clk_128B or negedge rst_n) begin
    if (!rst_n) begin
      m_intf.m_axis_tready <= 1'b0;
    end else begin
      m_intf.m_axis_tready <= 1'b1; 
    end
  end
 
endmodule : top