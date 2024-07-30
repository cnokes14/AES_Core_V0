/***************************************************************
 * File:        reg_side_top.sv
 * Module(s):   reg_side_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    reg_side_top 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

// reg-map:
// W0,1,2,3,4,5,6,7 -- key
// W8,9,10,11 -- IV
// W12,13,14,15 -- Misc. setup

module reg_side_top(i_clk, i_rst, i_addr, i_val, i_write_en, o_val,
                o_key, o_iv, o_key_write_en, o_blk_rst, o_expan_blk_rst, o_en_cbc,
                o_in_fifo_rst, o_out_fifo_rst, i_key_done,
                    o_size_key, o_num_rounds,
                    i_fifo_status);
  input logic i_clk;
  input logic i_rst;
  input logic[3:0] i_addr;
  input logic[31:0] i_val;
  input logic i_write_en;
  output logic[31:0] o_val;
 
  output logic[255:0] o_key;
  output logic[127:0] o_iv;
  output logic o_key_write_en;
  output logic o_blk_rst;
  output logic o_expan_blk_rst;
  output logic o_en_cbc;
 
  output logic o_in_fifo_rst;
  output logic o_out_fifo_rst;
 
  input logic i_key_done;
  input logic[3:0] i_fifo_status;
 
  output logic[3:0] o_size_key;
  output logic[3:0] o_num_rounds;
 
  // R12:
  // [20] -- overwrite size + rounds -- w1, self clears
  // [19:16] -- FIFO status -- RO
  // [15]    -- hold dpath in reset -- rw
  // [14:13] -- standard AES version -- rw; 00 - 128, 01 - 192, 10 -- 256, 11 -- custom
  // [12]    -- clear output FIFO -- w1, self clears
  // [11]    -- clear input FIFO -- w1, self clears
  // [10]    -- restart w/ key regen -- w1, self clears
  // [9]     -- restart no key regen -- w1, self clears
  // [8]     -- en_cbc -- rw
  // [7:4]   -- size_key -- rw
  // [3:0]   -- num_rounds -- rw
 
  logic[31:0] mem[0:31];
 
  // 00 -- no reset
  // 01 -- waiting on key to finish
  // 10 -- finished reset, now writing new key
  // 11 -- hold reset on both
  logic[1:0] internal_reset_state;
 
  assign o_key = {mem[0],mem[1],mem[2],mem[3],mem[4],mem[5],mem[6],mem[7]};
  assign o_iv = {mem[8], mem[9], mem[10], mem[11]};
  assign o_en_cbc = mem[12][8];
  assign o_size_key = mem[12][7:4];
  assign o_num_rounds = mem[12][3:0];
  assign o_in_fifo_rst = mem[12][11] | i_rst;
  assign o_out_fifo_rst = mem[12][12] | i_rst;
 
  assign o_blk_rst = |(internal_reset_state);
  assign o_expan_blk_rst = &(internal_reset_state);
  assign o_key_write_en = internal_reset_state[1] & ~internal_reset_state[0];
 
  //
  always @(posedge i_clk) begin
    if(i_rst | mem[12][15] | mem[12][10]) begin
      internal_reset_state = 2'b11;
    end else if(mem[12][9]) begin
     internal_reset_state = 2'b01;
    end else begin
      if(internal_reset_state == 2'b01 & i_key_done) begin
        internal_reset_state = 2'b00;
      end else if(internal_reset_state == 2'b10) begin
        internal_reset_state = 2'b01;
      end else if(internal_reset_state == 2'b11) begin
        internal_reset_state = 2'b10;
      end
    end
  end
 
  // writing to encryption key
  always @(posedge i_clk) begin
    if(i_rst | i_key_done) begin
      for(int i = 0; i < 8; i++) begin
        mem[i] = 32'h00000000;
      end
    end else if(i_write_en & ~i_addr[3]) begin
      mem[i_addr] = i_val;
    end
  end
 
  // writing to IV
  always @(posedge i_clk) begin
    if(i_rst) begin
      for(int i = 8; i < 12; i++) begin
        mem[i] = 32'h00000000;
      end
    end else if(i_write_en & (i_addr[3] & ~i_addr[2])) begin
      mem[i_addr] = i_val;
    end
  end
 
  // reading from memory
  always @(*) begin
    if(&(i_addr[3:2])) begin
      //o_val = 32'habcdabcd;
      o_val = mem[i_addr];
    end else begin
      o_val = 32'h00000000;
    end
  end
 
  // mem[12], config 1
  always @(posedge i_clk) begin
    if(i_rst) begin
      mem[12] = 32'h00000000;
    end else if(i_write_en & &(i_addr == 4'hC)) begin
      //mem[12] = i_val;
      mem[12][31:20] = i_val[31:20];
      mem[12][15:8]  = i_val[15:8];
      if(i_val[20]) begin
        mem[12][7:0] = i_val[7:0];
      end
    end else begin
      if(mem[12][14:13] == 2'b00) begin
        mem[12][3:0] = 4'hA;
        mem[12][7:4] = 4'h4;
      end else if(mem[12][14:13] == 2'b01) begin
        mem[12][3:0] = 4'hC;
        mem[12][7:4] = 4'h6;
      end else if(mem[12][14:13] == 2'b10) begin
        mem[12][3:0] = 4'hE;
        mem[12][7:4] = 4'h8;
      end
      mem[12] = (mem[12] & 32'hFFE0E1FF) | {12'h000, i_fifo_status, 16'h0000};
    end
  end
 
endmodule