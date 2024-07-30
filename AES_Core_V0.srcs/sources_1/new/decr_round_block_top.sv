/***************************************************************
 * File:        decr_round_block_top.sv
 * Module(s):   decr_round_block_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    decr_round_block_top 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/
 
module decr_round_block_top(i_clk, i_rst, i_round_max, i_en_cbc, i_str, i_key_str, o_str, o_ready_for_next, o_done, o_key_addr);
  // clock and reset
  input logic i_clk;
  input logic i_rst;
 
  // configuration
  input logic[3:0] i_round_max;
  input logic i_en_cbc;
 
  // pt, key, ct IO
  input logic[127:0] i_str;
  input logic[127:0] i_key_str;
  output logic[127:0] o_str;
 
  output logic o_ready_for_next;
  output logic o_done;
  output logic[3:0] o_key_addr;
 
  logic[3:0] reg_counter;
 
  logic[7:0] str_in_as_matrix[0:15];
  logic[7:0] key_in_as_matrix[0:15];
  logic[7:0] reg_str_out_as_matrix[0:15];
 
  logic[7:0] reg_ct_in[0:15];
  logic[7:0] decr_block_out[0:15];
  logic[7:0] key_xor_out[0:15];
  logic[7:0] sel_ct_block_out[0:15];
  logic[7:0] sel_cbc_en_out[0:15];
 
  logic disable_mix;
  logic sel_new_ct;
  logic is_initial;
 
  decr_round_block decr_round_block_inst(.i_matrix(key_xor_out), .i_disable_mix(disable_mix), .o_matrix(decr_block_out));
 
  assign sel_new_ct = (reg_counter == i_round_max+1);
  assign o_ready_for_next = sel_new_ct;
  assign disable_mix = (reg_counter == i_round_max);
  assign o_key_addr = reg_counter;
 
  generate
    for(genvar gen_index = 0; gen_index < 16; gen_index++) begin
      // delinearize input plaintext
      assign str_in_as_matrix[gen_index] = i_str[127 - (gen_index * 8) : 120 - (gen_index * 8)];
     
      // delinearize input key
      assign key_in_as_matrix[gen_index] = i_key_str[127 - (gen_index * 8) : 120 - (gen_index * 8)];
     
      // linearize output ciphertext
      assign o_str[127 - (gen_index * 8) : 120 - (gen_index * 8)] = reg_str_out_as_matrix[gen_index];
     
      assign key_xor_out[gen_index] = reg_ct_in[gen_index] ^ key_in_as_matrix[gen_index];
    end
   
    // REMOVE ME!!!!!
    //for(genvar gen_index = 0; gen_index < 15; gen_index++) begin
    //  assign o_str[127 - (gen_index * 8) : 120 - (gen_index * 8)] = reg_str_out_as_matrix[gen_index];
    //end
    //assign o_str[3:0] = reg_counter;
    //assign o_str[7:4] = sel_new_ct;
    // PLEASE!!!!!
  endgenerate
 
  always @(*) begin
    if(sel_new_ct) begin
      sel_ct_block_out = str_in_as_matrix;
    end else begin
      sel_ct_block_out = decr_block_out;
    end
  end
 
  always @(*) begin
    if(i_en_cbc) begin
      for(int i = 0; i < 16; i++) begin
        sel_cbc_en_out[i] = key_xor_out[i] ^ str_in_as_matrix[i];
      end
    end else begin
      sel_cbc_en_out =  key_xor_out;
    end
  end
 
  always @(posedge i_clk) begin
    if(~is_initial) begin
      for(int i = 0; i < 16; i++) begin
        reg_str_out_as_matrix[i] = sel_cbc_en_out[i];
      end
    end else begin
      for(int i = 0; i < 16; i++) begin
        reg_str_out_as_matrix[i] = 8'h00;
      end
    end
  end
 
 
  always @(posedge i_clk) begin
    if(i_rst) begin
      is_initial = 1;
    end else if(disable_mix) begin
      is_initial = 0;
    end
  end
 
  always @(posedge i_clk) begin
    if(~is_initial & (reg_counter == 0)) begin
      o_done = 1;
    end else begin
      o_done = 0;
    end
  end
 
  always @(posedge i_clk) begin
  reg_ct_in = sel_ct_block_out;
  end
 
  always @(posedge i_clk) begin
    if(i_rst | ~(|(reg_counter))) begin
      reg_counter = i_round_max+1;
    end else begin
      reg_counter--;
    end
  end
endmodule