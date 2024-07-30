#include <stdio.h>
#include <stdlib.h>

// the s-box and inverse s-box were written out by microsoft copilot.
static unsigned char s_box[256] = {
    0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
    0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
    0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
    0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
    0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
    0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
    0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
    0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
    0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
    0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
    0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
    0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
    0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
    0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
    0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
    0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16
};

unsigned char inv_s_box[256] = {
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
};

// constant for key expansion, used as rc[n] << 24 since it occupies the top 8 bits.
static unsigned char rc[11] = {0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36};

// needed on certain systems;
unsigned int switch_endian(unsigned int w_val){
    return ((w_val& 0xFF) << 24) | ((w_val& 0xFF00) << 8) | ((w_val& 0xFF0000) >> 8) | ((w_val & 0xFF000000) >> 24);
}

unsigned int sub_word(unsigned int w_val){
    return s_box[w_val & 0xFF] | (unsigned int) (s_box[(w_val >> 8) & 0xFF] << 8) | (unsigned int) (s_box[(w_val >> 16) & 0xFF] << 16) | (unsigned int) (s_box[(w_val >> 24) & 0xFF] << 24);
}

unsigned int rot_word(unsigned int w_val){
    return (w_val << 8) | (w_val >> 24);
}

unsigned char galois_mul_by_two(unsigned char in_val){
    return (in_val << 1) ^ ((in_val >> 7) * 0x1B);
}

/*
 * FUNCTION:    key_expansion
 * USE:         Expands a given key according to the AES key scheduler. See https://en.wikipedia.org/wiki/AES_key_schedule
 * ARGS:
 * char* key-----------------------character array of given key, whose length must be a multiple of 4.
 * unsigned char* exp_key_retval---location to which the expanded key is written once completed; ASSUMED FULLY ALLOCATED ON FUNCTION CALL
 * unsigned int len_key------------length of the key, in words (currently a word is 4 bytes; TODO: make this rely on a compiler constant?)
 * unsigned int num_rounds---------number of iterations (output key blocks of len_key * size word bits).
 */
void key_expansion(unsigned char* key, unsigned char* exp_key_retval, unsigned int len_key, unsigned int num_rounds){
    unsigned int index = 0;
    unsigned int expanded_key[(num_rounds+1) * 4];
    unsigned int prev_key;
    unsigned int sub_word_v;
    unsigned int sub_rot_word_v;
    unsigned int rcon_v;
    unsigned int case_vals[4];
    for(index = 0; index < 4*(num_rounds+1); index+=1){
        // we won't use a lot of these in every run, but we always calculate them to prevent simple instruction-based attacks.
        expanded_key[index] = switch_endian(*((unsigned int*)(&key[(index % len_key) * 4])));   // dereference 4 char bytes as an int; switching endian may be necessary!
        expanded_key[index] = expanded_key[index - (len_key * (index >= len_key))];             // if we're past the initial given key bytes, our starter value is the previous block's equivalent word
        prev_key = expanded_key[index - (1 && index)];                                          // expanded_key(index-1); if index < 1, just get key[0].
        sub_word_v = sub_word(prev_key);                                                        // substitution of all bytes in the previous word
        sub_rot_word_v = sub_word(rot_word(prev_key));                                          // substitution of all bytes in the previous word after cyclic rotation left by one byte
        rcon_v = (unsigned int) (rc[(index / len_key) % 11] << 24);                             // current constant, in case it's needed
        case_vals[0] = expanded_key[index];
        case_vals[1] = expanded_key[index] ^ sub_rot_word_v ^ rcon_v;
        case_vals[2] = expanded_key[index] ^ sub_word_v;
        case_vals[3] = expanded_key[index] ^ prev_key;
        // TODO : conditionals allow attackers to detect current stage; we don't want that.
        if(index < len_key){
            expanded_key[index] = case_vals[0];
        }
        else if(index >= len_key && index % len_key == 0){
            expanded_key[index] = case_vals[1];
        }
        else if(index >= len_key && len_key > 6 && index % len_key == 4){
            expanded_key[index] = case_vals[2];
        }
        else {
            expanded_key[index] = case_vals[3];
        }
        exp_key_retval[(index*4)+0] = (expanded_key[index] >> 0x18) & 0xFF;
        exp_key_retval[(index*4)+1] = (expanded_key[index] >> 0x10) & 0xFF;
        exp_key_retval[(index*4)+2] = (expanded_key[index] >> 0x08) & 0xFF;
        exp_key_retval[(index*4)+3] = (expanded_key[index] >> 0x00) & 0xFF;
    }
}

// https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
// https://legacy.cryptool.org/en/cto/aes-step-by-step
// https://www.onlinegdb.com/online_c_compiler
/*
 * FUNCTION:    encrypt_aes
 * USE:         Encrypts a given plaintext using an expanded AES key. Functions at any rate (128, 192, 256), so long as
 *                  len(exp_key) >= 16*(num_rounds+1). Developed by implementing the following reference:
 *                  https://en.wikipedia.org/wiki/Advanced_Encryption_Standard#Description_of_the_ciphers
 * ARGS:
 * char pt[16]-----------------Plaintext to encrypt
 * unsigned char ct_out[16]----location to which the ciphertext is written once completed; ASSUMED FULLY ALLOCATED ON FUNCTION CALL
 * unsigned char* exp_key------expanded key; len(exp_key) >= 16*(num_rounds+1)
 * unsigned int num_rounds-----number of iterations (output key blocks of len_key * size word bits).
 */
