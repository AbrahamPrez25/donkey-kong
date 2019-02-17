----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Archivo principal en el que se conectan todos los bloques del juego y se definen las señales internas y puertos de salida y entrada 
--
-- Dependencias: barril, contador, control, control_aparece, mario, memo_barril, memo_mario, memo_tiempos, stage, VGA_driver y mux_barriles
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity juego is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           left : in  STD_LOGIC; 
           right : in  STD_LOGIC;
			  up : in STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           HS : out  STD_LOGIC; --Señal de sincronismo horizontal
           VS : out  STD_LOGIC; --Señal de sincronismo vertical
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0)); --Salida de colores al monitor
end juego;

architecture Behavioral of juego is

--SEÑALES INTERNAS DE CONEXION ENTRE BLOQUES
signal RGBm, RGBs, RGBe, RGBb0, RGBb1, RGBb2, RGBin : STD_LOGIC_VECTOR (7 downto 0); --Señales internas de colores de los barriles, escaleras, mario, escenario y entrada al driver
signal eje_x, eje_y : STD_LOGIC_VECTOR (9 downto 0); --Posicion del driver en el monitor
signal refresh : STD_LOGIC;
signal resets, reset_cont : STD_LOGIC; --Resets sincronos para el juego y para el contador de tiempos entre barriles
signal sobre_plataforma_m, sobre_escalera_m : STD_LOGIC; --Señales de control del Mario
signal sobre_plataforma_i, sobre_plataforma_d : STD_LOGIC_VECTOR (2 downto 0); --Señales de control de los tres barriles (vector de tres bits, uno para cada uno)
signal aparece : STD_LOGIC_VECTOR (2 downto 0); --Tres bits, uno para cada barril, que indica cuando debe aparecer si está esperando fuera de la pantalla
signal pintar : STD_LOGIC_VECTOR (2 downto 0); --Tres bits, uno para cada barril, que usa cada barril cuando quiere acceder a la memoria compartida
--signal enable : STD_LOGIC := '1'; --Señal a 1 por defecto del contador de tiempos entre barriles (siempre contando)
signal cuenta, data_tiempos : STD_LOGIC_VECTOR (28 downto 0); --Valor actual de la cuenta del contador y tiempo leído en la memoria (entradas para el control_aparece)
signal data_mario, data_barril : STD_LOGIC_VECTOR (7 downto 0); --Datos leidos de la memoria del mario y del barril
signal addr_tiempos : STD_LOGIC_VECTOR (3 downto 0); --Direccion para acceder a memoria de tiempos
signal addr_mario : STD_LOGIC_VECTOR (10 downto 0); --Direccion para acceder a memoria del Mario
signal addr_barril, addr_barril0, addr_barril1, addr_barril2 : STD_LOGIC_VECTOR (7 downto 0); --Direccion para acceder a memoria de los barriles

component mario is
    Port ( left : in  STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  resets : in  STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  data_mario : in  STD_LOGIC_VECTOR (7 downto 0);
			  addr_mario : out  STD_LOGIC_VECTOR (10 downto 0);
           RGBm : out  STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC;
			  sobre_plataforma : in  STD_LOGIC;
			  sobre_escalera : in  STD_LOGIC);
end component;

component barril is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  resets : in  STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBb : out  STD_LOGIC_VECTOR (7 downto 0);
			  addr_barril : out  STD_LOGIC_VECTOR (7 downto 0);
			  pintar : out  STD_LOGIC;
			  data_barril : in  STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
			  sobre_plataforma_i : in  STD_LOGIC;
			  sobre_plataforma_d : in  STD_LOGIC);
end component;

component VGA_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in  STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : out  STD_LOGIC_VECTOR (9 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0);
			  refresh : out  STD_LOGIC);
end component;

component stage is
    Port ( eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  RGBe : out  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb0 : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb1 : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb2 : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBe : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0);
			  resets : out  STD_LOGIC;
			  sobre_plataforma_m : out  STD_LOGIC;
			  sobre_escalera_m : out  STD_LOGIC;
			  sobre_plataforma_i : out  STD_LOGIC_VECTOR (2 downto 0);
			  sobre_plataforma_d : out  STD_LOGIC_VECTOR (2 downto 0));
end component;

component contador
	 Generic (Nbit: INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end component;

component control_aparece is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           cuenta : in  STD_LOGIC_VECTOR (28 downto 0);
           data : in  STD_LOGIC_VECTOR (28 downto 0);
           address : out  STD_LOGIC_VECTOR (3 downto 0);
           reset_cont : out  STD_LOGIC;
			  aparece : out  STD_LOGIC_VECTOR (2 downto 0));
end component;

attribute box_type : string;

component memo_tiempos
  Port ( clka : in  STD_LOGIC;
			addra : in  STD_LOGIC_VECTOR (3 downto 0);
			douta : out  STD_LOGIC_VECTOR (28 downto 0));
end component;
attribute box_type of memo_tiempos : component is "black_box"; 

