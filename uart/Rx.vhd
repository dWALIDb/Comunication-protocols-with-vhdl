--no parity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rx is 
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
);end Rx;

architecture arch of Rx is 

type my_state is (idle,start,filler,d0,d1,d2,d3,d4,d5,d6,d7,finish);
signal state:my_state;
--the baud rate is the numbers of samples per second that are sent
--according to shanon nyquist theorem:
--the sampling frequency is twice that of the highest frequency of the system
--if we want baud rate of 9600 the input clock of the system must be more that 2*(baud rate)
--this case is named oversampling, making the data more robust to noise.
constant samples:integer:= (frequency*(10**6)/(baud_rate))-1;--calculation starts from 0
signal counter:unsigned(31 downto 0):=(others=>'0');
signal registered: std_logic_vector(7 downto 0);
begin 

process(clk,rst,state)
begin 
if rst='1' then state<=idle;counter<=(others=>'0');registered<=(others=>'0');
elsif clk'event and clk='1' then 
	counter<=counter+1;
	case state is 
	when idle=>if(D='0') then state<=start;counter<=(others=>'0');end if;
	when start=>if(counter=samples/2 and D='0') then state<=filler;
					elsif(D='1') then state<=idle;end if;
	when filler=>if(counter=samples) then state<=d0;counter<=(others=>'0');end if;
	when d0=>if(counter=samples/2)then registered(0)<=D;
				elsif(counter=samples) then state<=d1;counter<=(others=>'0');end if;
	when d1=>if(counter=samples/2)then registered(1)<=D;
				elsif(counter=samples) then state<=d2;counter<=(others=>'0');end if;
	when d2=>if(counter=samples/2)then registered(2)<=D;
				elsif(counter=samples) then state<=d3;counter<=(others=>'0');end if;
	when d3=>if(counter=samples/2)then registered(3)<=D;
				elsif(counter=samples) then state<=d4;counter<=(others=>'0');end if;
	when d4=>if(counter=samples/2)then registered(4)<=D;
				elsif(counter=samples) then state<=d5;counter<=(others=>'0');end if;
	when d5=>if(counter=samples/2)then registered(5)<=D;
				elsif(counter=samples) then state<=d6;counter<=(others=>'0');end if;
	when d6=>if(counter=samples/2)then registered(6)<=D;
				elsif(counter=samples) then state<=d7;counter<=(others=>'0');end if;
	when d7=>if(counter=samples/2)then registered(7)<=D;
				elsif(counter=samples) then state<=finish;counter<=(others=>'0');end if;
	when finish=>if(counter=samples) then state<=idle; counter<=(others=>'0');end if;
	end case;
end if;
end process;

O<=registered;
done<='1' when state=finish else '0';
count<=std_logic_vector(counter);
end arch;