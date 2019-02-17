--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:39:01 02/13/2019
-- Design Name:   
-- Module Name:   C:/Users/Abraham/Desktop/Trabajo_electronica/donkey_kong/tb_juego.vhd
-- Project Name:  donkey_kong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: juego
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
LIBRARY ieee,std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.all;
USE std.textio.all;
 
ENTITY tb_juego IS
END tb_juego;
 
ARCHITECTURE behavior OF tb_juego IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT juego
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         left : IN  std_logic;
         right : IN  std_logic;
         up : IN  std_logic;
         down : IN  std_logic;
         jump : IN  std_logic;
         HS : OUT  std_logic;
         VS : OUT  std_logic;
         RGBout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
	 COMPONENT vga_monitor is
		generic (
			NR: integer := 3; -- Number of bits of red bus
			NG: integer := 3; -- Number of bits of green bus
			NB: integer := 2 ); -- Number of bits of blue bus
		Port (
			clk : in  STD_LOGIC; -- Clock
			hs : in  STD_LOGIC; -- Horizontal Sync. Active low. 
			vs : in  STD_LOGIC; -- Vertical Sync. Active low.
			R : in  STD_LOGIC_VECTOR (NR-1 downto 0); -- red
			G : in  STD_LOGIC_VECTOR (NG-1 downto 0); -- green
			B : in  STD_LOGIC_VECTOR (NB-1 downto 0)); -- blue
	end component;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal left : std_logic := '0';
   signal right : std_logic := '0';
   signal up : std_logic := '0';
   signal down : std_logic := '0';
   signal jump : std_logic := '0';

 	--Outputs
   signal HS : std_logic;
   signal VS : std_logic;
   signal RGBout : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: juego PORT MAP (
          clk => clk,
          reset => reset,
          left => left,
          right => right,
          up => up,
          down => down,
          jump => jump,
          HS => HS,
          VS => VS,
          RGBout => RGBout
        );

	monitor: vga_monitor PORT MAP (
			clk => clk, -- Clock
			hs => HS, -- Horizontal Sync. Active low. 
			vs => VS, -- Vertical Sync. Active low.
			R => RGBout(7 downto 5), -- red
			G => RGBout(4 downto 2), -- green
			B => RGBout(1 downto 0)); -- blue

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
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;
END;
