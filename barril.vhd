----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Maquina de estados del barril, en la que se define el comportamiento y devuelve el RGB para el control del juego
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barril is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  resets : in  STD_LOGIC; --Reset sincrono
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0); 
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBb : out  STD_LOGIC_VECTOR (7 downto 0); --Salidas de colores al control
           addr_barril : out  STD_LOGIC_VECTOR (7 downto 0); --Direccion para acceder a la memoria
			  pintar : out  STD_LOGIC; --Señal para indicar que quiere pintar el barril
			  data_barril : in  STD_LOGIC_VECTOR (7 downto 0); --Datos leidos de la memoria
           refresh : in  STD_LOGIC;
           aparece : in  STD_LOGIC; --Entrada que da la orden de aparecer el barril
			  sobre_plataforma_i : in  STD_LOGIC; --Señal para encima de una plataforma en la que debe ir el barril hacia la izquierda
			  sobre_plataforma_d : in  STD_LOGIC); --Señal para encima de una plataforma en la que debe ir el barril hacia la derecha
end barril;

architecture Behavioral of barril is

type tipo_estado is (WAITING, FALLING, POS_UPDATE, VEL_UPDATE);

--Todas las variables sincronas siguen la nomenclatura: 'variable' para el valor actual y 'p_variable' para el del proximo ciclo de reloj
signal estado, p_estado : tipo_estado; --Estado de la maquina
signal posx, posy, p_posy, p_posx : unsigned (9 downto 0); --Posicion del barril en ambos ejes
signal movIzq, p_movIzq : STD_LOGIC; --A nivel alto si el barril se mueve hacia la izquierda
signal X, Y : unsigned (9 downto 0); --Variables para cambiar los ejes X e Y de entrada en unsigned
signal Xaux, Yaux : unsigned (9 downto 0); --Ejes X e Y mapeados a la posicion del barril actual 
signal vely, p_vely : unsigned(4 downto 0); --Velocidad en el eje vertical

constant VELX : unsigned(4 downto 0):= to_unsigned(5,5); --Velocidad constante en el eje X
constant MAX_VELY : unsigned (4 downto 0) := to_unsigned(25,5); --Maxima velocidad permitida en el eje Y (para la caida)
constant MAX_POSX : unsigned (9 downto 0) := to_unsigned(639,10); --Limite del eje X
constant MAX_POSY : unsigned (9 downto 0) := to_unsigned(479,10); --Limite del eje Y
constant ACEL : unsigned (4 downto 0) := to_unsigned(1,5); --Debe ser 1 para que cuando este en una plataforma solo se meta un pixel en la plataforma
constant POSX_INI : unsigned (9 downto 0) := to_unsigned(640,10); --Se pinta el barril fuera de la pantalla inicialmente

begin
	X <= unsigned(eje_x);
	Y <= unsigned(eje_y);
	Xaux <= unsigned(eje_x) - posx; --Mapeo del eje X a donde esta el Mario
	Yaux <= unsigned(eje_y) - posy; --Mapeo del eje Y a donde esta el Mario
	--El acceso a la memoria se explica con mas detalle en el PDF adjunto
	addr_barril <= std_logic_vector(Yaux(3 downto 0)) & std_logic_vector(Xaux(3 downto 0)); 
	
	repr : process(X, Y, posx, posy, data_barril)
	begin
		--Comprueba si se está pintando en el cuadrado que le corresponde al Mario en cuyo caso se pinta lo que viene de la memoria
		if ((X >= posx) and (X < (posx+to_unsigned(16,10))) and (Y >= posy) and (Y < (posy + to_unsigned(16,10)))) then
			pintar <= '1'; --Se pone a nivel alto para indicar que se quiere acceder a la memoria
			RGBb <= data_barril;
		else
			pintar <= '0';
			RGBb <= "00000000";
		end if;
		--Situamos el punto de control abajo del barril en el centro
		if ((Y = (posy+to_unsigned(15,10))) and (X = (posx + to_unsigned(7,10)))) then
			RGBb <= "00011111"; --Amarillo
		end if;
	end process;

	sinc : process(clk,reset)
	begin
	--Bloque sincrono con reset sincrono y asincrono
		if (reset = '1') then
			vely <= (others => '0');
			posx <= POSX_INI; --Posicion inicial del barril en X
			posy <= (others => '0'); --Posicion inicial del barril en Y
			estado <= WAITING;
			movIzq <= '1';
		elsif (rising_edge(clk)) then 
			if(resets = '0') then
				vely <= p_vely;
				posx <= p_posx;
				posy <= p_posy;
				estado <= p_estado;
				movIzq <= p_movIzq;
			else --Reset sincrono
				vely <= (others => '0');
				posx <= POSX_INI;
				posy <= (others => '0');
				estado <= WAITING;
				movIzq <= '1';
			end if;
		end if;		
	end process;

	machine : process(estado, refresh, posx, posy, vely, sobre_plataforma_i, sobre_plataforma_d, movIzq, aparece)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		p_movIzq <= movIzq;
		
		--MAQUINA DE ESTADOS
		case estado is
		
			when WAITING => --No cae un barril hasta que no este a nivel alto la señal de aparece
				if (aparece = '1') then
					p_estado <= FALLING;
				else
					p_estado <= WAITING;
				end if;
			
			when FALLING => --No se actualiza nada hasta que no se termine de dibujar un frame completo
				if (refresh = '1') then
					p_estado <= POS_UPDATE;
				else
					p_estado <= FALLING;
				end if;
				
			when POS_UPDATE =>
				p_estado <= VEL_UPDATE;
			--MOVIMIENTO VERTICAL
				if (sobre_plataforma_i = '0' and sobre_plataforma_d = '0') then --No está encima de una plataforma
					p_posy <= posy + vely; --El barril cae
				elsif (sobre_plataforma_i = '1') then --Si esta en una plataforma pegada a la derecha
					p_posy <= posy - 1; --Resto un pixel para que salga poco a poco
					p_movIzq <= '1'; --El barril debe ir hacia la izquierda
				else 
					p_posy <= posy - 1; --Resto un pixel para que salga poco a poco
					p_movIzq <= '0'; --El barril debe ir hacia la derecha
				end if;
				
			--MOVIMIENTO HORIZONTAL
				if (movIzq = '0') then --Si se mueve para la derecha
					if (((posx  - VELX) > 635) and (posy > 200)) then --Si la proxima posicion del barril es mayor que 635, vuelve al inicio
						p_estado <= WAITING;
						p_vely <= (others => '0');
						p_posx <= POSX_INI;
						p_posy <= (others => '0');
						p_movIzq <= '1';
					else	--Si no es mayor a 635 se incrementa el valor para que siga desplazandose
						p_posx <= posx + VELX; 
					end if;				
				elsif(movIzq = '1') then --Si se mueve para la izquierda	
						p_posx <= posx - VELX;
				end if;
								
			when VEL_UPDATE =>
				if (sobre_plataforma_i = '0' and sobre_plataforma_d = '0') then --Si no esta en ninguna plataforma
					if (vely < MAX_VELY) then --Si la velocidad actual es menor que la maxima permitida
						p_vely <= vely + ACEL; --Se aumenta la velocidad para que caiga mas rapido (gravedad)
					end if;
				else
					p_vely <= (others => '0'); --La velocidad en Y es nula si esta en una plataforma o enganchado en una escalera
				end if;
				p_estado <= FALLING;
		end case;
	end process;

end Behavioral;

