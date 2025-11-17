///////////////////////////////////////////////////////////////////////////
// Copyright 2023 DreamBig Semiconductor, Inc. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of DreamBig Semiconductor Inc.
// All information contained in this document is DreamBig Semiconductor Inc.
// company confidential, proprietary and trade secret.
//
/// Author (name and email): Sohaib Hussain (sohaib.hussain@dreambigsemi.com)
/// Date Created:
/// Description: converter for 16B to 128B
///////////////////////////////////////////////////////////////////////////

module axis_16B_to_128B(

    input  logic          clk_16B,
    input  logic          clk_128B,
    input  logic          rst_n,

    // 16-byte AXIS Slave interface
    input  logic [127:0]  s_axis_tdata,
    input  logic [7:0]    s_axis_tuser, // [7]=sop, [6:0]=byte_count - 1
    input  logic [2:0]    s_axis_tid,
    input  logic          s_axis_tvalid,
    input  logic          s_axis_tlast,
    output logic          s_axis_tready,

    // 128-byte AXIS Master interface
    output logic [1023:0] m_axis_tdata,
    output logic [10:0]   m_axis_tuser, // [10]=sop, [9]=eop, [6:0]=empty
    output logic [2:0]    m_axis_tid,
    output logic          m_axis_tvalid,
    output logic          m_axis_tlast,
    input  logic          m_axis_tready
);

    typedef struct packed {
        logic [1023:0] data;
        logic [10:0]   tuser;
        logic [2:0]    tid;
    } flit128_t;

    flit128_t fifo [0:3];

    logic [1:0] wr_ptr, rd_ptr;
    logic [6:0] valid_bytes;
    logic [6:0] empty_bytes;

    // FIFO status
    wire fifo_full  = ((wr_ptr + 1) % 4) == rd_ptr;
    wire fifo_empty = wr_ptr == rd_ptr;

    // Accumulation
    logic [127:0] flit_buffer [0:7];
    logic [7:0]   flit_tuser  [0:7];
    logic        flit_tlast   [0:7];
    logic [2:0]   flit_tid;
    logic [2:0]  flit_count;
    logic        packet_sop_seen;

    assign s_axis_tready = !fifo_full;

    // ----------------------------------------
    // 16B clock domain (write logic)
    // ----------------------------------------
    always_ff @(posedge clk_16B or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr          <= 0;
            flit_count      <= 0;
            packet_sop_seen <= 0;
            flit_tid        <= 0;
            for (int i = 0; i < 8; i++) begin
                flit_buffer[i] <= 128'd0;
                flit_tuser[i]  <= 8'd0;
                flit_tlast[i]  <= 1'b0;
            end
        end else begin
            if (s_axis_tvalid && s_axis_tready) begin
                // Byte-swap current flit inline (LSByte to MSByte)
                logic [127:0] current_flit_swapped;
                for (int j = 0; j < 16; j++) begin
                    current_flit_swapped[j*8 +: 8] = s_axis_tdata[(15-j)*8 +: 8];
                end

                flit_buffer[flit_count] <= current_flit_swapped;
                flit_tuser[flit_count]  <= s_axis_tuser;
                flit_tlast[flit_count]  <= s_axis_tlast;
                if (flit_count == 0) flit_tid <= s_axis_tid;

                if (s_axis_tuser[7]) packet_sop_seen <= 1;

                if (flit_count == 3'd7 || s_axis_tlast) begin
                    flit128_t temp;

                    for (int i = 0; i < flit_count; i++) begin
                        temp.data[i*128 +: 128] = flit_buffer[i];
                    end
                    temp.data[flit_count*128 +: 128] = current_flit_swapped;
                    for (int i = flit_count + 1; i < 8; i++) begin
                        temp.data[i*128 +: 128] = 128'd0;
                    end

                    valid_bytes = s_axis_tlast ? (flit_count * 16 + s_axis_tuser[6:0] + 1) : 128;
                    empty_bytes = s_axis_tlast ? (128 - valid_bytes) : 7'd0;

                    temp.tuser[10]  = packet_sop_seen;
                    temp.tuser[9]   = s_axis_tlast;
                    temp.tuser[6:0] = empty_bytes;

                    temp.tid = flit_tid;

                    if (!fifo_full) begin
                        fifo[wr_ptr] <= temp;
                        wr_ptr <= wr_ptr + 1;
                    end

                    flit_count      <= 0;
                    packet_sop_seen <= 0;
                    flit_tid        <= 0;
                    for (int i = 0; i < 8; i++) begin
                        flit_buffer[i] <= 128'd0;
                        flit_tuser[i]  <= 8'd0;
                        flit_tlast[i]  <= 1'b0;
                    end
                end else begin
                    flit_count <= flit_count + 1;
                end
            end
        end
    end

    // ----------------------------------------
    // 128B clock domain (read logic)
    // ----------------------------------------
    always_ff @(posedge clk_128B or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr        <= 0;
            m_axis_tvalid <= 0;
            m_axis_tdata  <= 0;
            m_axis_tuser  <= 0;
            m_axis_tid    <= 0;
            m_axis_tlast  <= 0;
        end else begin
            if (!fifo_empty && (!m_axis_tvalid || (m_axis_tvalid && m_axis_tready))) begin
                m_axis_tdata  <= fifo[rd_ptr].data;
                m_axis_tuser  <= fifo[rd_ptr].tuser;
                m_axis_tid    <= fifo[rd_ptr].tid;
                m_axis_tlast  <= fifo[rd_ptr].tuser[9];
                m_axis_tvalid <= 1;
                rd_ptr        <= rd_ptr + 1;
            end else if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 0;
                m_axis_tlast  <= 0;
            end
        end
    end

endmodule

 