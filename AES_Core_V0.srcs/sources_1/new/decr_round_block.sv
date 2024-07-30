/***************************************************************
 * File:        decr_round_block.sv
 * Module(s):   decr_round_block
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    decr_round_block 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/
module decr_round_block(i_matrix, i_disable_mix, o_matrix);
  input logic[7:0] i_matrix[0:15];
  input logic i_disable_mix;
  output logic[7:0] o_matrix[0:15];
 
  logic[7:0] post_mix_cols_mat[0:15];
  logic[7:0] pre_shift_rows_mat[0:15];
  logic[7:0] post_shift_rows_mat[0:15];
 
  generate
    for(genvar gen_index = 0; gen_index < 16; gen_index+=4) begin
      mix_columns_decr mix_columns_inst(i_matrix[gen_index +: 4], post_mix_cols_mat[gen_index +: 4]);
    end
  endgenerate
 
  always @(*) begin
    if(i_disable_mix) begin
      pre_shift_rows_mat = i_matrix;
    end else begin
      pre_shift_rows_mat = post_mix_cols_mat;
    end
  end
 
  shift_rows_decr shift_rows_inst(pre_shift_rows_mat, post_shift_rows_mat);
  s_box_decr s_box_inst(post_shift_rows_mat, o_matrix);
endmodule