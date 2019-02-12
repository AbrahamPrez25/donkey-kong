----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Maquina de estados del Mario, en la que se define el comportamiento y devuelve el RGB para el control del juego
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mario is
    Port ( left : in  STD_LOGIC; --Controles
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  resets : in  STD_LOGIC; --Reset sincrono
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  data_mario : in  STD_LOGIC_VECTOR (7 downto 0); --Datos leidos de la memoria
			  addr_mario : out  STD_LOGIC_VECTOR (10 downto 0); --Direccion para acceder a la memoria
           RGBm : out  STD_LOGIC_VECTOR (7 downto 0); --Salida de colores al control
           refresh : in  STD_LOGIC;
			  sobre_plataforma : in  STD_LOGIC; --Señal para encima de plataforma
			  sobre_escalera : in  STD_LOGIC); --Señal para encima de escalera
end mario;

architecture Behavioral of mario is

type tipo_estado is (WAITING,POS_UPDATE,VEL_UPDATE); --Estados posibles del Mario

--Todas las variables sincronas siguen la nomenclatura: 'variable' para el valor actual y 'p_variable' para el del proximo ciclo de reloj
signal estado, p_estado : tipo_estado; --Estado de la máquina
signal posx, posy, p_posy, p_posx : unsigned (9 downto 0); --Posicion del Mario en ambos ejes
signal goingUp, p_goingUp : STD_LOGIC; --A nivel alto en la trayectoria ascendente de un salto del Mario
signal jumping, p_jumping : STD_LOGIC; --A nivel alto en TODA la trayectoria de un salto del Mario
signal enganchado, p_enganchado : STD_LOGIC; --A nivel alto si se esta en una escalera y se esta o ha estado subiendo o bajando por ella (se esta enganchado)
signal X, Y : unsigned (9 downto 0); --Variables para cambiar los ejes X e Y de entrada en unsigned
signal Xaux, Yaux : unsigned (9 downto 0); --Ejes X e Y mapeados a la posicion del Mario actual 
signal mirandoIzq, p_mirandoIzq 	: STD_LOGIC; --A nivel alto si el ultimo movimiento ha sido hacia la izquierda (para pintar el Mario mirando en una direccion u otra)
signal vely, p_vely : unsigned (4 downto 0); --Velocidad en el eje vertical
signal direc, p_direc : STD_LOGIC_VECTOR (10 downto 0); --Direccion para acceder a la memoria (variable auxiliar del puerto addr_mario)

constant VELX : unsigned (4 downto 0) := to_unsigned(5,5); --Velocidad constante en el eje X
constant VEL_ESC : unsigned (4 downto 0) := to_unsigned(2,5); --Velocidad subida en escalera
constant MAX_VELY : unsigned (4 downto 0) := to_unsigned(25,5); --Maxima velocidad permitida en el eje Y (para la caida)
constant MAX_POSX : unsigned (9 downto 0) := to_unsigned(639,10); --Limite del eje X
constant MAX_POSY : unsigned (9 downto 0) := to_unsigned(479,10); --Limite del eje Y
constant ACEL : unsigned (4 downto 0) := to_unsigned(1,5); --Debe ser 1 para que cuando este en una plataforma solo se meta un pixel en la plataforma

