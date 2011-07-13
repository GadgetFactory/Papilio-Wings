library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
    Port ( clk			: in  STD_LOGIC;
			  tv_ground	: out STD_LOGIC;
           video_out	: out STD_LOGIC_VECTOR (5 downto 0);
           audio_out	: out STD_LOGIC);
end main;

architecture Behavioral of main is

	component clock8 is
   port (CLKIN_IN        : in    std_logic; 
			CLKFX_OUT       : out   std_logic; 
			CLKIN_IBUFG_OUT : out   std_logic; 
			CLK0_OUT        : out   std_logic);
	end component;

	component clock64 is
   port (CLKIN_IN        : in    std_logic; 
			CLKFX_OUT       : out   std_logic;
			CLK0_OUT        : out   std_logic);
	end component;
 
	COMPONENT pal_video
	Port (clk				: in  std_logic;
			line_visible	: out std_logic;
			line_even		: out std_logic;
			sync				: out std_logic;
			color				: out std_logic_vector(5 downto 0));
	END COMPONENT;
    
	component pal_encoder is
   Port (clk			: in  STD_LOGIC;
			sync			: in  STD_LOGIC;
			line_visible: in  STD_LOGIC;
			line_even	: in  STD_LOGIC;
			color			: in  STD_LOGIC_VECTOR (5 downto 0);
			output		: out STD_LOGIC_VECTOR (5 downto 0));
	end component;
 
	COMPONENT ntsc_video
	Port (clk				: in  std_logic;
			line_visible	: out std_logic;
			line_even		: out std_logic;
			sync				: out std_logic;
			color				: out std_logic_vector(5 downto 0));
	END COMPONENT;
    
	component ntsc_encoder is
   Port (clk			: in  STD_LOGIC;
			sync			: in  STD_LOGIC;
			line_visible: in  STD_LOGIC;
			line_even	: in  STD_LOGIC;
			color			: in  STD_LOGIC_VECTOR (5 downto 0);
			output		: out STD_LOGIC_VECTOR (5 downto 0));
	end component;
	
	signal clk8		: std_logic;
	signal clk32	: std_logic;
	signal clk64	: std_logic;

 	--Outputs
   signal line_visible : std_logic;
   signal line_even : std_logic;
   signal sync : std_logic;
   signal color : std_logic_vector(5 downto 0);
   signal output : std_logic_vector(5 downto 0);
	
	signal counter : unsigned(15 downto 0) := (others=>'0');
	signal sound : std_logic := '0';
begin

	clock8_inst: clock8 port map (
		clkin_in=>clk,
		clk0_out=>clk32,
		clkfx_out=>clk8);
		
	clock64_inst: clock64 port map (
		clkin_in=>clk32,
		clkfx_out=>clk64);
		
   video_inst: ntsc_video PORT MAP (
		clk => clk8,
		line_visible => line_visible,
		line_even => line_even,
		sync => sync,
		color => color
   );

	encoder_inst:	ntsc_encoder port map (
		clk => clk64,
		line_visible => line_visible,
		line_even => line_even,
		sync => sync,
		color => color,
		output => video_out(5 downto 0)
	);
	
	tv_ground <= '0';
	
	process (clk32)
	begin
		if rising_edge(clk32) then
			if (counter=36363) then
				sound <= not sound;
				counter <= (others=>'0');
			else
				counter <= counter+1;
			end if;
		end if;
	end process;
	audio_out <= sound;
	
end Behavioral;

