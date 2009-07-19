
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

vhdl\demo\cs2b_cpm_cpu.vhdl             CP/M on SD for Cyclone 2 starter board
vhdl\demo\cs2b_cpm_rom.vhdl             Bootloader for the CP/M demo
vhdl\demo\rs232_tx.vhdl                 Serial tx code for demo
vhdl\demo\rs232_rx.vhdl                 Serial rx code for demo
vhdl\demo\c2sb_cpm.csv                  Pin assignment file for Quartus II

util\uasm.pl                            Microcode assembler
util\microrom.bat                       Sample DOS bat file for assembler

ucode\light8080.m80                     Microcode source file

synthesis\sim_tb0.do                    Modelsim script for test bench 0
synthesis\sim_tb1.do                    Modelsim script for test bench 1
synthesis\tb0_modelsim_wave.do          Script with wave format and colors, tb0
synthesis\tb1_modelsim_wave.do          Script with wave format and colors, tb1

doc\designNotes.tex                     Core documentation in LaTeX format
doc\designNotes.pdf                     Core documentation in PDF format
doc\IMSAI SCS-1 Manual.pdf              IMSAI SCS-1 original documentation

asm\tb0.asm                             Test bench 0 program assembler source
asm\tb1.asm                             Test bench 1 program assembler source
asm\hexconv.pl                          Intel HEX to VHDL converter
asm\tasmtb.bat                          BATCH script to build the test benches
asm\readme.txt                          How to assemble the sources
