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

entity barril is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  resets : in STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBb : out  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril : out STD_LOGIC_VECTOR (7 downto 0);
			  pintar : out STD_LOGIC;
			  data_barril : in STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
			  sobre_plataforma_i : in STD_LOGIC;
			  sobre_plataforma_d : in STD_LOGIC);
end barril;

architecture Behavioral of barril is
type tipo_estado is (WAITING,FALLING,POS_UPDATE,VEL_UPDATE);

signal estado, p_estado : tipo_estado;
signal posx, posy, p_posy, p_posx : unsigned(9 downto 0);
signal movIzq,p_movIzq : std_logic; --1 si se mueve pa la izq
signal X,Y,Xaux,Yaux : unsigned(9 downto 0);

constant VELX : unsigned(4 downto 0):=to_unsigned(3,5);
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant MAX_POSX : unsigned(9 downto 0):=to_unsigned(639,10);
constant MAX_POSY : unsigned(9 downto 0):=to_unsigned(479,10);
constant ACEL : unsigned(4 downto 0):=to_unsigned(1,5); --Debe ser 1 para que cuando este en una plataforma solo se meta un pixel en la plataforma
constant POSX_INI : unsigned(9 downto 0):=to_unsigned(640,10);

signal vely,p_vely : unsigned(4 downto 0);

begin
	X<=unsigned(eje_x);
	Y<=unsigned(eje_y);
	Xaux<=unsigned(eje_x)-posx;
	Yaux<=unsigned(eje_y)-posy;
	
	addr_barril <= std_logic_vector(Yaux(3 downto 0)) & std_logic_vector(Xaux(3 downto 0));
	repr : process(X,Y,posx,posy,data_barril)
	begin
		if( ( X >= posx ) and ( X < (posx+to_unsigned(16,10)) ) and ( Y >= posy ) and ( Y < (posy + to_unsigned(16,10)) ) )then
			pintar <= '1';
			RGBb <= data_barril;
		else
			pintar <= '0';
			RGBb <= "00000000";
		end if;
		if( ( Y = (posy+to_unsigned(15,10)) ) and ((  X = posx )   or ( X = (posx + to_unsigned(15,10)) )) )then
			RGBb <= "00011111";
		end if;
	end process;

	sinc : process(clk,reset)
	begin
		if(reset='1') then
			vely <= (others=>'0');
			posx <= POSX_INI;
			posy <= (others=>'0');
			estado <= WAITING;
			movIzq <= '1';
		elsif(rising_edge(clk)) then 
			if(resets = '0') then
				vely <= p_vely;
				posx <= p_posx;
				posy <= p_posy;
				estado <= p_estado;
				movIzq <= p_movIzq;
			else
				vely <= (others=>'0');
				posx <= POSX_INI;
				posy <= (others=>'0');
				estado <= WAITING;
				movIzq <= '1';
			end if;
		end if;		
	end process;

	machine : process(estado,refresh,posx,posy,vely,sobre_plataforma_i,sobre_plataforma_d,movIzq,aparece)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		p_movIzq <= movIzq;
		
		case estado is
			when WAITING =>
				if (aparece='1') then
					p_estado <= FALLING;
				else
					p_estado <= WAITING;
				end if;
			
			when FALLING =>
				if (refresh='1') then
					p_estado <= POS_UPDATE;
				else
					p_estado <= FALLING;
				end if;
				
			when POS_UPDATE =>
				p_estado <= VEL_UPDATE;
				
			--Movimiento vertical
				if(  sobre_plataforma_i = '0' and sobre_plataforma_d = '0') then --No está encima de una plataforma
					p_posy <= posy + vely;
				elsif( sobre_plataforma_i = '1') then
					p_posy <= posy-1; --Si estoy, resto un pixel para que salga poco a poco
					p_movIzq <= '1';
				else 
					p_posy <= posy-1; --Si estoy, resto un pixel para que salga poco a poco
					p_movIzq <= '0';
				end if;
			--Movimiento horizontal
				if (movIzq='0') then --Se mueve para la derecha pero no se sale de la pantalla
					if ( ( (posx  - VELX) > 635 )) then-- and ( posx + to_unsigned(32,10) - VELX > 0 ) ) 
						p_estado <= WAITING;
						p_vely <= (others=>'0');
						p_posx <= POSX_INI;
						p_posy <= (others=>'0');
						p_movIzq <= '1';
					else	
						p_posx <= posx + VELX;
					end if;				
				elsif(movIzq='1') then --Se mueve para la izquierda pero no se sale de la pantalla
					if ( ( (posx  - VELX) > 635 ) and (posy > 200)) then-- and ( posx + to_unsigned(32,10) - VELX > 0 ) ) 
						p_estado <= WAITING;
						p_vely <= (others=>'0');
						p_posx <= POSX_INI;
						p_posy <= (others=>'0');
						p_movIzq <= '1';
					else	
						p_posx <= posx - VELX;
					end if;
				end if;
								
			when VEL_UPDATE =>
				if (sobre_plataforma_i = '0' and sobre_plataforma_d = '0') then
					if (vely < MAX_VELY) then
						p_vely <= vely + ACEL;
					end if;
				else
					p_vely <= (others => '0');
				end if;
				p_estado <= FALLING;				
		end case;
	end process;

end Behavioral;

