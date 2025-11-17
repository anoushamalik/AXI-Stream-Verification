//Slave Interface
interface axi_slave(input logic clk_16B);
  logic rst_n;
  
  logic [127:0] s_axis_tdata;
  logic [7:0] s_axis_tuser;
  logic [2:0] s_axis_tid;
  logic s_axis_tvalid;
  logic s_axis_tlast;
  logic s_axis_tready;
 
endinterface : axi_slave

//Master Interface
interface axi_master(input logic clk_128B);
  logic rst_n;
  
  logic [1023:0] m_axis_tdata;
  logic [10:0] m_axis_tuser;
  logic [2:0] m_axis_tid;
  logic m_axis_tvalid;
  logic m_axis_tlast;
  logic m_axis_tready;


endinterface : axi_master