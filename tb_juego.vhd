--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:48:55 12/01/2018
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
USE ieee.std_logic_textio.all;
USE std.textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
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
   constant frame_period : time := 8 ms;
 
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
		left <= '1';
      -- insert stimulus here 

      wait;
   end process;

	process (clk)
    file file_pointer: text is out "write.txt";
    variable line_el: line;
begin

    if rising_edge(clk) then

        -- Write the time
        write(line_el, now); -- write the line.
        write(line_el, ":"); -- write the line.

        -- Write the hsync
        write(line_el, " ");
        write(line_el, HS); -- write the line.

        -- Write the vsync
        write(line_el, " ");
        write(line_el, VS); -- write the line.

        -- Write the red
        write(line_el, " ");
        write(line_el, RGBout(7 downto 5)); -- write the line.

        -- Write the green
        write(line_el, " ");
        write(line_el, RGBout(4 downto 2)); -- write the line.

        -- Write the blue
        write(line_el, " ");
        write(line_el, RGBout(1 downto 0)); -- write the line.

        writeline(file_pointer, line_el); -- write the contents into the file.

    end if;
end process;

END;