begin
	X <= unsigned(eje_x);
	Y <= unsigned(eje_y);
	Xaux <= unsigned(eje_x) - posx; --Mapeo del eje X a donde esta el Mario
	Yaux <= unsigned(eje_y) - posy; --Mapeo del eje Y a donde esta el Mario
	addr_mario <= direc;
	
	asig_direccion: process(mirandoIzq, enganchado, Yaux, Xaux)
	begin
	--El acceso a la memoria se explica con mas detalle en el PDF adjunto
		if (mirandoIzq = '0') then --Si esta mirando a la derecha
			p_direc <= enganchado & STD_LOGIC_VECTOR(Yaux(4 downto 0)) & STD_LOGIC_VECTOR(Xaux(4 downto 0)); --Imagen cargada en la memoria
		else --Si esta mirando a la izquierda
			p_direc <= enganchado & STD_LOGIC_VECTOR(Yaux(4 downto 0)) & STD_LOGIC_VECTOR(31 - Xaux(4 downto 0)); --Imagen invertida
		end if;
	end process;
	
	
	repr : process(X, Y, posx, posy, data_mario)
	begin
		--Comprueba si se está pintando en el cuadrado que le corresponde al Mario en cuyo caso se pinta lo que viene de la memoria
		if ((X >= posx) and (X < (posx + to_unsigned(32,10))) and (Y >= posy) and (Y < (posy + to_unsigned(32,10)))) then
			RGBm <= data_mario;
		else
			RGBm <= "00000000";
		end if;
		--Situamos el punto de control abajo del Mario en el centro
		if ((Y = (posy + to_unsigned(31,10))) and (X = (posx + to_unsigned(15,10)))) then
			RGBm <= "00011111"; --Amarillo
		end if;
	end process;
	
	sinc : process(clk, reset)
	--Bloque sincrono con reset sincrono y asincrono
	begin
		if (reset = '1') then
			vely <= (others => '0');
			posx <= to_unsigned(600,10); --Posicion inicial del Mario en X
			posy <= to_unsigned(400,10); --Posicion inicial del Mario en Y
			estado <= WAITING;
			jumping <= '0';
			goingUp <= '0';
			enganchado <= '0';
			direc <= (others => '0');
			mirandoIzq <= '1';
		elsif (rising_edge(clk)) then
			if (resets = '0') then
				vely <= p_vely;
				posx <= p_posx;
				posy <= p_posy;
				estado <= p_estado;
				jumping <= p_jumping;
				goingUp <= p_goingUp;
				enganchado <= p_enganchado;
				direc <= p_direc;
				mirandoIzq <= p_mirandoIzq;
			else --Reset sincrono
				vely <= (others => '0');
				posx <= to_unsigned(600,10);
				posy <= to_unsigned(400,10);
				estado <= WAITING;
				jumping <= '0';
				goingUp <= '0';
				enganchado <= '0';
				direc <= (others => '0');
				mirandoIzq <= '1';
			end if;
		end if;		
	end process;

	machine : process(estado, refresh, posx, posy, left, right, up, down, vely, sobre_plataforma, sobre_escalera, jump, jumping, goingUp, enganchado, mirandoIzq)
	begin
		--Valores por defecto
		p_posx <= posx; 
		p_posy <= posy;
		p_vely <= vely;
		p_enganchado <= enganchado;
		p_mirandoIzq <= mirandoIzq;
		
		if(jump = '1' and jumping = '0') then --Si se pulsa el boton de saltar y no se esta saltando ya
			p_goingUp <= '1';
			p_jumping <= '1';
			p_vely <= to_unsigned(8,5); --Velocidad inicial para que el salto mida 32 pixeles y supere el barril, q mide 16
		else
			p_goingUp <= goingUp;
			p_jumping <= jumping;
			p_vely <= vely;
		end if;
		
		--MAQUINA DE ESTADOS
		case estado is
		
			when WAITING => --No se actualiza nada hasta que no se termine de dibujar un frame completo
				if (refresh = '1') then
					p_estado <= POS_UPDATE;
				else
					p_estado <= WAITING;
				end if;
				
			when POS_UPDATE =>
			--MOVIMIENTO HORIZONTAL
				if (left = '1' and right = '1') then --Si se pulsan los dos botones simultaneamente
					p_posx <= posx; --Se mantiene la posicion
				elsif (right = '1' and ((posx + to_unsigned(32,10) + VELX) < MAX_POSX)) then --Si se pulsa el boton de la derecha pero no se sale de la pantalla
					p_posx <= posx + VELX; --Se mueve para la derecha
					p_mirandoIzq <= '0'; --Mira para la derecha
				elsif (left = '1' and (posx > VELX)) then --Si se pulsa el boton de la izquierda pero no se sale de la pantalla
					p_posx <= posx - VELX; --Se mueve para la izquierda
					p_mirandoIzq <= '1'; --Mira para la izquierda
				end if;
				
			--MOVIMIENTO VERTICAL
				--Comportamiento en escaleras
				if (sobre_escalera = '1' and up = '1' and down = '1') then --Si esta encima de una escalera y se pulsan los botones de subir y bajar simultaneamente
					p_posy <= posy; --Se mantiene la posicion
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchado <= '1'; --Se esta enganchado
				elsif (sobre_escalera = '1' and up = '1') then --Si esta encima de una escalera y se pulsa el boton de subir
					p_posy <= posy - VEL_ESC; --Sube la escalera
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchado <= '1'; --Se esta enganchado
				elsif (sobre_escalera = '1' and down = '1') then --Si esta encima de una escalera y se pulsa el boton de bajar
					p_posy <= posy + VEL_ESC; --Baja la escalera
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchado <= '1'; --Se esta enganchado
				elsif (enganchado = '1' and sobre_escalera = '1') then --Si estando enganchado se esta sobre una escalera
					p_posy <= posy; --Se mantiene la posicion
					p_jumping <= '0';
					p_goingUp <= '0';
					p_enganchado <= enganchado; --Enganchado toma el mismo valor (sigue enganchado)
				--Comportamiento de caida y salto
				elsif (goingUp = '0') then --Si va para abajo
					p_enganchado <= '0'; --No esta enganchado
					if (sobre_plataforma = '0') then --Si no esta encima de una plataforma
						p_posy <= posy + vely; --Sigue la caida
					else --Si esta en una plataforma
						p_jumping <= '0'; --Aseguro que no estoy saltando
						p_posy <= posy - 1; --Resto un pixel para que salga poco a poco de la plataforma
					end if;
				else --Si esta subiendo en un salto
					p_enganchado <= '0'; --No esta enganchado
					if (posy > vely ) then --Control de desborde de pantalla
						p_posy <= posy - vely; --No va a desbordar y sigue subiendo
					else
						p_posy <= posy; --En caso contrario se mantiene para que no desborde
					end if;					
				end if;
				
				p_estado <= VEL_UPDATE;
				
			when VEL_UPDATE =>
				if (goingUp = '0') then --Si no esta subiendo en un salto
					if (sobre_plataforma = '0' and enganchado = '0') then --Si debe caer
						if (vely < MAX_VELY) then --Si la velocidad actual es menor que la maxima permitida
							p_vely <= vely + ACEL; --Se aumenta la velocidad para que caiga mas rapido (gravedad)
						end if;
					else
						p_vely <= (others => '0'); --La velocidad en Y es nula si esta en una plataforma o enganchado en una escalera
					end if;
				else --Esta subiendo en un salto
					if (vely > ACEL) then --Si la velocidad en Y es mayor que la aceleracion
						p_vely <= vely - ACEL; --Decremento la velocidad para que el salto sea gradual
					else --Cuando la velocidad se ha disminuido tanto que sea menor que la aceleracion
						p_vely <= (others => '0'); --La velocidad se pone a cero
						p_goingUp <= '0'; --No esta subiendo
					end if;
				end if;
				p_estado <= WAITING;				
		end case;
	end process;

end Behavioral;

