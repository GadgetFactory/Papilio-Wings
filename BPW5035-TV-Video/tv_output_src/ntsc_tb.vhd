--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:00:17 07/12/2011
-- Design Name:   
-- Module Name:   /home/ben/prog/vhdl/tv_output/ntsc_tb.vhd
-- Project Name:  tv_output
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ntsc_video
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ntsc_tb IS
END ntsc_tb;
 
ARCHITECTURE behavior OF ntsc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ntsc_video
    PORT(
         clk : IN  std_logic;
         line_visible : OUT  std_logic;
         line_even : OUT  std_logic;
         sync : OUT  std_logic;
         color : OUT  std_logic_vector(5 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';

 	--Outputs
   signal line_visible : std_logic;
   signal line_even : std_logic;
   signal sync : std_logic;
   signal color : std_logic_vector(5 downto 0);

   -- Clock period definitions
   constant clk_period : time := 125 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ntsc_video PORT MAP (
          clk => clk,
          line_visible => line_visible,
          line_even => line_even,
          sync => sync,
          color => color
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
