/***************************************************************
 * File:        shift_rows.sv
 * Module(s):   shift_rows_encr, shift_rows_decr
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    shift_rows_encr 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Module 1:    shift_rows_decr 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

module shift_rows_encr(i_matrix, o_matrix);
  input logic[7:0] i_matrix[0:15];
  output logic[7:0] o_matrix[0:15];
 
  assign o_matrix[0] = i_matrix[0];
  assign o_matrix[4] = i_matrix[4];
  assign o_matrix[8] = i_matrix[8];
  assign o_matrix[12] = i_matrix[12];
 
  assign o_matrix[1] = i_matrix[5];
  assign o_matrix[5] = i_matrix[9];
  assign o_matrix[9] = i_matrix[13];
  assign o_matrix[13] = i_matrix[1];
 
  assign o_matrix[2] = i_matrix[10];
  assign o_matrix[6] = i_matrix[14];
  assign o_matrix[10] = i_matrix[2];
  assign o_matrix[14] = i_matrix[6];
 
  assign o_matrix[3] = i_matrix[15];
  assign o_matrix[7] = i_matrix[3];
  assign o_matrix[11] = i_matrix[7];
  assign o_matrix[15] = i_matrix[11];
endmodule

module shift_rows_decr(i_matrix, o_matrix);
  input logic[7:0] i_matrix[0:15];
  output logic[7:0] o_matrix[0:15];
 
  assign o_matrix[0] = i_matrix[0];
  assign o_matrix[4] = i_matrix[4];
  assign o_matrix[8] = i_matrix[8];
  assign o_matrix[12] = i_matrix[12];
 
  assign o_matrix[5] = i_matrix[1];
  assign o_matrix[9] = i_matrix[5];
  assign o_matrix[13] = i_matrix[9];
  assign o_matrix[1] = i_matrix[13];
 
  assign o_matrix[10] = i_matrix[2];
  assign o_matrix[14] = i_matrix[6];
  assign o_matrix[2] = i_matrix[10];
  assign o_matrix[6] = i_matrix[14];

  assign o_matrix[15] = i_matrix[3];
  assign o_matrix[3] = i_matrix[7];
  assign o_matrix[7] = i_matrix[11];
  assign o_matrix[11] = i_matrix[15];
endmodule