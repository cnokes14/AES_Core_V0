/***************************************************************
 * File:        aes_core_v0_top.sv
 * Module(s):   aes_core_v0_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: Merger of encr_path_top and decr_path_top, with some extra select signals to
 *                  pick which one to read from and write to.
 ***************************************************************
 * Module 0:    decr_path_top 
 * Inputs:      i_clk---------------logic-----------Clock; used on positive edge only.
 *              i_rst---------------logic-----------Active high reset. Sets all used registers to 'h0, across both paths.
 *              i_write_fifo--------logic[1:0]------'b11: write i_fifo_data to both encr and decr FIFO
 *                                                  'b01: write i_fifo_data to decr FIFO
 *                                                  'b10: write i_fifo_data to encr FIFO
 *                                                  'b00: do not write i_fifo_data
 *              i_fifo_data---------logic[127:0]----Data for input FIFO.
 *              i_write_reg---------logic-----------When '1', write i_reg_data to the register map on rising clock edge.
 *              i_reg_data----------logic[31:0]-----Value to write to the register map.
 *              i_reg_addr----------logic[5:0]------First two bits are used as a select for encr / decr path:
 *                                                      'b11: both, 'b10: encr, 'b01: decr, 'b00: neither (possibly global?)

 *              i_read_fifo---------logic[2:0]------bit 0 : read from decryption FIFO
 *                                                  bit 1 : read from encryption FIFO
 *                                                  bit 2 : (0) enable popping, (1) disable popping, peeking only.
 * Outputs:     o_data--------------logic[127:0]----Value of the output FIFO. Valid until the rising clock edge when i_read_fifo[2]='0'
 *              o_reg_val-----------logic[31:0]-----Current data of reg[i_reg_addr]. Some values (key, IV, etc.) cannot be read.
 ****************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

module aes_core_v0_top(i_clk, i_rst, i_write_fifo, i_fifo_data, i_write_reg, i_reg_data, i_reg_addr, i_read_fifo, o_fifo_data, o_reg_data);
  input logic i_clk;
  input logic i_rst;
  input logic[1:0] i_write_fifo; // 2: encr, 1: decr
  input logic[127:0] i_fifo_data;
  input logic i_write_reg;
  input logic[31:0] i_reg_data;
  input logic[5:0] i_reg_addr;
  input logic[2:0] i_read_fifo; // bit 2 is to enable (0) popping or disable (0) popping (IE: peeking)
  output logic[127:0] o_fifo_data;
  output logic[31:0] o_reg_data;
 
  // NOTE: FOR OUTPUT READS, ENCRYPTION ALWAYS TAKES PRIORITY! YOU CANNOT READ BOTH AT ONCE
  logic write_encr_fifo;
  logic write_decr_fifo;
  logic read_encr_fifo;
  logic read_decr_fifo;
  logic write_encr_reg;
  logic write_decr_reg;
 
  logic enable_fifo_popping;
 
  logic[127:0] encr_fifo_out;
  logic[31:0] encr_reg_out;
  logic[127:0] decr_fifo_out;
  logic[31:0] decr_reg_out;
 
  assign write_encr_fifo = i_write_fifo[1];
  assign write_decr_fifo = i_write_fifo[0];
  assign read_encr_fifo = i_read_fifo[1];
  assign read_decr_fifo = i_read_fifo[0];
 
  assign write_encr_reg = i_reg_addr[5] & i_write_reg; // presumably, cases 00 can be used for top level regs
  assign write_decr_reg = i_reg_addr[4] & i_write_reg; // and case 11 can be used to write to both
 
  assign enable_fifo_popping = ~i_read_fifo[2];
 
  encr_path_top encryption_inst(.i_clk(i_clk), .i_rst(i_rst), .i_write_fifo_en(write_encr_fifo), .i_data(i_fifo_data), .i_reg_addr(i_reg_addr[3:0]), .i_reg_val(i_reg_data),
                                .i_reg_write_en(write_encr_reg), .i_read_next(read_encr_fifo & enable_fifo_popping), .o_data(encr_fifo_out), .o_reg_val(encr_reg_out));
  decr_path_top decryption_inst(.i_clk(i_clk), .i_rst(i_rst), .i_write_fifo_en(write_decr_fifo), .i_data(i_fifo_data), .i_reg_addr(i_reg_addr[3:0]), .i_reg_val(i_reg_data),
                                .i_reg_write_en(write_decr_reg), .i_read_next(read_decr_fifo & enable_fifo_popping), .o_data(decr_fifo_out), .o_reg_val(decr_reg_out));
 
  always @(*) begin
    if(read_encr_fifo) begin
      o_fifo_data = encr_fifo_out;
    end else if(read_decr_fifo) begin
      o_fifo_data = decr_fifo_out;
    end else begin
      o_fifo_data = 'h0;
    end
   
    if(i_reg_addr[5]) begin
      o_reg_data = encr_reg_out;
    end else if(i_reg_addr[4]) begin
      o_reg_data = decr_reg_out;
    end else begin
      o_reg_data = 'h0;
    end
  end
endmodule