component memo_mario
  Port ( clka : in STD_LOGIC;
			addra : in STD_LOGIC_VECTOR (10 downto 0);
			douta : out STD_LOGIC_VECTOR (7 downto 0));
end component;
attribute box_type of memo_mario : component is "black_box"; 

component memo_barril
  Port ( clka : in STD_LOGIC;
			addra : in STD_LOGIC_VECTOR (7 downto 0);
			douta : out STD_LOGIC_VECTOR (7 downto 0));
end component;
attribute box_type of memo_barril : component is "black_box"; 

component mux_barriles is
    Port ( pintar : in  STD_LOGIC_VECTOR (2 downto 0);
           addr_barril0 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril1 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril2 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril : out  STD_LOGIC_VECTOR (7 downto 0));
end component;


begin

	cont: contador
		Generic map( Nbit => 29)
		Port map( clk => clk,
				 reset => reset,
				 enable => '1', --Contador siempre contando
				 resets => reset_cont,
				 Q => cuenta);

	driver:  VGA_driver
		 Port map( clk => clk,
				  reset => reset,
				  RGBin => RGBin,
				  eje_x => eje_x,
				  eje_y => eje_y,
				  VS => VS,
				  HS => HS,
				  RGBout => RGBout,
				  refresh => refresh);
				  
	bloque_mario: mario
		 Port map( left => left,
				  right => right,
				  up => up,
				  down => down,
				  jump => jump,
				  clk => clk,
				  reset => reset,
				  resets => resets,
				  eje_x => eje_x,
				  eje_y => eje_y,
				  data_mario => data_mario,
				  addr_mario => addr_mario,
				  RGBm => RGBm,
				  refresh => refresh,
				  sobre_plataforma => sobre_plataforma_m,
				  sobre_escalera => sobre_escalera_m);

	bloque_barril0: barril
		 Port map( clk => clk,
				  reset => reset,
				  resets => resets,
				  eje_x => eje_x,
				  eje_y => eje_y,
				  RGBb => RGBb0,
				  addr_barril => addr_barril0,
				  pintar => pintar(0),
				  data_barril => data_barril,
				  refresh => refresh,
				  aparece => aparece(0),
				  sobre_plataforma_i => sobre_plataforma_i(0),
				  sobre_plataforma_d => sobre_plataforma_d(0));
				  
	bloque_barril1: barril
		 Port map( clk => clk,
				  reset => reset,
				  resets => resets,
				  eje_x => eje_x,
				  eje_y => eje_y,
				  RGBb => RGBb1,
				  addr_barril => addr_barril1,
				  pintar => pintar(1),
				  data_barril => data_barril,
				  refresh => refresh,
				  aparece => aparece(1),
				  sobre_plataforma_i => sobre_plataforma_i(1),
				  sobre_plataforma_d => sobre_plataforma_d(1));
				  
	bloque_barril2: barril
		 Port map( clk => clk,
				  reset => reset,
				  resets => resets,
				  eje_x => eje_x,
				  eje_y => eje_y,
				  RGBb => RGBb2,
				  addr_barril => addr_barril2,
				  pintar => pintar(2),
				  data_barril => data_barril,
				  refresh => refresh,
				  aparece => aparece(2),
				  sobre_plataforma_i => sobre_plataforma_i(2),
				  sobre_plataforma_d => sobre_plataforma_d(2));

	bloque_escenario: stage
		 Port map( eje_x => eje_x,
				  eje_y => eje_y,
				  RGBe => RGBe,
				  RGBs => RGBs);

	bloque_control: control
		 Port map( clk => clk,
				  reset => reset,
				  RGBm => RGBm,
				  RGBb0 => RGBb0,
				  RGBb1 => RGBb1,
				  RGBb2 => RGBb2,
				  RGBs => RGBs,
				  RGBe => RGBe,
				  RGBin => RGBin,
				  resets => resets,
				  sobre_plataforma_m => sobre_plataforma_m,
				  sobre_escalera_m => sobre_escalera_m,
				  sobre_plataforma_i => sobre_plataforma_i,
				  sobre_plataforma_d => sobre_plataforma_d);

	bloque_control_aparece: control_aparece
		 Port map( clk => clk,
				  reset => reset,
				  cuenta => cuenta,
				  data => data_tiempos,
				  address => addr_tiempos,
				  reset_cont => reset_cont,
				  aparece => aparece);
				  
	bloque_mux_barriles: mux_barriles
		Port map( pintar => pintar,
				 addr_barril0 => addr_barril0,
				 addr_barril1 => addr_barril1,
				 addr_barril2 => addr_barril2,
				 addr_barril => addr_barril);
				 
	bloque_memoria_tiempos : memo_tiempos
		 Port map( clka => clk,
				  addra => addr_tiempos,
				  douta => data_tiempos);
	  
	bloque_memoria_mario : memo_mario
		 Port map( clka => clk,
				  addra => addr_mario,
				  douta => data_mario);
		 
	bloque_memoria_barril : memo_barril
		 Port map( clka => clk,
				  addra => addr_barril,
				  douta => data_barril);	 
	  
end Behavioral;

