library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Converter_1HZ is
Port(   clk : in STD_LOGIC;
		enable : in STD_LOGIC;
		clock_out : out STD_LOGIC);
end Converter_1HZ;

architecture Behavioral of Converter_1HZ is

signal count : integer :=1;
signal clock : std_logic :='0';

begin


process(clk) 
begin
	if(clk'event and clk='1') then
		if(enable = '1') then
			count <= count+1;
			if(count >= 50000000) then
			clock <= not clock;
			count <= 1;
			end if;
		end if;
	end if;
end process;
		

clock_out <= clock;

end Behavioral;

