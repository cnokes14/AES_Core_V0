/***************************************************************
 * File:        encr_round_block_top.sv
 * Module(s):   encr_round_block_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    encr_round_block_top 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

module encr_round_block_top(i_clk, i_rst, i_round_max, i_en_cbc, i_str, i_key_str, i_iv, o_str, o_ready_for_next, o_done, o_key_addr);
  // clock and reset
  input logic i_clk;
  input logic i_rst;
 
  // configuration
  input logic[3:0] i_round_max;
  input logic i_en_cbc;
 
  // pt, key, ct IO
  input logic[127:0] i_str;
  input logic[127:0] i_key_str;
  input logic[127:0] i_iv; // initialization vector
  output logic[127:0] o_str;
 
  output logic o_ready_for_next;
  output logic o_done;
  output logic[3:0] o_key_addr;
 
  logic[7:0] str_in_as_matrix[0:15];
  logic[7:0] key_in_as_matrix[0:15];
  logic[7:0] reg_str_out_as_matrix[0:15];
  logic[3:0] reg_counter;
 
  logic[7:0] reg_key[0:15];
 
  logic[7:0] matrix_pre_xor[0:15];
  logic[7:0] matrix_to_encr_blk[0:15];
  logic[7:0] matrix_out_encr_blk[0:15];
  logic[7:0] iv_in_as_matrix[0:15]; // incoming IV as a matrix
  logic[7:0] matrix_cbc_vector_sel[0:15]; // incoming IV or outgoing XOR value
  logic[7:0] matrix_cbc_matrix_sel[0:15]; // incoming PT with (1) or without (0) CBC.
  logic[7:0] matrix_cbc_xor[0:15]; // output of IV ^ incoming PT
 
  logic disable_mix;
  logic sel_block_loop;
  logic is_done;
  logic[2:0] reg_push_to_xor_reg = 3'b000;
 
  assign o_key_addr = reg_counter;
  assign sel_block_loop = |(reg_counter); // 0 : take plaintext input; 1 : take input from the encryption block output
  assign o_ready_for_next = ~sel_block_loop; // counter = 0 means we want plaintext input
  assign disable_mix = (i_round_max == 0 || reg_counter == i_round_max);
  assign o_done = reg_push_to_xor_reg[2];
 
  // this block handles the s-box, shift, and mixing steps as needed.
  encr_round_block encr_round_block_inst(.i_matrix(matrix_to_encr_blk), .i_disable_mix(disable_mix), .o_matrix(matrix_out_encr_blk));
 
  generate
    for(genvar gen_index = 0; gen_index < 16; gen_index++) begin
      // delinearize input plaintext
      assign str_in_as_matrix[gen_index] = i_str[127 - (gen_index * 8) : 120 - (gen_index * 8)];
     
      // delinearize input key
      assign key_in_as_matrix[gen_index] = i_key_str[127 - (gen_index * 8) : 120 - (gen_index * 8)];
     
      // delinearize input IV
      assign iv_in_as_matrix[gen_index] = i_iv[127 - (gen_index * 8) : 120 - (gen_index * 8)];
     
      // linearize output ciphertext
      assign o_str[127 - (gen_index * 8) : 120 - (gen_index * 8)] = reg_str_out_as_matrix[gen_index];
     
      // xor result of PT / CT Loopback selection
      assign matrix_to_encr_blk[gen_index] = matrix_pre_xor[gen_index] ^ reg_key[gen_index];
     
      // xor result of CBC and incoming PT
      assign matrix_cbc_xor[gen_index] = matrix_cbc_vector_sel[gen_index] ^ str_in_as_matrix[gen_index];
    end
  endgenerate
 
  // select the initialization vector if that's being used
  always @(*) begin
    if(reg_push_to_xor_reg[1]) begin
      matrix_cbc_vector_sel = matrix_to_encr_blk;
    end else begin
      matrix_cbc_vector_sel = iv_in_as_matrix;
    end
  end
 
  // select the initialization vector if that's being used
  always @(*) begin
    if(i_en_cbc) begin
      matrix_cbc_matrix_sel = matrix_cbc_xor;
    end else begin
      matrix_cbc_matrix_sel = str_in_as_matrix;
    end
  end
 
  // handle counter; increment to round max then loop
  always @(posedge i_clk) begin
    if(i_rst == 1 || reg_counter == i_round_max) begin
      reg_counter = 0;
    end else begin
      reg_counter++;
    end
  end
   
  // if we just finished round 10, in two cycles the output will be done
  always @(posedge i_clk) begin
    if(reg_counter == i_round_max && !i_rst) begin
      reg_push_to_xor_reg[0] <= 1;
    end else begin
      reg_push_to_xor_reg[0] <= 0;
    end
    reg_push_to_xor_reg[1] <= reg_push_to_xor_reg[0];
    reg_push_to_xor_reg[2] <= reg_push_to_xor_reg[1];
  end
   
  // timed register for input key
  always @(posedge i_clk) begin
    reg_key <= key_in_as_matrix;
  end
 
  // timed register for text sent to XOR
  always @(posedge i_clk) begin
    if(sel_block_loop) begin
      matrix_pre_xor <= matrix_out_encr_blk;
    end else begin
      matrix_pre_xor <= matrix_cbc_matrix_sel;
    end
  end
 
  // we only output the result of the XOR when it's done.
  always @(posedge i_clk) begin
    if(reg_push_to_xor_reg[1]) begin
      reg_str_out_as_matrix <= matrix_to_encr_blk;
    end else begin
      reg_str_out_as_matrix <= '{default: 8'h00};
    end
  end
endmodule