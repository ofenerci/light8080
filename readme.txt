
The test programs have been assembled with TASM (Telemark Cross Assembler), 
a free assembler available for DOS and Linux.

A few Modelsim simulation scripts are included to assist in running the test
benches with that simulator. They are in the synthesis directory.
The scripts expect that Modelsim's current directory is the synthesis directory.
(you can change the working directory with 'File'->'change directory').
If you don't use Modelsim standalone but from within an IDE, there's a couple
of independent scripts to help you organize the test signals.

A CP/M port for a Cyclone 2 starter board will eventually be included as a demo. 
It is still incomplete (a lot of necessary files haven't yet been uploaded to 
SVN) and unfinished.


FILE LIST
==========

vhdl\light8080.vhdl                     Core source (single file)

vhdl\test\light8080_tb0.vhdl            Test bench 0 (Kelly test)
vhdl\test\light8080_tb1.vhdl            Test bench 1 (Interrupts)

vhdl\demo\cs2b_4kbasic_cpu.vhdl         altair 4K Basic demo on DE-1 board
vhdl\demo\cs2b_4kbasic_rom.vhdl         ROM/RAM for 4K Basic demo
vhdl\demo\rs232_tx.vhdl                 Serial tx code for demo
vhdl\demo\rs232_rx.vhdl                 Serial rx code for demo
vhdl\demo\c2sb_4kbasic.csv              Pin assignment file for Quartus II

util\uasm.pl                            Microcode assembler
util\microrom.bat                       Sample DOS bat file for assembler

ucode\light8080.m80                     Microcode source file

synthesis\sim_tb0.do                    Modelsim script for test bench 0
synthesis\sim_tb1.do                    Modelsim script for test bench 1
synthesis\tb0_modelsim_wave.do          Script with wave format and colors, tb0
synthesis\tb1_modelsim_wave.do          Script with wave format and colors, tb1

doc\designNotes.tex                     Core documentation in LaTeX format
doc\designNotes.pdf                     Core documentation in PDF format

asm\tb0.asm                             Test bench 0 program assembler source
asm\tb1.asm                             Test bench 1 program assembler source
asm\hexconv.pl                          Intel HEX to VHDL converter
asm\tasmtb.bat                          BATCH script to build the test benches
asm\readme.txt                          How to assemble the sources

verilog\rtl\                                contains the Verilog files of the light8080 CPU and SOC
verilog\bench\                          Verilog light8080 SOC testbench 
verilog\sim\icarus                      files used for Verilog simulation using Icaru Verilog 
verilog\syn\altera_c2                   Altera Quartus project file ucing Cyclone II FPGA 
verilog\syn\xilinx_s3                   Xilinx ISE project file ucing Spartan 3 FPGA 

c\                                      Hello World Small-C light8080 SOC sample 

tools\c80\                              C80 compiler and AS80 assembler tools used to compile 
                                        the C example program. The c80.exe executable was compiled 
                                        using tcc (Tiny C Compiler).

tools\ihex2vlog\                        Intel HEX to Verilog tool used to generate the Verilog 
                                        program & RAM memory file used by the verilog SOC. 
                                        The ihex2vlog.exe executable was compiled using tcc 
                                        (Tiny C Compiler).
