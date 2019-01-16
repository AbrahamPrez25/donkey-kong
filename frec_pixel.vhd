----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:14:40 11/12/2018 
-- Design Name: 
-- Module Name:    frec_pixel - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frec_pixel is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_pixel : out  STD_LOGIC);
end frec_pixel;

architecture Behavioral of frec_pixel is
signal p_clk_pixel: STD_LOGIC;
begin
p_clk_pixel <= not clk_pixel;

sinc:process(clk,reset)
begin
	if(reset='1') then
		clk_pixel<='0';
	elsif (rising_edge(clk)) then
		clk_pixel<=p_clk_pixel;
	end if;
end process;

end Behavioral;

