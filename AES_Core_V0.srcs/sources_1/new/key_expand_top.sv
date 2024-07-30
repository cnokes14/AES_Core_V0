/***************************************************************
 * File:        key_expand_top.sv
 * Module(s):   key_expand_top
 * Author:      Christopher Nokes, ChristopherRNokes@gmail.com
 * Description: TODO
 ***************************************************************
 * Module 0:    key_expand_top 
 * Inputs:      TODO
 * Outputs:     TODO
 ***************************************************************
 * Edits:
 ***************************************************************
 * 30/07/2024   File created.
 ***************************************************************/

module key_expand_top(i_clk, i_rst, i_key, i_write_en, i_addr, i_key_len, i_num_rounds, o_key_val, o_key_done);
  input logic i_clk;
  input logic i_rst;
  input logic[255:0] i_key;
  input logic i_write_en;
  input logic[3:0] i_addr;
  input logic[3:0] i_key_len;
  input logic[3:0] i_num_rounds;
  output logic[127:0] o_key_val;
  output logic o_key_done;
 
  logic[31:0] in_key_as_word_arr[0:7];
  logic[31:0] reg_key_mem[0:63];
  logic[127:0] key_mem_as_str[0:15];
  logic[5:0] reg_counter;
  logic[31:0] wi_minus_n;
  logic[31:0] wi_minus_one;
  logic[31:0] word_new;
  logic[5:0] req_num_words;
  logic[31:0] rot_wi_minus_one;
  logic[3:0] i_div_n;
  logic[3:0] i_mod_n;
  logic[31:0] to_s_box;
  logic[31:0] from_s_box;
  logic[31:0] inc_r_con;
  logic[3:0] len_key_minus_one;
 
  logic is_mod_zero;
  logic is_mod_four;
  logic is_mod_last;
  logic internal_key_done;
 
  logic[7:0] r_con_arr[0:15] = {'h01, 'h02, 'h04, 'h08,
                                'h10, 'h20, 'h40, 'h80,
                                'h1B, 'h36, 'h00, 'h00,
                                'h00, 'h00,'h00, 'h00};
  logic[7:0] s_box_vals[0:255] = '{
    8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
    8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
    8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
    8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
    8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
    8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
    8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
    8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
    8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
    8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
    8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
    8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
    8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
    8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
    8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
    8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
  };
 
  assign o_key_val = key_mem_as_str[i_addr];
  assign wi_minus_n = reg_key_mem[reg_counter - i_key_len];
  assign wi_minus_one = reg_key_mem[reg_counter - 1];
  assign req_num_words = {i_num_rounds, 2'b11};
  assign rot_wi_minus_one = {wi_minus_one[23:0], wi_minus_one[31:24]};
  assign len_key_minus_one = i_key_len - 1;
 
  assign is_mod_zero = ~(|(i_mod_n));
  assign is_mod_four = (i_key_len[3] | &(i_key_len[2:0])) & &(i_mod_n == 4'h4);
  assign is_mod_last = &(i_mod_n == len_key_minus_one);
 
  assign from_s_box[31:24] = s_box_vals[to_s_box[31:24]];
  assign from_s_box[23:16] = s_box_vals[to_s_box[23:16]];
  assign from_s_box[15:8] = s_box_vals[to_s_box[15:8]];
  assign from_s_box[7:0] = s_box_vals[to_s_box[7:0]];
 
  assign internal_key_done = &(reg_counter == {i_num_rounds+1, 2'b00});
  assign o_key_done = internal_key_done;
 
  generate
    for(genvar gen_index = 0; gen_index < 16; gen_index++) begin
      assign key_mem_as_str[gen_index][127:96] = reg_key_mem[(gen_index * 4)];
      assign key_mem_as_str[gen_index][95:64] = reg_key_mem[(gen_index * 4)+1];
      assign key_mem_as_str[gen_index][63:32] = reg_key_mem[(gen_index * 4)+2];
      assign key_mem_as_str[gen_index][31:0] = reg_key_mem[(gen_index * 4)+3];
    end
  endgenerate
 
  generate
  for(genvar gen_index = 0; gen_index < 8; gen_index++) begin
      assign in_key_as_word_arr[gen_index] = i_key[255 - (32 * gen_index) : 224 - (32 * gen_index)];
    end
  endgenerate
 
  always @(*) begin
    if(is_mod_four) begin
      to_s_box = wi_minus_one;
    end else begin
      to_s_box = rot_wi_minus_one;
    end
  end
 
  always @(*) begin
    if(is_mod_zero) begin
      inc_r_con = wi_minus_n ^ ({r_con_arr[i_div_n], 24'h000000});
    end else begin
      inc_r_con = wi_minus_n;
    end
  end
 
  always @(*) begin
    if(is_mod_zero | is_mod_four) begin
      word_new = inc_r_con ^ from_s_box;
    end else begin
      word_new = inc_r_con ^ wi_minus_one;
    end
  end
 
  always @(posedge i_clk) begin
    if(i_rst) begin
      reg_key_mem = '{default:'0};
    end else if(i_write_en) begin
      for(int i = 0; i < 8; i++) begin
        reg_key_mem[i]  = in_key_as_word_arr[i];
      end
      for(int i = 8; i < 64; i++) begin
        reg_key_mem[i]  = 32'h00000000;
      end
    end else begin
      reg_key_mem[reg_counter] = word_new;
    end
  end
 
  always @(posedge i_clk) begin
    if(i_rst) begin
      reg_counter = 5'h00;
      //internal_key_done = 1'b0;
    end else if(i_write_en) begin
      reg_counter = i_key_len;
      //internal_key_done = 1'b0;
    end else if(~internal_key_done) begin
      reg_counter++;
      //internal_key_done = 1'b0;
    end else begin
      //internal_key_done = 1'b1;
    end
  end
 
  always @(posedge i_clk) begin
    if(i_rst | i_write_en | is_mod_last | internal_key_done) begin
      i_mod_n = 4'h0;
    end else begin
      i_mod_n++;
    end
  end
 
  always @(posedge i_clk) begin
    if(i_rst | i_write_en | internal_key_done) begin
      i_div_n <= 4'h0;
    end else if(is_mod_last) begin
      i_div_n++;
    end
  end
endmodule