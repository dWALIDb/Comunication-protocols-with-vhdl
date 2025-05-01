-- no parity
-- 8 bits 1 stop bit and 1 start bit
-- write to tx buffer with WD_TX read from rx buffer with RX_RD
-- provide address also :)
-- could use count_tx and count_rx to know if messages are sent or pending
-- cs used to enable chip to write/ recieve data  active low
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
generic(buffer_addresses: integer:=3;
	baud_rate: integer:=115200;
	frequency: integer:=50 --in Mhz
	);
port(
	clk,rst_tx,rst_rx,send,rx_in,cs,RD_RX,WD_TX: in std_logic;
	tx_buffer_in:in std_logic_vector(7 downto 0);
	tx_buffer_Waddress,rx_buffer_Raddress:in std_logic_vector(buffer_addresses-1 downto 0);
	--bytes recieved/transmitted 
	count_rx,count_tx:out std_logic_vector(buffer_addresses-1 downto 0);
	tx_out,doneTx,doneRx:out std_logic;
	rx_buffer_out:out std_logic_vector(7 downto 0)
);end uart;

architecture arch of uart is 

component Rx is 
generic(
	baud_rate: integer:=9600;
	frequency: integer:=50 --in Mhz
);
port(
	clk,rst: in std_logic;
	D:in std_logic;
	done:out std_logic;
	count:out std_logic_vector(31 downto 0);
	O:out std_logic_vector(7 downto 0)
);end component;

component Tx is 
generic(
	baud_rate: integer:=115200;
	frequency: integer:=50 --in Mhz
);
port(
	clk,rst,send: in std_logic;
	D:in std_logic_vector(7 downto 0);
	count:out std_logic_vector(31 downto 0);
	O,done:out std_logic
);end component;

component counter is 
generic( counter_width : integer:=8);
port(
	clk,rst:in std_logic;
	count: out std_logic_vector(counter_width-1 downto 0)
);end component;

component uart_buff is 
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
);end component;

signal done_recieve,done_transmit:std_logic;
signal rx_counter,tx_counter:std_logic_vector(buffer_addresses-1 downto 0);
signal tx_buffer_out,rx_buffer_in:std_logic_vector(7 downto 0);
signal b:std_logic;
begin 

doneTx<=done_transmit;
doneRx<=done_recieve;


trans:tx generic map(baud_rate,frequency) port map(clk,rst_tx,send,tx_buffer_out,open,tx_out,done_transmit);
rec:rx generic map(baud_rate,frequency) port map(clk,rst_rx,rx_in,done_recieve,open,rx_buffer_in);

--LOOP BACK TEST :) FOR NOW XD
--trans:tx generic map(1152000,50) port map(clk,rst_tx,send,tx_buffer_out,open,b,done_transmit);
--tx_out<=b;
--rec:rx generic map(1152000,50) port map(clk,rst_rx,b,done_recieve,open,rx_buffer_in);

-- reciver and transmitter counters used for addressing in the corresponding buffers
-- transmitter can only read and send when triggered and reciever only writes to buffer 
-- user does write to transmitter buffer and reads recieve buffer
URx_counter: counter generic map(buffer_addresses) port map(not done_recieve,rst_rx,rx_counter);
UTx_counter: counter generic map(buffer_addresses) port map(not done_transmit,rst_tx,tx_counter);

count_tx<=tx_counter;
count_rx<=rx_counter;
-- the buffers used to comunicate they are always enabled
rx_buffer: uart_buff generic map(buffer_addresses,"") port map(clk,RD_RX and not cs,done_recieve,'0',rx_buffer_Raddress,rx_counter,rx_buffer_in,rx_buffer_out); 
tx_buffer: uart_buff generic map(buffer_addresses,"") port map(clk,'1',WD_TX and not cs,'0',tx_counter,tx_buffer_Waddress,tx_buffer_in,tx_buffer_out); 
end arch;