----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:06:25 12/01/2018 
-- Design Name: 
-- Module Name:    mario - Behavioral 
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

entity mario is
    Port ( left : in  STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBm : out  STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC);
end mario;

architecture Behavioral of mario is

constant posx : unsigned(9 downto 0):=to_unsigned(200,10);
constant posy : unsigned(9 downto 0):=to_unsigned(200,10);

begin

repr : process(eje_x,eje_y)
begin
	if( (posx >= unsigned(eje_x)) and (posx < (unsigned(eje_x)+to_unsigned(32,10))) and (posy >= unsigned(eje_y)) and (posy < unsigned(eje_y)+to_unsigned(32,10))) then
		RGBm<="11100000";
	else
		RGBm<="00000000";
	end if;

end process;
end Behavioral;

