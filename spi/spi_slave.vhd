library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is 
generic(
	cpol:std_logic:='0';
	cpha:std_logic:='0'
);
port(
	clk,rst,ss:in std_logic;
	D:in std_logic_vector(7 downto 0);
	mosi:in std_logic;
	miso:out std_logic;
	rx_done,tx_done:out std_logic;
	O:out std_logic_vector(7 downto 0)
);end spi_slave;

architecture arch of spi_slave is 

type tx_states is (d0,d1,d2,d3,d4,d5,d6,d7);
type rx_states is (d0,d1,d2,d3,d4,d5,d6,d7);

signal tx :tx_states;
signal rx :rx_states;

signal registered_rx:std_logic_vector(7 downto 0);
--divide input clock because of shanon theorem fs>2f
--so system clock (input clock must be >=2*SCLK)
-- from what i understand, the sampling rate is 

begin

--transmition of the signal
process(clk,rst,ss)
begin
if (rst='1' or ss='1') then tx<=d0;
elsif(clk'event and clk=(cpol xnor cpha)) then
	case tx is 
	when d0=>tx<=d1;
	when d1=>tx<=d2;
	when d2=>tx<=d3;
	when d3=>tx<=d4;
	when d4=>tx<=d5;
	when d5=>tx<=d6;
	when d6=>tx<=d7;
	when d7=>tx<=d0;
	end case;
	end if;
end process;
		
		
miso<=D(0) when tx=d0 else
		D(1) when tx=d1 else
		D(2) when tx=d2 else
		D(3) when tx=d3 else
		D(4) when tx=d4 else 
		D(5) when tx=d5 else 
		D(6) when tx=d6 else 
		D(7) when tx=d7 else '0';
	
tx_done<='1' when tx=d7 else '0';

--reception of the signal
process(clk,rst,ss)
begin
if(rst='1' or ss='1')then rx<=d0; 
elsif(clk'event and clk=(cpol xnor cpha)) then
	case rx is 
	when d0=>registered_rx(0)<=mosi;rx<=d1;
	when d1=>registered_rx(1)<=mosi;rx<=d2;
	when d2=>registered_rx(2)<=mosi;rx<=d3;
	when d3=>registered_rx(3)<=mosi;rx<=d4;
	when d4=>registered_rx(4)<=mosi;rx<=d5;
	when d5=>registered_rx(5)<=mosi;rx<=d6;
	when d6=>registered_rx(6)<=mosi;rx<=d7;
	when d7=>registered_rx(7)<=mosi;rx<=d0;
end case;
end if;
end process;

rx_done<='1' when rx=d7 else '0';

O<=registered_rx;

end arch;
