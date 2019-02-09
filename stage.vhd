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
			  RGBe : out  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : out  STD_LOGIC_VECTOR (7 downto 0));
end stage;

architecture Behavioral of stage is

constant grosor: unsigned(9 downto 0):=to_unsigned(15,10);
constant medio_1: unsigned(9 downto 0):=to_unsigned(115,10);
constant lim_izquierdo_1: unsigned(9 downto 0):=to_unsigned(110,10);
constant medio_2: unsigned(9 downto 0):=to_unsigned(230,10);
constant lim_derecho_2: unsigned(9 downto 0):=to_unsigned(500,10);
constant medio_3: unsigned(9 downto 0):=to_unsigned(345,10);
constant lim_izquierdo_3: unsigned(9 downto 0):=to_unsigned(100,10);
constant lim_superior_suelo: unsigned(9 downto 0):=to_unsigned(460,10);

constant grosor_escalera: unsigned(9 downto 0):=to_unsigned(20,10);
constant medio_esc_1: unsigned(9 downto 0):=to_unsigned(150,10);
constant medio_esc_2: unsigned(9 downto 0):=to_unsigned(460,10);
constant medio_esc_3: unsigned(9 downto 0):=to_unsigned(140,10);


constant color_bloque_izq: STD_LOGIC_VECTOR(7 downto 0):="00010100"; --Verde clarete
constant color_bloque_der: STD_LOGIC_VECTOR(7 downto 0):="00001000"; --Verde oscurete
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):="11111111"; --Blanco

signal X,Y : unsigned(9 downto 0);
begin

X<=unsigned(eje_x);
Y<=unsigned(eje_y);

escenario : process(X,Y)
begin
	if ( X > (medio_esc_1 - grosor_escalera) and X <= (medio_esc_1 + grosor_escalera) and Y > (medio_1 - grosor) and Y <= (medio_2 - grosor) ) then --Primera escalera
		RGBe <= color_escalera;
	elsif ( X > (medio_esc_2 - grosor_escalera) and X <= (medio_esc_2 + grosor_escalera) and Y > (medio_2 - grosor) and Y <= (medio_3 - grosor) ) then --Segunda escalera
		RGBe <= color_escalera;
	elsif ( X > (medio_esc_3 - grosor_escalera) and X <= (medio_esc_3 + grosor_escalera) and Y > (medio_3 - grosor) and Y <= lim_superior_suelo ) then --Tercera escalera
		RGBe <= color_escalera;
	else
		RGBe <= (others => '0');
	end if;
	
	if ( X > lim_izquierdo_1 and Y > (medio_1 - grosor) and Y <= (medio_1 + grosor)) then --Primer stage
		RGBs <= color_bloque_izq; --Verde oscuro
	elsif ( X < lim_derecho_2 and Y > (medio_2 - grosor) and Y <= (medio_2 + grosor)) then --Segundo stage
		RGBs <= color_bloque_der; --Rosa
	elsif ( X > lim_izquierdo_3 and Y > (medio_3 - grosor) and Y <= (medio_3 + grosor)) then --Tercer stage
		RGBs <= color_bloque_izq; --Rosa
	elsif ( Y > lim_superior_suelo ) then --Suelo
		RGBs <= color_bloque_der; --Verde oscuro
	else
		RGBs <= (others => '0');
	end if;
end process;

end Behavioral;

