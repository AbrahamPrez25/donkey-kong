----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:44:28 12/04/2018 
-- Design Name: 
-- Module Name:    control - Behavioral 
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

entity control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0);
			  sobre_plataforma : out STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobrePlat, p_sobrePlat : STD_LOGIC;
signal p_RGBin : STD_LOGIC_VECTOR (7 downto 0);
begin
sobre_plataforma <= sobrePlat;

sinc : process(clk, reset)
begin

	if(reset = '1') then
		sobrePlat <= '0';
		RGBin <= (others => '0');
	elsif(rising_edge(clk)) then
		sobrePlat <= p_sobrePlat;
		RGBin <= p_RGBin;
	end if;
end process;

comb : process(RGBm,RGBs,sobrePlat)
begin
	if( not (RGBm = "00000000"))then --Prioridad a pintar el mario
		p_RGBin <= RGBm;
	else
		p_RGBin <= RGBs;
	end if;
	
	if( (RGBm = "00011111" and RGBs = "00001100") or (RGBm = "00011111" and RGBs = "11100010")) then
		p_sobrePlat <= '1';
	elsif( RGBm = "00011111" and RGBs = "00000000") then
		p_sobrePlat <= '0';
	else
		p_sobrePlat <= sobrePlat;
	end if;
end process;

end Behavioral;

