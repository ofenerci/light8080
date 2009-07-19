@rem The only parameter is the file name of the assembly source file without 
@rem extension or path (file has to be on the same dir as this script).
@set PROG=%1
@rem Edit to point to the directory you installed TASM in
@set TASM_DIR=..\local\tasm
@rem remove output from previous assembly
@del %PROG%.hex
@del %PROG%.lst
@rem make sure TASM is able to find its table files (see TASM documentation)
@set TASMTABS=..\local\tasm
%TASM_DIR%\tasm -85 -a %PROG%.asm %PROG%.hex %PROG%.lst
@rem 
@perl hexconv.pl .\%PROG%.hex ..\vhdl\test\tb_template.vhdl 000 800 > ..\vhdl\test\light8080_%PROG%.vhdl