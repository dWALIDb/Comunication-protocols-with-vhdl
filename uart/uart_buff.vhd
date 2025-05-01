--little endian 
--memory is byte addressable but outputs 4 bytes of memory
--example 
--0A0B0C0D in little endian is stored as follows "0D" at i "0C" at i+1 "0B" at i+2 "0A" at i+3
--one architecture is used for synthesis(mif file) and the other for simulation(txt file)
--used for instruction memory and for data memory 
--variable in process used to run the for-loop because the loops are kinda weird with signals
--used for synthesis because attributes are synthesisable but not simulatable for some reason
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;

entity uart_buff is 
generic(
		address_width:integer:=6;
		synthesis_file_directory: string:=
		"C:\Users\DELL\Desktop\fpga\RISC-V-CORE-WITH-VHDL-main\RISC-V-CORE-WITH-VHDL-main\assembler\d_mif0.mif"
);
port(--use this module to instantiate 4 rams and then write C++ code to generate the 4 initialization files :)
--i meaaan you cant complain you wanted this buddy i cant hear excuses ;)
--cs is active low 
		clk,RD,wd,cs:in std_logic;
		address_read,address_write:in std_logic_vector(address_width-1 downto 0);
		D:in std_logic_vector(7 downto 0);
		Q:out std_logic_vector(7 downto 0)
);end uart_buff;

architecture synthesis of uart_buff is

type std_logic_array is array (integer range<>) of std_logic_vector(7 downto 0);

signal ram_data: std_logic_array(2**address_width-1 downto 0);--:=init_ram_withFile(synthesis_file_directory,address_width);

attribute ram_init_file : string;
attribute ram_init_file of ram_data :signal is synthesis_file_directory;

signal output:std_logic_vector(7 downto 0);

begin 

WRITING_PROCESS:process(clk,wd,address_write,cs)
begin 
if(clk'event and clk='1') then 
if(wd='1' and cs='0') then	
	ram_data(to_integer(unsigned(address_write)))<=D;
	end if;
end if;
end process;

READING_PROCESS:process(rd,address_read,ram_data,cs)
begin
if(RD='1' and cs='0') then 

	output<=ram_data(to_integer(unsigned(address_read)));
else output<=(others=>'Z');
end if;
end process;

Q<=output;

end synthesis;