library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is 
generic(
	cpol:std_logic:='0';
	cpha:std_logic:='0'
);
port(
	clk,rst,en:in std_logic;
	D:in std_logic_vector(7 downto 0);
	miso:in std_logic;
	sclk,mosi:out std_logic;
	rx_done,tx_done:out std_logic;
	cs:out std_logic;
	O:out std_logic_vector(7 downto 0)
);end spi_master;

architecture arch of spi_master is 

type tx_states is (idle,d0,d1,d2,d3,d4,d5,d6,d7);
type rx_states is (idle,d0,d1,d2,d3,d4,d5,d6,d7);

signal tx :tx_states;
signal rx :rx_states;

signal registered_rx:std_logic_vector(7 downto 0);
signal counter:integer range 0 to 16;--divide input clock because of shanon theorem fs>2f
--so system clock (input clock must be >=2*SCLK)
-- from what i understand, the sampling rate is 

begin

--serial clock generation
process(clk,rst)
begin 
if(rst='1')then counter<=0;
elsif(clk'event and clk='1') then if(rx/=idle or tx/=idle) then 
										if (counter<16-1)then counter<=counter+1; else counter<=0; end if;
											end if;
end if;
end process;

--serial clock generation depending on the mode of operation
sclk<=cpol when tx=idle and rx=idle else 
		cpol xor cpha when counter<=16/2 -1 else 
		cpol xnor cpha when counter>16/2 -1;
--transmition of the signal
process(clk,rst)
begin
if rst='1' then tx<=idle;
elsif(clk'event and clk=(cpol xnor cpha)) then
	case tx is 
	when idle=>if(en='1')then tx<=d0;end if;
	when d0=>if(counter=16-1) then tx<=d1;end if;
	when d1=>if(counter=16-1) then tx<=d2;end if;
	when d2=>if(counter=16-1) then tx<=d3;end if;
	when d3=>if(counter=16-1) then tx<=d4;end if;
	when d4=>if(counter=16-1) then tx<=d5;end if;
	when d5=>if(counter=16-1) then tx<=d6;end if;
	when d6=>if(counter=16-1) then tx<=d7;end if;
	when d7=>if(counter=16-1) then if (en='1')then tx<=d0;
											 else tx<=idle;end if;end if;
	end case;
	end if;
end process;
		
mosi<=D(0) when tx=d0 else
		D(1) when tx=d1 else		
		D(2) when tx=d2 else	
		D(3) when tx=d3 else		
		D(4) when tx=d4 else		
		D(5) when tx=d5 else		
		D(6) when tx=d6 else	
		D(7) when tx=d7 else '0';		
		
tx_done<='1' when tx=d7 else '0';

--reception of the signal
process(clk,rst)
begin
if(rst='1')then rx<=idle; 
elsif(clk'event and clk=(cpol xnor cpha)) then
	case rx is 
	when idle=>if(en='1') then rx<=d0;end if;
	when d0=>if(counter=16/2-1)then registered_rx(0)<=miso;
				elsif(counter=16-1)then rx<=d1; end if;
	when d1=>if(counter=16/2-1)then registered_rx(1)<=miso;
				elsif(counter=16-1)then rx<=d2; end if;
	when d2=>if(counter=16/2-1)then registered_rx(2)<=miso;
				elsif(counter=16-1)then rx<=d3; end if;
	when d3=>if(counter=16/2-1)then registered_rx(3)<=miso;
				elsif(counter=16-1)then rx<=d4; end if;
	when d4=>if(counter=16/2-1)then registered_rx(4)<=miso;
				elsif(counter=16-1)then rx<=d5; end if;
	when d5=>if(counter=16/2-1)then registered_rx(5)<=miso;
				elsif(counter=16-1)then rx<=d6; end if;
	when d6=>if(counter=16/2-1)then registered_rx(6)<=miso;
				elsif(counter=16-1)then rx<=d7; end if;
	when d7=>if(counter=16/2-1)then registered_rx(7)<=miso;
				elsif(counter=16-1)then if (en='1')then rx<=d0;
											 else rx<=idle;end if;end if;
end case;
end if;
end process;

cs<='1' when rx=idle and tx=idle else '0';

rx_done<='1' when rx=d7 else '0';

O<=registered_rx;

end arch;