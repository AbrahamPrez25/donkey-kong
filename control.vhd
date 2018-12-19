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
			  RGBb : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0);
			  --aparece : out STD_LOGIC;
			  sobre_plataforma_m : out STD_LOGIC;
			  sobre_plataforma_i : out STD_LOGIC;
			  sobre_plataforma_d : out STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobrePlat_m,p_sobrePlat_m,sobrePlat_i, p_sobrePlat_i,sobrePlat_d, p_sobrePlat_d : STD_LOGIC;
signal p_RGBin : STD_LOGIC_VECTOR (7 downto 0);
begin

--aparece <= '1';
sobre_plataforma_m <= sobrePlat_m;
sobre_plataforma_i <= sobrePlat_i;
sobre_plataforma_d <= sobrePlat_d;

sinc : process(clk, reset)
begin

	if(reset = '1') then
		sobrePlat_m <= '0';
		sobrePlat_i <= '0';
		sobrePlat_d <= '0';
		RGBin <= (others => '0');
	elsif(rising_edge(clk)) then
		sobrePlat_m <= p_sobrePlat_m;
		sobrePlat_i <= p_sobrePlat_i;
		sobrePlat_d <= p_sobrePlat_d;
		RGBin <= p_RGBin;
	end if;
end process;

comb : process(RGBm,RGBs,RGBb,sobrePlat_m,sobrePlat_i,sobrePlat_d)
begin
	if( not (RGBm = "00000000"))then --Prioridad a pintar el mario
		p_RGBin <= RGBm;
	elsif( not (RGBb = "00000000"))then
		p_RGBin <= RGBb;
	else
		p_RGBin <= RGBs;
	end if;
	
	if(RGBb = "00011111" and RGBs = "00001100") then
		p_sobrePlat_d <= '0';
		p_sobrePlat_i <= '1';
	elsif(RGBb = "00011111" and RGBs = "11100010") then
		p_sobrePlat_d <= '1';
		p_sobrePlat_i <= '0';
	elsif( RGBb = "00011111" and RGBs = "00000000") then
		p_sobrePlat_i <= '0';
		p_sobrePlat_d <= '0';
	else
		p_sobrePlat_i <= sobrePlat_i;
		p_sobrePlat_d <= sobrePlat_d;
	end if;
	
	if( (RGBm = "00011111" and RGBs = "00001100") or (RGBm = "00011111" and RGBs = "11100010")) then
		p_sobrePlat_m <= '1';
	elsif( RGBm = "00011111" and RGBs = "00000000") then
		p_sobrePlat_m <= '0';
	else
		p_sobrePlat_m <= sobrePlat_m;
	end if;
	
end process;

end Behavioral;

