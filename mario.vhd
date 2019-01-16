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
			  sobre_plataforma : in STD_LOGIC;
			  sobre_escalera : in STD_LOGIC);
end mario;

architecture Behavioral of mario is
type tipo_estado is (WAITING,POS_UPDATE,VEL_UPDATE);

signal estado, p_estado : tipo_estado;
signal posx, posy, p_posy, p_posx : unsigned(9 downto 0);
signal goingUp, p_goingUp, jumping, p_jumping, enganchau, p_enganchau: std_logic;

signal X,Y : unsigned(9 downto 0);

constant VELX : unsigned(4 downto 0):=to_unsigned(10,5);
constant VEL_ESC : unsigned(4 downto 0):=to_unsigned(3,5);
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant MAX_POSX : unsigned(9 downto 0):=to_unsigned(639,10);
constant MAX_POSY : unsigned(9 downto 0):=to_unsigned(479,10);
constant ACEL : unsigned(4 downto 0):=to_unsigned(1,5); --Debe ser 1 para que cuando este en una plataforma solo se meta un pixel en la plataforma

signal vely,p_vely : unsigned(4 downto 0);

begin
	X <= unsigned(eje_x);
	Y <= unsigned(eje_y);
	repr : process(X,Y,posx,posy)
	begin
		if( ( X >= posx ) and ( X < (posx+to_unsigned(32,10)) ) and ( Y >= posy ) and ( Y < (posy + to_unsigned(32,10)) ) )then
			RGBm <= "11100000";
		else
			RGBm <= "00000000";
		end if;
		if( ( Y = (posy+to_unsigned(31,10)) ) and ((  X = (posx + to_unsigned(9,10)) )   or ( X = (posx + to_unsigned(21,10)) )) )then
			RGBm <= "00011111"; --Amarillo
		end if;
	end process;

	sinc : process(clk,reset)
	begin
		if(reset='1') then
			vely <= (others=>'0');
			posx <= to_unsigned(10,10);
			posy <= to_unsigned(400,10);
			estado <= WAITING;
			jumping <= '0';
			goingUp <= '0';
			enganchau <= '0';
		elsif(rising_edge(clk)) then 
			vely <= p_vely;
			posx <= p_posx;
			posy <= p_posy;
			estado<=p_estado;
			jumping <= p_jumping;
			goingUp <= p_goingUp;
			enganchau <= p_enganchau;
		end if;		
	end process;

	machine : process(estado,refresh,posx,posy,left,right,up,down,vely,sobre_plataforma,sobre_escalera,jump,jumping,goingUp,enganchau)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		p_enganchau <= enganchau;
		if(jump='1' and jumping='0')then
			p_goingUp <= '1';
			p_jumping <= '1';
			p_vely <= to_unsigned(8,5); --Velocidad inicial para que el salto mida 32 pixeles y supere el barril, q mide 16
		else
			p_goingUp <= goingUp;
			p_jumping <= jumping;
			p_vely <= vely;
		end if;
		
		case estado is
			when WAITING =>
				if (refresh='1') then
					p_estado <= POS_UPDATE;
				else
					p_estado <= WAITING;
				end if;
				
			when POS_UPDATE =>
			--Movimiento horizontal
				if(left='1' and right='1') then
					p_posx <= posx;
				elsif (right='1' and ( (posx + to_unsigned(32,10) + VELX) < MAX_POSX )) then --Se mueve para la derecha pero no se sale de la pantalla
					p_posx <= posx + VELX;
				elsif(left='1' and ((posx - VELX) > 0)) then --Se mueve para la izquierda pero no se sale de la pantalla
					p_posx <= posx - VELX;
				end if;
			--Movimiento vertical
				--Caída y salto
				
				if (sobre_escalera = '1' and up = '1') then
					p_posy <= posy - VEL_ESC;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= '1';
				elsif (sobre_escalera = '1' and down = '1') then
					p_posy <= posy + VEL_ESC;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= '1';
				elsif ( enganchau = '1' ) then
					p_posy <= posy;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= enganchau;
				elsif(goingUp = '0') then --Si va para abajo
					p_enganchau <= '0';
					if( sobre_plataforma = '0') then --No está encima de una plataforma
						p_posy <= posy + vely;
					else
						p_jumping <= '0'; --Aseguro que no estoy saltando
						p_posy <= posy-1; --Si estoy, resto un pixel para que salga poco a poco
					end if;
				else
					p_enganchau <= '0';
					if(posy > vely) then --Control de desborde de pantalla
						p_posy <= posy-vely;
					else
						p_posy <= posy;
					end if;					
				end if;
				
				p_estado <= VEL_UPDATE;
				
			when VEL_UPDATE =>
				if(goingUp = '0') then
					if (sobre_plataforma = '0') then
						if (vely < MAX_VELY) then
							p_vely <= vely + ACEL;
						end if;
					else
						p_vely <= (others => '0');
					end if;
				else
					if(vely > acel) then
						p_vely <= vely-acel;
					else
						p_vely <= (others => '0');
						p_goingUp <= '0';
					end if;
				end if;
				p_estado <= WAITING;				
		end case;
	end process;

end Behavioral;