void encrypt_aes(unsigned char pt[16], unsigned char ct_out[16], unsigned char* exp_key, unsigned int num_rounds){
    unsigned int index, inner_index;
    unsigned char sub_ct[16];
    unsigned char xor_two[4];
    unsigned char ct[16];
    // round 0 -- add initial key
    for(index = 0; index < 16; index++){
        ct[index] = pt[index] ^ exp_key[index];
    }
    // main rounds -- perform loop
    for(index = 1; index < num_rounds; index++){
        // sub bytes and shift rows
        for(inner_index = 0; inner_index < 4; inner_index++){
            sub_ct[inner_index + 0] = s_box[ct[inner_index + ((4 * (inner_index + 0)) % 16)]];
            sub_ct[inner_index + 4] = s_box[ct[inner_index + ((4 * (inner_index + 1)) % 16)]];
            sub_ct[inner_index + 8] = s_box[ct[inner_index + ((4 * (inner_index + 2)) % 16)]];
            sub_ct[inner_index + 12] = s_box[ct[inner_index + ((4 * (inner_index + 3)) % 16)]];
        }
        // mix columns and add key
        for(inner_index = 0; inner_index < 4; inner_index++){
            xor_two[0] = galois_mul_by_two(sub_ct[(inner_index * 4) + 0]);
            xor_two[1] = galois_mul_by_two(sub_ct[(inner_index * 4) + 1]);
            xor_two[2] = galois_mul_by_two(sub_ct[(inner_index * 4) + 2]);
            xor_two[3] = galois_mul_by_two(sub_ct[(inner_index * 4) + 3]);
            ct[(inner_index*4) + 0] = exp_key[(index * 16) + (inner_index*4) + 0] ^ xor_two[0] ^ xor_two[1] ^ sub_ct[(4*inner_index) + 1] ^ sub_ct[(4*inner_index) + 2] ^ sub_ct[(4*inner_index) + 3];
            ct[(inner_index*4) + 1] = exp_key[(index * 16) + (inner_index*4) + 1] ^ xor_two[1] ^ xor_two[2] ^ sub_ct[(4*inner_index) + 2] ^ sub_ct[(4*inner_index) + 0] ^ sub_ct[(4*inner_index) + 3];
            ct[(inner_index*4) + 2] = exp_key[(index * 16) + (inner_index*4) + 2] ^ xor_two[2] ^ xor_two[3] ^ sub_ct[(4*inner_index) + 3] ^ sub_ct[(4*inner_index) + 0] ^ sub_ct[(4*inner_index) + 1];
            ct[(inner_index*4) + 3] = exp_key[(index * 16) + (inner_index*4) + 3] ^ xor_two[3] ^ xor_two[0] ^ sub_ct[(4*inner_index) + 0] ^ sub_ct[(4*inner_index) + 1] ^ sub_ct[(4*inner_index) + 2];
        }
    }
    // final round
    for(inner_index = 0; inner_index < 4; inner_index++){
        sub_ct[inner_index + 0] = s_box[ct[inner_index + ((4 * (inner_index + 0)) % 16)]];
        sub_ct[inner_index + 4] = s_box[ct[inner_index + ((4 * (inner_index + 1)) % 16)]];
        sub_ct[inner_index + 8] = s_box[ct[inner_index + ((4 * (inner_index + 2)) % 16)]];
        sub_ct[inner_index + 12] = s_box[ct[inner_index + ((4 * (inner_index + 3)) % 16)]];
    }
    for(index = 0; index < 16; index++){
        ct_out[index] = sub_ct[index] ^ exp_key[index + (16 * (num_rounds))];
    }
}

