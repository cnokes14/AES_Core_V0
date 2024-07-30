**Overview.** An *Advanced Encryption Standard* (AES) core written in SystemVerilog. Capable of encrypting and decrypting data at AES-128, AES-192, and AES-256 standards, and has the (mostly untested) capability to do custom rates (IE: 160 bit key, 128 bit key with 14 rounds, etc.). It also features a cipher-block-chaining (CBC) mode, though this is not completely functional. Key expansion takes four cycles for every round needed; encryption and decryption both take a number of cycles equal to the number of rounds. Each FIFO block (encryption input, encryption output, decryption input, decryption output) has 1KB of memory (128 bit plaintext x 64 entries).

Some possible future objectives (in no particular order):

1. Create a more elaborate testing mechanism, possibly using UVM.
2. Complete documentation, both in code (IE: how and why certain design choices were made, and what certain submodules do) and outside of it (IE: how to use the core).
3. Test non-standard round counts and key sizes, make possible expansions to them.
4. Fully test and fix CBC mode.
5. Standardize format (variable naming, spacing, file naming, etc.).
6. Add more status registers (IE: is it safe to read output FIFO / write input FIFO? Etc.)
7. Expand or make generic certain sizing elements (max key size (currently 256 bits), max number of rounds (currently 15), etc.)

**Personal Commentary.** This project was made during down-time between projects at an internship, as a way of refreshing myself on RTL design and introducing myself to cryptography (a course I'll be taking this upcoming fall). The actual project took about a week of on-and-off work, with a bit of extra time spent neatening things up before making this repository public (originally, the entire codebase was in one, ~1100 line long file that I would run on EDAPlayground). A prototype C file was also created to get myself used to the encryption, decryption, and key expansion processes in an environment I have more experience in. The main challenges were the finite field theory--which was easy to implement, but hard to grasp--and dealing with certain timing elements (data leaving a cycle too early, a cycle too late, etc.).

**Images.** These are mostly just for the sake of having pretty pictures, since there's too much going on for images of this scale to be useful.

Vivado Wave Output:

![image](https://github.com/user-attachments/assets/cdf72534-1d13-4513-b76c-6037c5f366af)


Top-level Elaborated View:

![image](https://github.com/user-attachments/assets/13fbffd7-1cd5-4b0c-9f54-4592cf7e9e6a)

Encryption Path Elaborated View:

![image](https://github.com/user-attachments/assets/2233851a-a5da-41cb-b15a-a07f9dca394e)

Encryption Block Elaborated View:

![image](https://github.com/user-attachments/assets/13332ed9-4f61-4ccd-963b-3996b0659443)

Decryption Path Elaborated View:

![image](https://github.com/user-attachments/assets/9305c9f6-e970-419e-b299-3272f64e6ae9)

Decryption Block Elaborated View:

![image](https://github.com/user-attachments/assets/f357dcec-0645-4882-a30c-e00e79082aed)

First-In-First-Out Module Elaborated View:

![image](https://github.com/user-attachments/assets/c469f91a-8c0c-496f-a241-56c12ee3a796)

Key Expansion Module Elaborated View:

![image](https://github.com/user-attachments/assets/06b626ef-b571-4403-ab60-fc38025b3d34)

Register Array Elaborated View:

![image](https://github.com/user-attachments/assets/0c61a40a-d9ea-45d2-8eb6-7e35db37500a)


**Disclaimer.** This is just a little side project made by an undergraduate student. *PLEASE* DO NOT USE THIS IN PRODUCTION. If you do, it's your problem.
