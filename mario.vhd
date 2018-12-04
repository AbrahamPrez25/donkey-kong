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
           refresh : in  STD_LOGIC;
			  sobre_plataforma : in STD_LOGIC);
end mario;

architecture Behavioral of mario is
type tipo_estado is (WAITING,POS_UPDATE,VEL_UPDATE);

signal estado, p_estado : tipo_estado;
signal posx, posy, p_posy, p_posx : unsigned(9 downto 0);

constant VELX : unsigned(4 downto 0):=to_unsigned(20,5);
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant MAX_POSX : unsigned(9 downto 0):=to_unsigned(639,10);
constant MAX_POSY : unsigned(9 downto 0):=to_unsigned(479,10);
constant ACEL : unsigned(4 downto 0):=to_unsigned(5,5);

signal vely,p_vely : unsigned(4 downto 0);

begin

	repr : process(eje_x,eje_y,posx,posy)
	begin
		if( (posx >= unsigned(eje_x)) and (posx < (unsigned(eje_x)+to_unsigned(32,10))) and (posy >= unsigned(eje_y)) and (posy < unsigned(eje_y)+to_unsigned(31,10))) then
			RGBm<="11100000";
		elsif( (posx >= unsigned(eje_x)) and (posx < (unsigned(eje_x)+to_unsigned(32,10))) and (posy >= unsigned(eje_y)+to_unsigned(31,10)) and (posy < unsigned(eje_y)+to_unsigned(32,10))) then
			RGBm<="00011111";
		else
			RGBm<="00000000";
		end if;
	end process;

	sinc : process(clk,reset)
	begin
		if(reset='1') then
			vely <= (others=>'0');
			posx <= to_unsigned(20,10);
			posy <= to_unsigned(358,10);
			estado <= WAITING;
		elsif(rising_edge(clk)) then 
			vely <= p_vely;
			posx <= p_posx;
			posy <= p_posy;
			estado<=p_estado;
		end if;		
	end process;

	machine : process(estado,refresh,posx,posy,left,right,vely,sobre_plataforma)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		case estado is
			when WAITING =>
				if (refresh='1') then
					p_estado <= POS_UPDATE;
				else
					p_estado <= WAITING;
				end if;
				
			when POS_UPDATE =>
				if(left='1' and right='1') then
					p_posx <= posx;
				elsif (right='1' and ( (posx + VELX) < MAX_POSX )) then --Se mueve para la derecha pero no se sale de la pantalla
					p_posx <= posx + VELX;
				elsif(left='1' and ((posx - VELX) > 0)) then --Se mueve para la izquierda pero no se sale de la pantalla
					p_posx <= posx - VELX;
				end if;
				if(  sobre_plataforma = '0') then --No está encima de una pataforma
					p_posy <= posy + vely;
				else
					p_posy <= posy-1; --Si estoy, resto un pixel para que salga poco a poco
				end if;
				p_estado <= VEL_UPDATE;
				
			when VEL_UPDATE =>
				if (sobre_plataforma = '0') then
					if (vely < MAX_VELY) then
						p_vely <= vely + ACEL;
					end if;
				else
					p_vely <= (others => '0');
				end if;
				p_estado <= WAITING;				
		end case;
	end process;

end Behavioral;

