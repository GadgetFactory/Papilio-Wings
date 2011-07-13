library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ntsc_video is
    Port(clk				: in  std_logic;
			line_visible	: out std_logic;
			line_even		: out std_logic;
			sync				: out std_logic;
			color				: out std_logic_vector(5 downto 0));
end ntsc_video;

architecture Behavioral of ntsc_video is

	signal hcount		: unsigned(8 downto 0) := (others => '0');
	signal vcount		: unsigned(8 downto 0) := (others => '0');
	
	signal in_vbl		: std_logic;
	signal screen_sync: std_logic;
	signal vbl_sync	: std_logic;
	
	signal even : std_logic := '1';
	
	type tpalette is array(7 downto 0) of std_logic_vector(5 downto 0);
	signal palette	: tpalette := (
			 0=>"111100",
			 1=>"001111",
			 2=>"001100",
			 3=>"110011",
			 4=>"110000",
			 5=>"000011",
			 6=>"000000",
			 7=>"111111");

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if hcount=507 then
				hcount <= (others => '0');
				if vcount=261 then
					vcount <= (others=>'0');
					even <= not even;
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;
	
	process (hcount)
	begin
		if hcount<38 then
			screen_sync <= '0';
		else
			screen_sync <= '1';
		end if;
	end process;
	
	process (vcount)
	begin
		if vcount>=9 and vcount<262 then
			in_vbl <= '0';
		else
			in_vbl <= '1';
		end if;
	end process;
	
	line_visible	<= not in_vbl;
	line_even		<= not vcount(0);
	
	process (vcount,hcount)
	begin
		if vcount<3 or (vcount>=6 and vcount<9) then
			-- _^^^^^_^^^^^ : low pulse = 2.35us
			if hcount<19 or (hcount>=254 and hcount<254+19) then
				vbl_sync <= '0';
			else
				vbl_sync <= '1';
			end if;
		else
			-- ____^^ : high pulse = 4.7us
			if hcount<(254-38) or (hcount>=254 and hcount<508-38) then
				vbl_sync <= '0';
			else
				vbl_sync <= '1';
			end if;
		end if;
	end process;
	
	process (in_vbl,screen_sync,vbl_sync)
	begin
		if in_vbl='1' then
			sync <= vbl_sync;
		else
			sync <= screen_sync;
		end if;
	end process;
	
	
	
	process(in_vbl,hcount,vcount,palette)
	begin
		if in_vbl='1' or hcount<(38+47) or hcount>=(38+47+412) then
			color <= "000000";

	   -- drawable screen (256*192)
		elsif in_vbl='0' and hcount>=(38+47+80) and hcount<(38+47+80+256) and vcount>=48 and vcount<(48+192) then
			color <= palette(to_integer((hcount-(38+47+80))/32));

		-- overscan
		else
			color <= "010101";
		end if;
	end process;
	
end Behavioral;
