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
			  RGBb0 : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb1 : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb2 : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBe : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0);
			  resets : out STD_LOGIC;
			  --aparece : out STD_LOGIC;
			  sobre_plataforma_m : out STD_LOGIC;
			  sobre_escalera_m : out STD_LOGIC;
			  sobre_plataforma_i : out STD_LOGIC_VECTOR (2 downto 0);
			  sobre_plataforma_d : out STD_LOGIC_VECTOR (2 downto 0));
end control;

architecture Behavioral of control is

type estado_juego is (PLAYING,WIN);

signal estado, p_estado : estado_juego;
signal sobrePlat_m, p_sobrePlat_m,sobreEsc_m, p_sobreEsc_m : STD_LOGIC;
signal sobrePlat_i, p_sobrePlat_i,sobrePlat_d, p_sobrePlat_d : STD_LOGIC_VECTOR (2 downto 0);
signal p_RGBin : STD_LOGIC_VECTOR (7 downto 0);

constant color_bloque_izq: STD_LOGIC_VECTOR(7 downto 0):="00010100"; --Verde clarete
constant color_bloque_der: STD_LOGIC_VECTOR(7 downto 0):="00001000"; --Verde oscurete
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):="11111111"; --Blanco
constant color_negro: STD_LOGIC_VECTOR(7 downto 0):="00000000"; --Negro
constant color_final: STD_LOGIC_VECTOR(7 downto 0) :="11101101"; --Naranja
constant pto_control: STD_LOGIC_VECTOR(7 downto 0) :="00011111"; --Amarillo


begin

sobre_plataforma_m <= sobrePlat_m;
sobre_escalera_m <= sobreEsc_m;
sobre_plataforma_i <= sobrePlat_i;
sobre_plataforma_d <= sobrePlat_d;

sinc : process(clk, reset)
begin

	if(reset = '1') then
		sobrePlat_m <= '0';
		sobreEsc_m <= '0';
		sobrePlat_i <= (others =>'0');
		sobrePlat_d <= (others =>'0');
		RGBin <= (others => '0');
		estado <= PLAYING;
	elsif(rising_edge(clk)) then
		sobreEsc_m <= p_sobreEsc_m;
		sobrePlat_m <= p_sobrePlat_m;
		sobrePlat_i <= p_sobrePlat_i;
		sobrePlat_d <= p_sobrePlat_d;
		RGBin <= p_RGBin;
		estado <= p_estado;
	end if;
end process;

comb : process(RGBm,RGBe,RGBs,RGBb0,RGBb1,RGBb2,sobrePlat_m,sobreEsc_m,sobrePlat_i,sobrePlat_d,estado)
begin

	case estado is 
		
		when PLAYING =>
					--Prioridad para pintar
					if( not (RGBm = color_negro))then --Primero Mario
						p_RGBin <= RGBm;
					elsif( not (RGBb0 = color_negro))then --Despues Barril0
						p_RGBin <= RGBb0;
					elsif( not (RGBb1 = color_negro))then --Despues Barril1
						p_RGBin <= RGBb1;
					elsif( not (RGBb2 = color_negro))then --Despues Barril2
						p_RGBin <= RGBb2;
					elsif( not (RGBe = color_negro))then
						p_RGBin <= RGBe;
					else
						p_RGBin <= RGBs; --Despues lo que venga
					end if;
					
					--Sobreplataforma de barril 0
					if(RGBb0 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final) ) then
						p_sobrePlat_d(0) <= '0';
						p_sobrePlat_i(0) <= '1';
					elsif(RGBb0 = pto_control and RGBs = color_bloque_der) then
						p_sobrePlat_d(0) <= '1';
						p_sobrePlat_i(0) <= '0';
					elsif( RGBb0 = pto_control and RGBs = color_negro) then
						p_sobrePlat_i(0) <= '0';
						p_sobrePlat_d(0) <= '0';
					else
						p_sobrePlat_i(0) <= sobrePlat_i(0);
						p_sobrePlat_d(0) <= sobrePlat_d(0);
					end if;
					
					--Sobreplataforma de barril 1
					if(RGBb1 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final)) then
						p_sobrePlat_d(1) <= '0';
						p_sobrePlat_i(1) <= '1';
					elsif(RGBb1 = pto_control and RGBs = color_bloque_der) then
						p_sobrePlat_d(1) <= '1';
						p_sobrePlat_i(1) <= '0';
					elsif( RGBb1 = pto_control and RGBs = color_negro) then
						p_sobrePlat_i(1) <= '0';
						p_sobrePlat_d(1) <= '0';
					else
						p_sobrePlat_i(1) <= sobrePlat_i(1);
						p_sobrePlat_d(1) <= sobrePlat_d(1);
					end if;
					
					--Sobreplataforma de barril 2	
					if(RGBb2 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final)) then
						p_sobrePlat_d(2) <= '0';
						p_sobrePlat_i(2) <= '1';
					elsif(RGBb2 = pto_control and RGBs = color_bloque_der) then
						p_sobrePlat_d(2) <= '1';
						p_sobrePlat_i(2) <= '0';
					elsif( RGBb2 = pto_control and RGBs = color_negro) then
						p_sobrePlat_i(2) <= '0';
						p_sobrePlat_d(2) <= '0';
					else
						p_sobrePlat_i(2) <= sobrePlat_i(2);
						p_sobrePlat_d(2) <= sobrePlat_d(2);
					end if;
					
					
					--Sobreplataforma de Mario
					if( (RGBm = pto_control and RGBe = color_escalera) ) then
						p_sobreEsc_m <= '1';
					elsif( (RGBm = pto_control and RGBe = color_negro) ) then
						p_sobreEsc_m <= '0';
					else
						p_sobreEsc_m <= sobreEsc_m;
					end if;
					
					if( (RGBm = pto_control and (RGBs = color_bloque_izq)) or (RGBm = "00011111" and RGBs = color_bloque_der)) then
						p_sobrePlat_m <= '1';
					elsif( RGBm = pto_control and RGBs = color_negro) then
						p_sobrePlat_m <= '0';
					else
						p_sobrePlat_m <= sobrePlat_m;
					end if;
					
					--Control de Final
					if ( RGBm = pto_control and RGBs = color_final ) then
						p_estado <= WIN;
					else
						p_estado <= estado;
					end if;
					
					--Control de muerte
					if ( (not (RGBm = color_negro)) and ( (not (RGBb0 = color_negro)) or (not (RGBb1 = color_negro)) or (not (RGBb2 = color_negro)) )) then
						resets <= '1';
					else
						resets <= '0';
					end if;
				
			when WIN =>
				p_sobreEsc_m <= sobreEsc_m;
				p_sobrePlat_m <= sobrePlat_m;
				p_sobrePlat_i <= sobrePlat_i;
				p_sobrePlat_d <= sobrePlat_d;
				p_RGBin <= color_bloque_izq;
				p_estado <= WIN;
				resets <= '0';
		end case;
end process;

end Behavioral;