// https://crypto.stackexchange.com/questions/2569/how-does-one-implement-the-inverse-of-aes-mixcolumns
// https://en.wikipedia.org/wiki/Rijndael_MixColumns
void decrypt_aes(unsigned char ct[16], unsigned char pt_out[16], unsigned char* exp_key, unsigned int num_rounds){
    int index, inner_index, tertiary_index;
    unsigned char sub_pt[16];
    unsigned char xor_outs[16]; // 0:3 -- x9, 4:7 -- x11, 8:11 -- x13, 12:15 -- x14
    unsigned char pt[16];
    unsigned char tmp;
    // undo final key addition
    for(index = 0; index < 16; index++){
        pt[index] = ct[index] ^ exp_key[index + (16 * (num_rounds))];
    }
    // undo final shift and sub-box
    for(index = 0; index < 4; index++){
        sub_pt[index + 0]  = inv_s_box[pt[(16 - (3 * index)) % 16]]; // these are +16 off since C handles negative modulo
        sub_pt[index + 4]  = inv_s_box[pt[(20 - (3 * index)) % 16]]; // inputs in a way that isn't right for this application;
        sub_pt[index + 8]  = inv_s_box[pt[(24 - (3 * index)) % 16]]; // IE: -3 % 16 is -3 in C, but we want it to be 13.
        sub_pt[index + 12] = inv_s_box[pt[(28 - (3 * index)) % 16]]; // BUT (-3 + 16) % 16 = 13 in C.
    }
    // main loops
    for(index = num_rounds - 1; index > 0; index--){
        for(inner_index = 0; inner_index < 4; inner_index++){
            for(tertiary_index = 0; tertiary_index < 4; tertiary_index++){
                tmp = exp_key[index*16 + inner_index*4 + tertiary_index] ^ sub_pt[(4*inner_index) + tertiary_index];
                xor_outs[tertiary_index + 0] = galois_mul_by_two(tmp);                                      // X * 2
                xor_outs[tertiary_index + 8] = galois_mul_by_two(xor_outs[tertiary_index + 0] ^ tmp);       // ((X * 2) + X) * 2
                xor_outs[tertiary_index + 0] = galois_mul_by_two(xor_outs[tertiary_index + 0]);             // ((X * 2) * 2)
                xor_outs[tertiary_index + 4] = galois_mul_by_two(xor_outs[tertiary_index + 0] ^ tmp) ^ tmp; // ((((X * 2) * 2) ^ X) * 2) ^ X -- DONE
                xor_outs[tertiary_index + 0] = galois_mul_by_two(xor_outs[tertiary_index + 0]) ^ tmp;       // (((X * 2) * 2) * 2) ^ X -- DONE
                xor_outs[tertiary_index + 12]= galois_mul_by_two(xor_outs[tertiary_index + 8] ^ tmp);       // ((((X * 2) + X) * 2) ^ X) * 2 -- DONE
                xor_outs[tertiary_index + 8] = galois_mul_by_two(xor_outs[tertiary_index + 8]) ^ tmp;       // ((((X * 2) + X) * 2) * 2) ^ X -- DONE
            }
            pt[(inner_index*4) + 0] = xor_outs[12] ^ xor_outs[5] ^ xor_outs[10] ^ xor_outs[3];
            pt[(inner_index*4) + 1] = xor_outs[0] ^ xor_outs[13] ^ xor_outs[6] ^ xor_outs[11];
            pt[(inner_index*4) + 2] = xor_outs[8] ^ xor_outs[1] ^ xor_outs[14] ^ xor_outs[7];
            pt[(inner_index*4) + 3] = xor_outs[4] ^ xor_outs[9] ^ xor_outs[2] ^ xor_outs[15];
        }
        // sub bytes and shift rows
        for(inner_index = 0; inner_index < 4; inner_index++){
            sub_pt[inner_index + 0]  = inv_s_box[pt[(16 - (3 * inner_index)) % 16]];
            sub_pt[inner_index + 4]  = inv_s_box[pt[(20 - (3 * inner_index)) % 16]];
            sub_pt[inner_index + 8]  = inv_s_box[pt[(24 - (3 * inner_index)) % 16]];
            sub_pt[inner_index + 12] = inv_s_box[pt[(28 - (3 * inner_index)) % 16]];
        }
    }
    // round 0 -- add initial key
    for(index = 0; index < 16; index++){
        pt_out[index] = sub_pt[index] ^ exp_key[index];
    }
   
}

// https://legacy.cryptool.org/en/cto/aes-step-by-step was used to verify functionality
// https://www.onlinegdb.com/online_c_compiler was used as a compiler when away from my home system
// https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Cipher_block_chaining_(CBC) will be used for chaining
int main()
{
    int num_rounds = 14;
    int size_key_in_words = 8;
   
    /*
    unsigned char key[32] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                             0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                             0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7,
                             0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF};
    unsigned char pt[16]  = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
                             0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF};
    */
    unsigned char pt[16];
    for(int index = 0; index < 16; index++){
        pt[index] = 0xFF & rand();
    }
    unsigned char key[size_key_in_words * 4];
    for(int index = 0; index < size_key_in_words*4; index++){
        key[index] = 0xFF & rand();
    }
   
    unsigned char exp_key[16 * (num_rounds + 1)];
    unsigned char ct[16];
    unsigned char pt_result[16];
    printf("\nInput plaintext: ");
    for(int index = 0; index < 16; index++){
        printf("%02x", pt[index]);  
    }
    printf("\nInput key: ");
    for(int index = 0; index < size_key_in_words*4; index++){
        printf("%02x", key[index]);  
    }
    key_expansion(key, exp_key, size_key_in_words, num_rounds);
    printf("\n\nExpanded key: ");
    for(int index = 0; index < 16 * (num_rounds + 1); index++){
        printf("%02x", exp_key[index]);  
    }
    encrypt_aes(pt, ct, exp_key, num_rounds);
    printf("\n\nCiphertext: ");
    for(int index = 0; index < 16; index++){
        printf("%02x", ct[index]);  
    }
    decrypt_aes(ct, pt_result, exp_key, num_rounds);
    printf("\n\nOutput plaintext: ");
    for(int index = 0; index < 16; index++){
        printf("%02x", pt_result[index]);  
    }
}