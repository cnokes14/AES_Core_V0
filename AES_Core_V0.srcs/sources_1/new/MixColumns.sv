/***************************************************************
 * File:        MixColumns.sv
 * Module(s):   galois_mul_by_two, galois_modulo, mix_columns_encr, mix_columns_decr
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    galois_mul_by_two 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Module 1:    galois_modulo 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Module 2:    mix_columns_encr 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Module 3:    mix_columns_decr 
 * Inputs:      TODO
 * Outputs:     TODO
 ****************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/
module galois_mul_by_two(i_val, o_val);
  input logic[7:0] i_val;
  output logic[7:0] o_val;

  // https://stackoverflow.com/questions/50385144/how-to-expand-a-single-bit-to-multi-bits-depending-on-parameter-in-verilog
  assign o_val = ({i_val[6:0], 1'b0}) ^ ({3'b000, ({5{(i_val[7])}} & 5'h1B)});
endmodule

module galois_modulo(i_byte_extended, o_byte);
  input logic[10:0] i_byte_extended;
  output logic[7:0] o_byte;
 
  logic[9:0] xor_num_one;
  logic[8:0] xor_num_two;
 
  assign xor_num_one = i_byte_extended[9:0] ^ ({10{(i_byte_extended[10])}} & 10'b00_0110_1100);
  assign xor_num_two = xor_num_one[8:0] ^ ({9{(xor_num_one[9])}} & 9'b0_0011_0110);
  assign o_byte = xor_num_two[7:0] ^ ({8{(xor_num_two[8])}} & 8'b0001_1011);
endmodule

module mix_columns_encr(i_word_vector, o_word_vector);
  input logic[7:0] i_word_vector[0:3];
  output logic[7:0] o_word_vector[0:3];
  logic[7:0] m_by_two[0:3];
  logic[7:0] m_by_three[0:3];
 
  generate
    for(genvar gen_index = 0; gen_index < 4; gen_index++) begin : GENERATE_XORS
      galois_mul_by_two mul_two_inst(.i_val(i_word_vector[gen_index]), .o_val(m_by_two[gen_index]));
      assign m_by_three[gen_index] = m_by_two[gen_index] ^ i_word_vector[gen_index];
    end : GENERATE_XORS
  endgenerate
  assign o_word_vector[0] = m_by_two[0] ^ m_by_three[1] ^ i_word_vector[2] ^ i_word_vector[3];
  assign o_word_vector[1] = i_word_vector[0] ^ m_by_two[1] ^ m_by_three[2] ^ i_word_vector[3];
  assign o_word_vector[2] = i_word_vector[0] ^ i_word_vector[1] ^ m_by_two[2] ^ m_by_three[3];
  assign o_word_vector[3] = m_by_three[0] ^ i_word_vector[1] ^ i_word_vector[2] ^ m_by_two[3];
endmodule

module mix_columns_decr(i_word_vector, o_word_vector);
  input logic[7:0] i_word_vector[0:3];
  output logic[7:0] o_word_vector[0:3];
 
  logic[10:0] mul_nine[0:3];
  logic[10:0] mul_eleven[0:3];
  logic[10:0] mul_thirteen[0:3];
  logic[10:0] mul_fourteen[0:3];
 
  logic[7:0] mul_nine_mod[0:3];
  logic[7:0] mul_eleven_mod[0:3];
  logic[7:0] mul_thirteen_mod[0:3];
  logic[7:0] mul_fourteen_mod[0:3];
 
  generate
    for(genvar gen_index = 0; gen_index < 4; gen_index++) begin
      assign mul_nine[gen_index] = {i_word_vector[gen_index], 3'b000} ^ {3'b000, i_word_vector[gen_index]};
      assign mul_eleven[gen_index] = mul_nine[gen_index] ^ {2'b00, i_word_vector[gen_index], 1'b0};
      assign mul_thirteen[gen_index] = mul_nine[gen_index] ^ {1'b0, i_word_vector[gen_index], 2'b00};
      assign mul_fourteen[gen_index] = {i_word_vector[gen_index], 3'b000} ^ {2'b00, i_word_vector[gen_index], 1'b0} ^ {1'b0, i_word_vector[gen_index], 2'b00};
     
      galois_modulo galois_modulo_nine_inst(.i_byte_extended(mul_nine[gen_index]), .o_byte(mul_nine_mod[gen_index]));
      galois_modulo galois_modulo_eleven_inst(.i_byte_extended(mul_eleven[gen_index]), .o_byte(mul_eleven_mod[gen_index]));
      galois_modulo galois_modulo_thirteen_inst(.i_byte_extended(mul_thirteen[gen_index]), .o_byte(mul_thirteen_mod[gen_index]));
      galois_modulo galois_modulo_fourteen_inst(.i_byte_extended(mul_fourteen[gen_index]), .o_byte(mul_fourteen_mod[gen_index]));
    end
   
    assign o_word_vector[0] = mul_fourteen_mod[0] ^ mul_eleven_mod[1] ^ mul_thirteen_mod[2] ^ mul_nine_mod[3];
    assign o_word_vector[1] = mul_nine_mod[0] ^ mul_fourteen_mod[1] ^ mul_eleven_mod[2] ^ mul_thirteen_mod[3];
    assign o_word_vector[2] = mul_thirteen_mod[0] ^ mul_nine_mod[1] ^ mul_fourteen_mod[2] ^ mul_eleven_mod[3];
    assign o_word_vector[3] = mul_eleven_mod[0] ^ mul_thirteen_mod[1] ^ mul_nine_mod[2] ^ mul_fourteen_mod[3];
  endgenerate
endmodule