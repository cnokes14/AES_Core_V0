/***************************************************************
 * File:        input_fifo.sv
 * Module(s):   input_fifo
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    input_fifo 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

module input_fifo(i_clk, i_rst, i_write_en, i_goto_next, i_val, o_val, o_overflow_error, o_underflow_error);
  input logic i_clk;
  input logic i_rst;
  input logic i_write_en;
  input logic i_goto_next;
  input logic[127:0] i_val;
  output logic[127:0] o_val;
  output logic o_overflow_error;
  output logic o_underflow_error;
 
  logic[127:0] mem[0:63]; // this ends up being about 1KB of data
 
  logic[5:0]  output_counter; // ends a clock cycle on the NEXT one to take out
  logic[5:0]  input_counter;
  logic[0:63] valid_data;
 
  assign o_val = mem[output_counter];
 
  always @(posedge i_clk) begin
    if(i_rst) begin
      valid_data = 64'h00000000_00000000;
      o_overflow_error = 1'b0;
      o_underflow_error = 1'b0;
      input_counter = 6'b000000;
      output_counter = 6'b000000;
    end else begin
      if(i_write_en) begin
        if(valid_data[input_counter]) begin
          o_overflow_error <= 1'b1;
        end else begin
          o_overflow_error <= 1'b0;
          input_counter <= input_counter+1;
          mem[input_counter] = i_val;
          valid_data[input_counter] <= 1'b1;
        end
      end
      if(i_goto_next) begin
        if(~valid_data[output_counter]) begin
          o_underflow_error <= 1'b1;
        end else begin
          o_underflow_error <= 1'b0;
          output_counter <= output_counter+1;
          valid_data[output_counter] <= 1'b0;
        end
      end
    end
  end
endmodule