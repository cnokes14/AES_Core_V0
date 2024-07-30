/***************************************************************
 * File:        encr_path_top.sv
 * Module(s):   encr_path_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: Encryption path of an AES core, including FIFOs,
 *                  the register map, and key expansion.
 ***************************************************************
 * Module 0:    decr_path_top 
 * Inputs:      i_clk---------------logic-----------Clock; used on positive edge only.
 *              i_rst---------------logic-----------Active high reset. Sets all used registers to 'h0.
 *              i_write_fifo_en-----logic-----------When '1', write i_data to the input FIFO on the rising clock edge.
 *              i_data--------------logic[127:0]----Data for input FIFO.
 *              i_reg_addr----------logic[3:0]------Register to address; reg space includes key, IV, and configuration
 *              i_reg_val-----------logic[31:0]-----Value to write to the register map.
 *              i_reg_write_en------logic-----------When '1', write i_reg_val to the register map.
 *              i_read_next---------logic-----------When '1', on a rising clock edge, pop the top value of the output FIFO.
 * Outputs:     o_data--------------logic[127:0]----Value of the output FIFO. Valid until the rising clock edge when i_read_next='1'
 *              o_reg_val-----------logic[31:0]-----Current data of reg[i_reg_addr]. Some values (key, IV, etc.) cannot be read.
 ****************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/
 
module encr_path_top(i_clk, i_rst, i_write_fifo_en, i_data, i_reg_addr, i_reg_val, i_reg_write_en, i_read_next, o_data, o_reg_val);
  input logic i_clk;
  input logic i_rst;
  input logic i_write_fifo_en;
  input logic[127:0] i_data;
  input logic[3:0] i_reg_addr;
  input logic[31:0] i_reg_val;
  input logic i_reg_write_en;
  input logic i_read_next;
  output logic[127:0] o_data;
  output logic[31:0] o_reg_val;
 
  logic rst_input_fifo;
  logic rst_output_fifo;
  logic encr_block_ready;
  logic[127:0] pt_from_fifo;
 
  logic overflow_input_fifo;
  logic underflow_input_fifo;
  logic overflow_output_fifo;
  logic underflow_output_fifo;
  logic[255:0] key_in_reg;
  logic[127:0] iv_in_reg;
  logic key_write_en;
  logic encr_block_rst;
  logic expan_block_rst;
  logic en_cbc;
  logic key_done;
  logic[3:0] size_key;
  logic[3:0] num_rounds;
  logic[3:0] key_addr;
  logic[127:0] expanded_key;
 
  logic[3:0] fifo_status;
 
  logic write_output_fifo_en;
  logic[127:0] ct_to_fifo;
 
  logic input_fifo_state;
  always @(posedge i_clk) begin
    if(encr_block_rst) begin
      input_fifo_state <= 1'b0;
    end if(~encr_block_rst & ~encr_block_ready) begin
      input_fifo_state <= 1'b1;
    end
  end
 
  assign fifo_status = {overflow_input_fifo, underflow_input_fifo, overflow_output_fifo, underflow_output_fifo};
  //assign o_data = input_fifo_state;
  /*
  input_fifo(i_clk, i_rst, i_write_en, i_goto_next, i_val, o_val, o_overflow_error, o_underflow_error);
  reg_side_top(i_clk, i_rst, i_addr, i_val, i_write_en, o_val,
               o_key, o_iv, o_key_write_en, o_blk_rst, o_expan_blk_rst, o_en_cbc,
               o_in_fifo_rst, o_out_fifo_rst, i_key_done,
               o_size_key, o_num_rounds);
  key_expand_top(i_clk, i_rst, i_key, i_write_en, i_addr, i_key_len, i_num_rounds, o_key_val, o_key_done);
  encr_round_block_top(i_clk, i_rst, i_round_max, i_en_cbc, i_str, i_key_str, i_iv, o_str, o_ready_for_next, o_done, o_key_addr);
  */
  input_fifo input_fifo_inst(.i_clk(i_clk),
                                        .i_rst(rst_input_fifo),
                                        .i_write_en(i_write_fifo_en),
                                        .i_goto_next((encr_block_ready & input_fifo_state) | (~input_fifo_state & ~encr_block_ready)),
                                        .i_val(i_data),
                                        .o_val(pt_from_fifo),
                                        .o_overflow_error(overflow_input_fifo),
                                        .o_underflow_error(underflow_input_fifo));
 
  input_fifo   output_fifo_inst(.i_clk(i_clk),
                                        .i_rst(rst_output_fifo),
                                        .i_write_en(write_output_fifo_en),
                                        .i_goto_next(i_read_next),
                                        .i_val(ct_to_fifo),
                                        .o_val(o_data), // put o_data back!!!!!
                                        .o_overflow_error(overflow_output_fifo),
                                        .o_underflow_error(underflow_output_fifo));
 
  reg_side_top reg_inst( .i_clk(i_clk),
                                  .i_rst(i_rst),
                                  .i_addr(i_reg_addr),
                                  .i_val(i_reg_val),
                                  .i_write_en(i_reg_write_en),
                                  .o_val(o_reg_val),
                                  .o_key(key_in_reg),
                                  .o_iv(iv_in_reg),
                                  .o_key_write_en(key_write_en),
                                  .o_blk_rst(encr_block_rst),
                                  .o_expan_blk_rst(expan_block_rst),
                                  .o_en_cbc(en_cbc),
                                  .o_in_fifo_rst(rst_input_fifo),
                                  .o_out_fifo_rst(rst_output_fifo),
                                  .i_key_done(key_done),
                                  .o_size_key(size_key),
                                  .o_num_rounds(num_rounds),
                                  .i_fifo_status(fifo_status));
 
  key_expand_top key_expan_inst(.i_clk(i_clk),
                                       .i_rst(expan_block_rst),
                                       .i_key(key_in_reg),
                                       .i_write_en(key_write_en),
                                       .i_addr(key_addr),
                                       .i_key_len(size_key),
                                       .i_num_rounds(num_rounds),
                                       .o_key_val(expanded_key),
                                       .o_key_done(key_done));
 
  encr_round_block_top encr_block_inst(.i_clk(i_clk),
                                        .i_rst(encr_block_rst),
                                        .i_round_max(num_rounds),
                                        .i_en_cbc(en_cbc),
                                        .i_str(pt_from_fifo),
                                        .i_key_str(expanded_key),
                                        .i_iv(iv_in_reg),
                                        .o_str(ct_to_fifo),
                                        .o_ready_for_next(encr_block_ready),
                                        .o_done(write_output_fifo_en),
                                        .o_key_addr(key_addr));
endmodule