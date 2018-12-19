----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:26 12/04/2018 
-- Design Name: 
-- Module Name:    stage - Behavioral 
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

entity stage is
    Port ( eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR (7 downto 0));
end stage;

architecture Behavioral of stage is

constant lim_superior_1: unsigned(9 downto 0):=to_unsigned(75,10);
constant lim_inferior_1: unsigned(9 downto 0):=to_unsigned(125,10);
constant lim_izquierdo_1: unsigned(9 downto 0):=to_unsigned(110,10);
constant lim_superior_2: unsigned(9 downto 0):=to_unsigned(275,10);
constant lim_inferior_2: unsigned(9 downto 0):=to_unsigned(325,10);
constant lim_derecho_2: unsigned(9 downto 0):=to_unsigned(500,10);
constant lim_superior_3: unsigned(9 downto 0):=to_unsigned(460,10);

signal X,Y : unsigned(9 downto 0);
begin

X<=unsigned(eje_x);
Y<=unsigned(eje_y);

escenario : process(X,Y)
begin
	if ( X > lim_izquierdo_1 and Y > lim_superior_1 and Y < lim_inferior_1) then --Primer stage
		RGBs <= "00001100"; --Verde oscuro
	elsif ( X < lim_derecho_2 and Y > lim_superior_2 and Y < lim_inferior_2) then --Segundo stage
		RGBs <= "11100010"; --Rosa
	elsif ( Y > lim_superior_3 ) then --Suelo
		RGBs <= "00001100"; --Verde oscuro
	else
		RGBs <= (others => '0');
	end if;
end process;

end Behavioral;

