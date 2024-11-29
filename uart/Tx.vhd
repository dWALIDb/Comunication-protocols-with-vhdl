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
	clk,rst,send: in std_logic;
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
begin 

process(clk,rst,state)
begin 
if rst='1' then state<=idle;counter<=(0);
elsif clk'event and clk='1' then 
	if(counter<samples-1) then counter<=counter+1; else counter<=0;end if;
	case state is 
	when idle=>if(send='1') then state<=start; else counter<=0;end if;
	when start=>if(counter=samples-1) then state<=d0;end if;
	when d0=>if(counter=samples-1) then state<=d1;end if;
	when d1=>if(counter=samples-1) then state<=d2;end if;
	when d2=>if(counter=samples-1) then state<=d3;end if;
	when d3=>if(counter=samples-1) then state<=d4;end if;
	when d4=>if(counter=samples-1) then state<=d5;end if;
	when d5=>if(counter=samples-1) then state<=d6;end if;
	when d6=>if(counter=samples-1) then state<=d7;end if;
	when d7=>if(counter=samples-1) then state<=finish;end if;
	when finish=>if(counter=samples-1) then state<=idle;end if;
end case;
end if;
end process;

O<='1' when state=idle or state=finish else
	'0' when state=start else
	d(0) when state=d0 else 
	d(1) when state=d1 else
	d(2) when state=d2 else
	d(3) when state=d3 else
	d(4) when state=d4 else
	d(5) when state=d5 else
	d(6) when state=d6 else
	d(7) when state=d7 else '1' ;
	
done<='1' when state=finish else '0';

end arch;
