--no parity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tx is 
generic(
	baud_rate: integer:=9600;
	frequency: integer:=1 --in Mhz
);
port(
	clk,rst: in std_logic;
	D:in std_logic_vector(7 downto 0);
	O,done:out std_logic
);end Tx;

architecture arch of Tx is 

type my_state is (idle,start,d0,d1,d2,d3,d4,d5,d6,d7,finish);
signal state:my_state;
--the baud rate is the numbers of samples per second that are sent
--according to shanon nyquist theorem:
--the sampling frequency is twice that of the highest frequency of the system
--if we want baud rate of 9600 the input clock of the system must be more that 2*(baud rate)
--here the coefficient for the input frequency is chosen to be 16.
--this case is named oversampling, making the data more robust to noise.
constant samples:integer :=frequency*(10**6)/(16*baud_rate);
signal counter:integer range 0 to samples;
signal registered: std_logic_vector(7 downto 0);
begin 

process(clk,rst,state)
begin 
if rst='1' then state<=idle;counter<=(0);registered<=(OTHERS=>'0');
elsif clk'event and clk='1' then 
	if(counter<samples-1) then counter<=counter+1; else counter<=0;end if;
	case state is 
	when idle=>o<='1';if(counter<samples-1) then null; else state<=start;end if;
	when start=>o<='0';if(counter<samples-1) then null; else registered<=D;state<=d0;end if;
	when d0=>if(counter<samples-1) then o<=registered(0); else state<=d1;end if;
	when d1=>if(counter<samples-1) then o<=registered(1); else state<=d2;end if;
	when d2=>if(counter<samples-1) then o<=registered(2); else state<=d3;end if;
	when d3=>if(counter<samples-1) then o<=registered(3); else state<=d4;end if;
	when d4=>if(counter<samples-1) then o<=registered(4); else state<=d5;end if;
	when d5=>if(counter<samples-1) then o<=registered(7); else state<=d6;end if;
	when d6=>if(counter<samples-1) then o<=registered(6); else state<=d7;end if;
	when d7=>if(counter<samples-1) then o<=registered(7); else state<=finish;end if;
	when finish=>o<='1';if(counter<samples-1) then null; else state<=idle;end if;
end case;
end if;
end process;

done<='1' when state=finish else '0';

end arch;