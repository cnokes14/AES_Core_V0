// SEE : http://ieasynote.com/tools/aes

`timescale 1ps/1ps

logic i_clk;
logic i_rst;
logic[1:0] i_write_fifo;
logic[127:0] i_fifo_data;
logic i_write_reg;
logic[31:0] i_reg_data;
logic[5:0] i_reg_addr;
logic[2:0] i_read_fifo;
logic[127:0] o_fifo_data;
logic[31:0] o_reg_data;
   
logic[127:0] pt_in_arr[0:49];
logic[127:0]   ct_out_arr[0:49];
logic[255:0]   key_val;
logic[127:0]   iv_val;
logic[127:0]   pt_out_arr[0:49];
logic[127:0] tmp;

module test;
 
  aes_core_v0_top uut(i_clk, i_rst, i_write_fifo, i_fifo_data, i_write_reg, i_reg_data, i_reg_addr, i_read_fifo, o_fifo_data, o_reg_data);
 
  initial begin
    i_clk = 0;
    i_rst = 1;
    i_write_fifo = 0;
    i_write_reg = 0;
    fork
      begin
        while(1) begin
        #5ns;
        i_clk = ~i_clk;
        end
      end
    join_none;
    #22.5ns;
    i_rst = 0;
    #10ns;
    write_config(.path(2'b11), .hold_rst(1), .en_cbc(0));
    #10ns;
    fork
      begin
        void'(std::randomize(key_val));
        #1;
        $display($sformatf("Key: %064x", key_val));
        write_key('b11, tmp);
      end
      begin
        #10ns;
        for(int i = 0; i < 50; i++) begin
          void'(std::randomize(tmp));
          #1;
          pt_in_arr[i] = tmp;
          $display($sformatf("%03d : Input plaintext:   %032x", i, pt_in_arr[i]));
          write_fifo(pt_in_arr[i], 2'b10);
        end
      end
    join
    $display("------------------------------------------------------------------------------------------------------");
    #10ns;
    write_config(.path(2'b10), .hold_rst(0), .en_cbc(0));
    #1500ns;
    for(int i = 0; i < 50; i++) begin
      i_read_fifo = 3'b010;
      #1;
      ct_out_arr[i] = o_fifo_data;
      $display($sformatf("%03d : Output ciphertext: %032x", i, o_fifo_data));
      #10ns;
      i_read_fifo = 3'b000;
      #130ns;
    end
    $display("------------------------------------------------------------------------------------------------------");
    #10ns;
    for(int i = 0; i < 50; i++) begin
      write_fifo(ct_out_arr[i], 2'b01);
    end
    #10ns;
    write_config(.path(2'b01), .hold_rst(0), .en_cbc(0));
    write_config(.path(2'b10), .hold_rst(1), .en_cbc(0));
    #1500ns;
    for(int i = 0; i < 50; i++) begin
      i_read_fifo = 3'b001;
      #1;
      pt_out_arr[i] = o_fifo_data;
      $display($sformatf("%03d : Output plaintext:  %032x", i, o_fifo_data));
      if(pt_out_arr[i] !== pt_in_arr[i]) begin
        $display($sformatf("Error at %d! Wanted %032x but got %032x!", i, pt_in_arr[i], pt_out_arr[i]));
      end
      #10ns;
      i_read_fifo = 3'b000;
      #130ns;
    end
    $finish;
  end
 
  task write_config(bit[1:0] path=0, bit en_size_overwrite=0, bit hold_rst=0, bit[1:0] mode=0, bit clr_out_fifo=0,
                    bit clr_in_fifo=0, bit restart_keygen=0, bit restart_nokeygen=0, bit en_cbc=0,
                    bit[3:0] size_key=4, bit[3:0] num_rounds=10);
    i_write_reg = 1;
    i_reg_addr = {path, 4'b1100};
    i_reg_data = {11'h0, en_size_overwrite, 4'h0, hold_rst, mode, clr_out_fifo, clr_in_fifo, restart_keygen, restart_nokeygen, en_cbc, size_key, num_rounds};
    #10ns;
    i_write_reg = 0;
  endtask
 
  task write_key(bit[1:0] path, bit[255:0] i_key);
    i_write_reg = 1;
    for(bit[3:0] i = 0; i < 8; i++) begin
      i_reg_addr = {path, i};
      i_reg_data = i_key[255 - (32*i) -: 32];
      #10ns;
    end
    i_write_reg = 0;
  endtask
 
  // both paths are allowed, but doing this on the encryption side has no use
  task write_iv(bit[1:0] path, bit[127:0] i_iv);
    i_write_reg = 1;
    for(bit[3:0] i = 8; i < 12; i++) begin
      i_reg_addr = {path, i};
      i_reg_data = i_iv[127 - (32*i) -: 32];
      #10ns;
    end
    i_write_reg = 0;
  endtask
 
  task write_fifo(logic[127:0] val, bit[1:0] path);
    i_write_fifo = path;
    i_fifo_data = val;
    #10ns;
    i_write_fifo = 2'b00;
  endtask
 
endmodule
