//======================================================================
//
// tb_aes_core.v
// ----------------
// Testbench for the SHA-256 core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2013, Secworks Sweden AB
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the following 
// conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright 
//    notice, this list of conditions and the following disclaimer. 
// 
// 2. Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the 
//    distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

//------------------------------------------------------------------
// Simulator directives.
//------------------------------------------------------------------
`timescale 1ns/10ps


//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_aes_core();
  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG = 0;

  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;
  

  parameter AES_128_BIT_KEY = 2'b0;
  parameter AES_128_BIT_KEY = 2'b1;
  parameter AES_128_BIT_KEY = 2'b2;

  parameter AES_DECIPHER = 1'b0;
  parameter AES_ENCIPHER = 1'b1;

  
  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg            tb_clk;
  reg            tb_reset_n;
  reg            tb_encdec;
  reg            tb_init;
  reg            tb_next;
  wire           tb_ready;
  reg [255 : 0]  tb_key;
  reg [1 : 0]    tb_keylen;
  reg [127 : 0]  tb_block;
  wire [127 : 0] tb_result;
  wire           tb_result_valid;
  
  
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  aes_core dut(
               .clk(tb_clk),
               .reset_n(tb_reset_n),
               
               .encdec(tb_encdec),
               .init(tb_init),
               .next(tb_next),
               .ready(tb_ready),

               .key(tb_key),
               .keylen(tb_keylen),

               .block(tb_block),
               .result(tb_result),
               .result_valid(tb_result_valid)
              );
  

  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always 
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen
    

  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;
      #(CLK_PERIOD);
      if (DEBUG)
        begin
          dump_dut_state();
        end
    end

  
  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
//  task dump_dut_state();
//    begin
//      $display("State of DUT");
//      $display("------------");
//      $display("Inputs and outputs:");
//      $display("init   = 0x%01x, next  = 0x%01x", 
//               dut.init, dut.next);
//      $display("block  = 0x%0128x", dut.block);
//
//      $display("ready  = 0x%01x, valid = 0x%01x", 
//               dut.ready, dut.digest_valid);
//      $display("digest = 0x%064x", dut.digest);
//      $display("H0_reg = 0x%08x, H1_reg = 0x%08x, H2_reg = 0x%08x, H3_reg = 0x%08x", 
//               dut.H0_reg, dut.H1_reg, dut.H2_reg, dut.H3_reg);
//      $display("H4_reg = 0x%08x, H5_reg = 0x%08x, H6_reg = 0x%08x, H7_reg = 0x%08x", 
//               dut.H4_reg, dut.H5_reg, dut.H6_reg, dut.H7_reg);
//      $display("");
//      
//      $display("Control signals and counter:");
//      $display("aes_ctrl_reg = 0x%02x", dut.aes_ctrl_reg);
//      $display("digest_init     = 0x%01x, digest_update = 0x%01x", 
//               dut.digest_init, dut.digest_update);
//      $display("state_init      = 0x%01x, state_update  = 0x%01x", 
//               dut.state_init, dut.state_update);
//      $display("first_block     = 0x%01x, ready_flag    = 0x%01x, w_init    = 0x%01x", 
//               dut.first_block, dut.ready_flag, dut.w_init);
//      $display("t_ctr_inc       = 0x%01x, t_ctr_rst     = 0x%01x, t_ctr_reg = 0x%02x", 
//               dut.t_ctr_inc, dut.t_ctr_rst, dut.t_ctr_reg);
//      $display("");
//
//      $display("State registers:");
//      $display("a_reg = 0x%08x, b_reg = 0x%08x, c_reg = 0x%08x, d_reg = 0x%08x", 
//               dut.a_reg, dut.b_reg, dut.c_reg, dut.d_reg);
//      $display("e_reg = 0x%08x, f_reg = 0x%08x, g_reg = 0x%08x, h_reg = 0x%08x", 
//               dut.e_reg, dut.f_reg, dut.g_reg, dut.h_reg);
//      $display("");
//      $display("a_new = 0x%08x, b_new = 0x%08x, c_new = 0x%08x, d_new = 0x%08x", 
//               dut.a_new, dut.b_new, dut.c_new, dut.d_new);
//      $display("e_new = 0x%08x, f_new = 0x%08x, g_new = 0x%08x, h_new = 0x%08x", 
//               dut.e_new, dut.f_new, dut.g_new, dut.h_new);
//      $display("");
//
//      $display("State update values:");
//      $display("w  = 0x%08x, k  = 0x%08x", dut.w_data, dut.k_data);
//      $display("t1 = 0x%08x, t2 = 0x%08x", dut.t1, dut.t2);
//      $display("");
//    end
//  endtask // dump_dut_state
  
  
  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut();
    begin
      $display("*** Toggle reset.");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut

  
  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim();
    begin
      cycle_ctr = 0;
      error_ctr = 0;
      tc_ctr    = 0;
      
      tb_clk     = 0;
      tb_reset_n = 1;
      tb_encdec  = 0;
      tb_init    = 0;
      tb_next    = 0;
      tb_key     = {8(32'h00000000}};
      tb_keylen  = 0;

      tb_block  = {4(32'h00000000}};
    end
  endtask // init_dut

  
  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result();
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d tests completed - %02d test cases did not complete successfully.", 
                   tc_ctr, error_ctr);
        end
    end
  endtask // display_test_result
  

  //----------------------------------------------------------------
  // wait_ready()
  //
  // Wait for the ready flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing and will in fact at some
  // point set the flag.
  //----------------------------------------------------------------
  task wait_ready();
    begin
      while (!tb_ready)
        begin
          #(CLK_PERIOD);
        end
    end
  endtask // wait_ready
  

  //----------------------------------------------------------------
  // wait_valid()
  //
  // Wait for the result_valid flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing a block and will in fact 
  // at some point set the flag.
  //----------------------------------------------------------------
  task wait_valid();
    begin
      while (!tb_result_valid)
        begin
          #(CLK_PERIOD);
        end
    end
  endtask // wait_valid

  
  //----------------------------------------------------------------
  // ecb_mode_single_block_test()
  //
  // Perform ECB mode encryption or decryption single block test.
  //----------------------------------------------------------------
  task ecb_mode_single_block_test(input [7 : 0]   tc_number,
                                  input           encdec,
                                  input [255 : 0] key,
                                  input [1 : 0]   key_length,
                                  input [127 : 0] block,
                                  input [127 : 0] expected);
   begin
     $display("*** TC %0d ECB mode test started.", tc_number);
     tc_ctr = tc_ctr + 1;

     // Init the cipher with the given key and length.
     tb_key = key;
     tb_keylength = key_length;
     tb_init = 1;
     #(2 * CLK_PERIOD);
     tb_init = 0;
     wait_ready();

     // Perform encipher och decipher operation on the block.
     tb_encdec = encdec;
     tb_block = block;
     tb_next = 1;
     #(2 * CLK_PERIOD);
     tb_next = 0;
     wait_valid();
      
     if (tb_result == expected)
       begin
         $display("*** TC %0d successful.", tc_number);
         $display("");
       end 
     else
       begin
         $display("*** ERROR: TC %0d NOT successful.", tc_number);
         $display("Expected: 0x%064x", expected);
         $display("Got:      0x%064x", tb_digest);
         $display("");

         error_ctr = error_ctr + 1;
       end
   end
  endtask // ecb_mode_single_block_test
                         
    
  //----------------------------------------------------------------
  // aes_core_test
  // The main test functionality. 
  //
  // Test cases taken from NIST SP 800-38A:
  // http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf
  //----------------------------------------------------------------
  initial
    begin : aes_core_test
      reg [127 : 0] nist_aes128_key;
      reg [191 : 0] nist_aes192_key;
      reg [255 : 0] nist_aes255_key;

      reg [127 : 0] nist_plaintext0;
      reg [127 : 0] nist_plaintext1;
      reg [127 : 0] nist_plaintext2;
      reg [127 : 0] nist_plaintext3;

      reg [127 : 0] nist_ecb_128_enc_expected0;
      reg [127 : 0] nist_ecb_128_enc_expected1;
      reg [127 : 0] nist_ecb_128_enc_expected2;
      reg [127 : 0] nist_ecb_128_enc_expected3;

      reg [127 : 0] nist_ecb_192_enc_expected0;
      reg [127 : 0] nist_ecb_192_enc_expected1;
      reg [127 : 0] nist_ecb_192_enc_expected2;
      reg [127 : 0] nist_ecb_192_enc_expected3;

      reg [127 : 0] nist_ecb_256_enc_expected0;
      reg [127 : 0] nist_ecb_256_enc_expected1;
      reg [127 : 0] nist_ecb_256_enc_expected2;
      reg [127 : 0] nist_ecb_256_enc_expected3;

      nist_aes128_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
      nist_aes192_key = 192'h8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b;
      nist_aes255_key = 255'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4;

      nist_plaintext0 = 128'h6bc1bee22e409f96e93d7e117393172a;
      nist_plaintext1 = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
      nist_plaintext2 = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
      nist_plaintext3 = 128'hf69f2445df4f9b17ad2b417be66c3710;

      nist_ecb_128_enc_expected0 = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
      nist_ecb_128_enc_expected1 = 128'hf5d3d58503b9699de785895a96fdbaaf;
      nist_ecb_128_enc_expected2 = 128'h43b1cd7f598ece23881b00e3ed030688;
      nist_ecb_128_enc_expected3 = 128'h7b0c785e27e8ad3f8223207104725dd4;

      nist_ecb_192_enc_expected0 = 192'hbd334f1d6e45f25ff712a214571fa5cc;
      nist_ecb_192_enc_expected1 = 192'h974104846d0ad3ad7734ecb3ecee4eef;
      nist_ecb_192_enc_expected2 = 192'hef7afd2270e2e60adce0ba2face6444e;
      nist_ecb_192_enc_expected3 = 192'h9a4b41ba738d6c72fb16691603c18e0e;

      nist_ecb_256_enc_expected0 = 255'hf3eed1bdb5d2a03c064b5a7e3db181f8;
      nist_ecb_256_enc_expected1 = 255'h591ccb10d410ed26dc5ba74a31362870;
      nist_ecb_256_enc_expected2 = 255'hb6ed21b99ca6f4f9f153e7b1beafed1d;
      nist_ecb_256_enc_expected3 = 255'h23304b7a39f9f3ff067d8d8f9e24ecc7;


      $display("   -= Testbench for aes core started =-");
      $display("     ================================");
      $display("");

      init_sim();
      dump_dut_state();
      reset_dut();
      dump_dut_state();


      $display("ECB 128 bit key tests");
      $display("-------------");
      ecb_mode_single_block_test(8'h01 AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_plaintext0, nist_ecb_128_enc_expected0);

      ecb_mode_single_block_test(8'h02 AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_plaintext1, nist_ecb_128_enc_expected1);

      ecb_mode_single_block_test(8'h03 AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_plaintext2, nist_ecb_128_enc_expected2);

      ecb_mode_single_block_test(8'h03 AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_plaintext3, nist_ecb_128_enc_expected3);

      
      ecb_mode_single_block_test(8'h04 AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_ecb_128_enc_expected0, nist_plaintext0);

      ecb_mode_single_block_test(8'h05 AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_ecb_128_enc_expected1, nist_plaintext1);

      ecb_mode_single_block_test(8'h06 AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_ecb_128_enc_expected2, nist_plaintext2);

      ecb_mode_single_block_test(8'h07 AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY, 
                                 nist_ecb_128_enc_expected3, nist_plaintext3);
      

      $display("");
      $display("ECB 192 bit key tests");
      $display("---------------------");
      ecb_mode_single_block_test(8'h08 AES_ENCIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_plaintext0, nist_ecb_192_enc_expected0);

      ecb_mode_single_block_test(8'h09 AES_ENCIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_plaintext1, nist_ecb_192_enc_expected1);

      ecb_mode_single_block_test(8'h0a AES_ENCIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_plaintext2, nist_ecb_192_enc_expected2);

      ecb_mode_single_block_test(8'h0b AES_ENCIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_plaintext3, nist_ecb_192_enc_expected3);

      
      ecb_mode_single_block_test(8'h0c AES_DECIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_ecb_192_enc_expected0, nist_plaintext0);

      ecb_mode_single_block_test(8'h0d AES_DECIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_ecb_192_enc_expected1, nist_plaintext1);

      ecb_mode_single_block_test(8'h0e AES_DECIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_ecb_192_enc_expected2, nist_plaintext2);

      ecb_mode_single_block_test(8'h0f AES_DECIPHER, nist_aes192_key, AES_192_BIT_KEY, 
                                 nist_ecb_192_enc_expected3, nist_plaintext3);


      
      $display("");
      $display("ECB 256 bit key tests");
      $display("---------------------");
      ecb_mode_single_block_test(8'h10 AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_plaintext0, nist_ecb_256_enc_expected0);

      ecb_mode_single_block_test(8'h11 AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_plaintext1, nist_ecb_256_enc_expected1);

      ecb_mode_single_block_test(8'h12 AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_plaintext2, nist_ecb_256_enc_expected2);

      ecb_mode_single_block_test(8'h13 AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_plaintext3, nist_ecb_256_enc_expected3);

      
      ecb_mode_single_block_test(8'h14 AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_ecb_256_enc_expected0, nist_plaintext0);

      ecb_mode_single_block_test(8'h15 AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_ecb_256_enc_expected1, nist_plaintext1);

      ecb_mode_single_block_test(8'h16 AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_ecb_256_enc_expected2, nist_plaintext2);

      ecb_mode_single_block_test(8'h17 AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY, 
                                 nist_ecb_256_enc_expected3, nist_plaintext3);


      display_test_result();
      $display("");
      $display("*** AES core simulation done. ***");
      $finish;
    end // aes_core_test
endmodule // tb_aes_core

//======================================================================
// EOF tb_aes_core.v
//======================================================================