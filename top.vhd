-- Engineer: 	   Serkan Kavak
-- Create Date:    13:48:05 12/10/2017 
-- Design Name:	   Vending Machine
-- Module Name:    top - Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
Port(
		clk, reset : in std_logic;
		item_select : in std_logic_vector (1 downto 0);
		request : in std_logic;
		one_tl : in std_logic;
		take_item : in std_logic;
		
		leds : out std_logic;
		seg_out, seg_sel : out std_logic_vector (7 downto 0)
);
end top;

architecture Behavioral of top is

component Converter_1HZ is
Port( clk : in STD_LOGIC;
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

signal one_hz_clock : std_logic;

-- Seven Segment Signals
signal in1, in2 : std_logic_vector (3 downto 0);
signal dp : std_logic;
signal seg_sel_4 : std_logic_vector (3 downto 0);
signal seg_out_7 : std_logic_vector (6 downto 0);

-- LED Signal
signal state_reg_led: std_logic;

signal state_out: std_logic_vector (3 downto 0);

type state_type is
	(Water, Chocolate , Coke, Cookies, state_reset,
		Chocolate_1, Coke_1, Coke_2, 
		Cookies_1, Cookies_2, Cookies_3, 
		state_result, state_take );
		
signal state_reg, state_next : state_type;


begin

-- 100MHz to 1Hz
Convert_to_1Hz : Converter_1HZ
	Port map(clk => clk, enable=> '1', clock_out=>one_hz_clock);


-- STATE REGISTER
Process(one_hz_clock, reset)
	begin
		if(reset ='1') then
			state_reg <= state_reset;

		elsif (one_hz_clock'event and one_hz_clock = '1') then
			state_reg <= state_next;
		end if;
	end process;


---- INPUT LOGIC
Process(one_hz_clock, state_reg, item_select, one_tl, request)
	begin
	if (one_hz_clock'event and one_hz_clock = '1') then
		case state_reg is
			when Water=> 
				if one_tl = '1' then
					state_next <= state_result;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Water;
				end if;
				
			when Chocolate=> 
				if one_tl = '1' then
					state_next <= Chocolate_1;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Chocolate;
				end if;
				
			when Chocolate_1=>
				if one_tl = '1' then
					state_next <= state_result;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Chocolate_1;
				end if;
			
			when Coke=>
				if one_tl = '1' then
					state_next <= Coke_1;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Coke;
				end if;
				
			when Coke_1=>
				if one_tl ='1' then 
					state_next <= Coke_2;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Coke_1;
				end if;
					
			when Coke_2=>
				if one_tl ='1' then 
					state_next <= state_result;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Coke_2;
				end if;
					
			when Cookies=>
				if one_tl ='1' then 
					state_next <= Cookies_1;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Cookies;
				end if;
					
			when Cookies_1=>
				if one_tl ='1' then 
					state_next <= Cookies_2;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Cookies_1;
				end if;
					
			when Cookies_2=>
				if one_tl ='1' then 
					state_next <= Cookies_3;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Cookies_2;
				end if;
			
			when Cookies_3=>
				if one_tl ='1' then 
					state_next <= state_result;
					in1 <= std_logic_vector( unsigned(in1) +1);
				else 
					state_next <= Cookies_3;
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
		end case;
	
	end if;
			
end process;
	
	
Seven_segment : seven_four
	Port map(in1 => in1, in2 => "0000", in3=>in2, in4=>"0000", clk=>clk, dp=>dp, sel=>seg_sel_4, segment=>seg_out_7);

-- Seven segment related part
seg_out <= (seg_out_7 & dp);
seg_sel <= "1111" & seg_sel_4;
	
 
state_reg_led <= '1' when state_reg = state_result 
				else '0';
 
leds <= state_reg_led;

state_out <= "0000" when (state_reg = Water) else
			 "0001" when (state_reg = Chocolate) else
			 "0010" when (state_reg = Coke) else
			 "0011" when (state_reg = Cookies) else
			 "0100" when (state_reg = state_result) else
			 "1111" when (state_reg = state_reset) else
			 "1010" ;
				 
in2 <= state_out;

end Behavioral;

