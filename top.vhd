-- Create Date:    13:48:05 12/10/2017 
-- Design Name: 
-- Module Name:    top - Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
Port(
		clk, reset : in std_logic;
		
		item_select : in std_logic_vector (1 downto 0);
		
		tl_select : in std_logic_vector (2 downto 0);
		request : in std_logic;
		
		take_item : in std_logic;
		
		leds : out std_logic;
		seg_out, seg_sel : out std_logic_vector (7 downto 0)
);
end top;

architecture Behavioral of top is

component Converter_1HZ is
Port(   clk : in STD_LOGIC;
		enable : in STD_LOGIC;
		clock_out : out STD_LOGIC);
end component;

component seven_four is
    Port ( in1 : in  STD_LOGIC_VECTOR (3 downto 0);
           in2 : in  STD_LOGIC_VECTOR (3 downto 0);
           in3 : in  STD_LOGIC_VECTOR (3 downto 0);
           in4 : in  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC;
		   dp  : out  STD_LOGIC;
           sel : out  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (6 downto 0)
			);
end component;

signal one_mhz_clock : std_logic;

signal in1, in2 : std_logic_vector (3 downto 0);

signal dp : std_logic;
signal seg_sel_4 : std_logic_vector (3 downto 0);
signal seg_out_7 : std_logic_vector (6 downto 0);

signal state_reg_led: std_logic;

signal state_out: std_logic_vector (3 downto 0);

type state_type is
	(Water, Chocolate , Coke, Cookies, state_reset,
		state_result);
		
signal state_reg, state_next : state_type;


begin

Convert_to_1Hz : Converter_1HZ
	Port map(clk => clk, enable=> '1', clock_out=>one_mhz_clock);


-- STATE REGISTER
Process(one_mhz_clock, reset)
	begin
		if(reset ='1') then
			state_reg <= state_reset;
		
			
		elsif (one_mhz_clock'event and one_mhz_clock = '1') then
			state_reg <= state_next;
		end if;
		
	end process;

---- INPUT LOGIC
Process(state_reg, item_select, request)
	begin
	
	case state_reg is
		when Water=> 
			if (tl_select >= "001") then
				state_next <= state_result;
				else state_next <= Water;
			end if;
			
		when Chocolate=> 
				if (tl_select >= "010") then
				state_next <= state_result;
				else state_next <= Chocolate;
			end if;
	
		
		when Coke=>
			if (tl_select >= "011") then
				state_next <= state_result;
				else state_next <= Coke;
			end if;

		when Cookies=>
			if (tl_select >= "100") then
				state_next <= state_result;
				else state_next <= Cookies;
			end if;
			
		when state_reset=>
		  in1 <= (others=> '0');
			if request='1' then
				case item_select is
					when "00"=>
						state_next <= Water;
					when "01"=>
						state_next <= Chocolate;
					when "10"=>
						state_next <= Coke;
					when others=>
						state_next <= Cookies;
				end case;
			else state_next <= state_reset;
			end if;
			
		when state_result=>
			if take_item ='1' then
				state_next <= state_reset;
			else state_next <= state_result;
				end if;
		
	--	when state_take=>
	--		state_next <= state_reset;
			
	end case;
	
			
end process;
	
	
Seven_segment : seven_four
	Port map(in1 => in1, in2 => "0000", in3=>in2, in4=>"0000", clk=>clk, dp=>dp, sel=>seg_sel_4, segment=>seg_out_7);

-- Seven segment related part
seg_out <= (seg_out_7 & dp);
seg_sel <= "1111" & seg_sel_4;
	
 
state_reg_led <= '1' when state_reg = state_result 
				else '0';
 
leds <= state_reg_led;

--in1 <= std_logic_vector( unsigned(in1) +1) 
--	when (one_tl = '1') and (state_reg = state_result or state_reg = Chocolate_1 or state_reg = Coke_1 or
--								  state_reg = Coke_2 or state_reg = Cookies_1 or state_reg = Cookies_2 or 
--								  state_reg = Cookies_3)
--		else (others=> '0') when state_reg = state_reset
--		else in1;

state_out <= "0000" when (state_reg = Water) else
				 "0001" when (state_reg = Chocolate) else
				 "0010" when (state_reg = Coke) else
				 "0011" when (state_reg = Cookies) else
				 "0100" when (state_reg = state_result) else
				 "1111" when (state_reg = state_reset) else
				 "1010" ;
				 
in2 <= state_out;



end Behavioral;

