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
			  resets : in STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  data_mario : in STD_LOGIC_VECTOR (7 downto 0);
			  addr_mario : out STD_LOGIC_VECTOR (10 downto 0);
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

signal X,Y,Xaux,Yaux : unsigned(9 downto 0);

constant VELX : unsigned(4 downto 0):=to_unsigned(5,5);
constant VEL_ESC : unsigned(4 downto 0):=to_unsigned(2,5);
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant MAX_POSX : unsigned(9 downto 0):=to_unsigned(639,10);
constant MAX_POSY : unsigned(9 downto 0):=to_unsigned(479,10);
constant ACEL : unsigned(4 downto 0):=to_unsigned(1,5); --Debe ser 1 para que cuando este en una plataforma solo se meta un pixel en la plataforma

signal mirandoIzq, p_mirandoIzq: STD_LOGIC;
signal vely,p_vely : unsigned(4 downto 0);
signal direc, p_direc : STD_LOGIC_VECTOR (10 downto 0);
begin
	X <= unsigned(eje_x);
	Y <= unsigned(eje_y);
	Xaux <= unsigned(eje_x)-posx;
	Yaux <= unsigned(eje_y)-posy;
	addr_mario <= direc;
	
	asig_direccion: process(mirandoIzq,enganchau,Yaux,Xaux)
	begin
		if(mirandoIzq = '0') then
			p_direc <= enganchau & std_logic_vector(Yaux(4 downto 0)) & std_logic_vector(Xaux(4 downto 0));
		else
			p_direc <= enganchau & std_logic_vector(Yaux(4 downto 0)) & std_logic_vector(31 - Xaux(4 downto 0));
		end if;
	end process;
	
	
	repr : process(X,Y,posx,posy,data_mario)
	begin
		if( ( X >= posx ) and ( X < (posx+to_unsigned(32,10)) ) and ( Y >= posy ) and ( Y < (posy + to_unsigned(32,10)) ) )then
			RGBm <= data_mario;
		else
			RGBm <= "00000000";
		end if;
		if( ( Y = (posy+to_unsigned(31,10)) ) and (  X = (posx + to_unsigned(15,10)) ) )then
			RGBm <= "00011111"; --Amarillo
		end if;
	end process;
	
	sinc : process(clk,reset)
	begin
		if(reset='1') then
			vely <= (others=>'0');
			posx <= to_unsigned(600,10);
			posy <= to_unsigned(400,10);
			estado <= WAITING;
			jumping <= '0';
			goingUp <= '0';
			enganchau <= '0';
			direc <= (others => '0');
			mirandoIzq <= '1';
		elsif(rising_edge(clk)) then
			if( resets = '0') then
				vely <= p_vely;
				posx <= p_posx;
				posy <= p_posy;
				estado<=p_estado;
				jumping <= p_jumping;
				goingUp <= p_goingUp;
				enganchau <= p_enganchau;
				direc <= p_direc;
				mirandoIzq <= p_mirandoIzq;
			else
				vely <= (others=>'0');
				posx <= to_unsigned(600,10);
				posy <= to_unsigned(400,10);
				estado <= WAITING;
				jumping <= '0';
				goingUp <= '0';
				enganchau <= '0';
				direc <= (others => '0');
				mirandoIzq <= '1';
			end if;
		end if;		
	end process;

	machine : process(estado,refresh,posx,posy,left,right,up,down,vely,sobre_plataforma,sobre_escalera,jump,jumping,goingUp,enganchau,mirandoIzq)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		p_enganchau <= enganchau;
		p_mirandoIzq <= mirandoIzq;
		
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
					p_mirandoIzq <= '0';
				elsif(left='1' and ( posx > VELX )) then --Se mueve para la izquierda pero no se sale de la pantalla
					p_posx <= posx - VELX;
					p_mirandoIzq <= '1';
				end if;
			--Movimiento vertical
				--Caída y salto
				if (sobre_escalera = '1' and up = '1' and down = '1') then
					p_posy <= posy;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= '1';
				elsif (sobre_escalera = '1' and up = '1') then
					p_posy <= posy - VEL_ESC;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= '1';
				elsif (sobre_escalera = '1' and down = '1') then
					p_posy <= posy + VEL_ESC;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= '1';
				elsif ( enganchau = '1' and sobre_escalera = '1' ) then
					p_posy <= posy;
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchau <= enganchau;
				elsif ( goingUp = '0' ) then --Si va para abajo
					p_enganchau <= '0';
					if( sobre_plataforma = '0') then --No está encima de una plataforma
						p_posy <= posy + vely;
					else
						p_jumping <= '0'; --Aseguro que no estoy saltando
						p_posy <= posy-1; --Si estoy, resto un pixel para que salga poco a poco
					end if;
				else
					p_enganchau <= '0';
					if( posy > vely ) then --Control de desborde de pantalla
						p_posy <= posy-vely;
					else
						p_posy <= posy;
					end if;					
				end if;
				
				p_estado <= VEL_UPDATE;
			when VEL_UPDATE =>
				if( goingUp = '0' ) then
					if( sobre_plataforma = '0' and enganchau = '0') then
						if ( vely < MAX_VELY ) then
							p_vely <= vely + ACEL;
						end if;
					else
						p_vely <= (others => '0');
					end if;
				else
					if( vely > acel ) then
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

