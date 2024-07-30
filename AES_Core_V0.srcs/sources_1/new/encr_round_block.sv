/***************************************************************
 * File:        encr_round_block.sv
 * Module(s):   encr_round_block
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    encr_round_block 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/
 
module encr_round_block(i_matrix, i_disable_mix, o_matrix);
  input logic[7:0]  i_matrix[0:15];
  input logic  i_disable_mix;
  output logic[7:0] o_matrix[0:15];
 
  logic[7:0] post_s_box_matrix[0:15];
  logic[7:0] post_shift_matrix[0:15];
  logic[7:0] post_mix_matrix[0:15];
 
  s_box_encr s_box_inst(.i_matrix(i_matrix), .o_matrix(post_s_box_matrix));
  shift_rows_encr shift_rows_inst(.i_matrix(post_s_box_matrix), .o_matrix(post_shift_matrix));
 
  generate
    for(genvar gen_index = 0; gen_index < 16; gen_index+=4) begin
      mix_columns_encr mix_columns_inst(.i_word_vector(post_shift_matrix[gen_index:gen_index+3]), .o_word_vector(post_mix_matrix[gen_index:gen_index+3]));
    end
  endgenerate
 
  always @(*) begin
    if(i_disable_mix) begin
      o_matrix = post_shift_matrix;
    end else begin
      o_matrix = post_mix_matrix;
    end
  end
endmodule