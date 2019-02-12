----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Driver para monitor 4:3 basado en el protocolo VGA, desarrollado en la practica 3
--
-- Dependencias: Contador y comparador
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in  STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : out  STD_LOGIC_VECTOR (9 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0);
			  refresh : out  STD_LOGIC);
end VGA_driver;

architecture Behavioral of VGA_driver is

component contador
	 Generic ( Nbit : integer := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end component;

component comparador
    Generic ( Nbit : integer := 8;
			  End_Of_Screen : integer := 10;
			  Start_Of_Pulse : integer := 20;
			  End_Of_Pulse : integer := 30;
			  End_Of_Line : integer := 40);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (Nbit-1 downto 0);
           O1 : out  STD_LOGIC;
           O2 : out  STD_LOGIC;
           O3 : out  STD_LOGIC);
end component;

signal O3_h, O3_v, clk_pixel, p_clk_pixel, enable_v, Blank_H, Blank_V: STD_LOGIC;
signal eje_x_aux, eje_y_aux : STD_LOGIC_VECTOR(9 downto 0);
begin

enable_v <= O3_h and clk_pixel;
eje_x <= eje_x_aux;
eje_y <= eje_y_aux;
refresh <= O3_v;
p_clk_pixel <= not clk_pixel;

frec_pixel: process(clk, reset)
begin
	if (reset = '1') then
		clk_pixel <= '0';
	elsif (rising_edge(clk)) then
		clk_pixel <= p_clk_pixel;
	end if;
end process;

gen_color: process(Blank_H, Blank_V, RGBin)
begin
	if (Blank_H = '1' or Blank_V = '1') then
		RGBout <= (others => '0');
	else
		RGBout <= RGBin;
	end if;
end process;

Conth: contador
	Generic map( Nbit => 10)
	Port map( clk => clk,
           reset => reset,
           enable => clk_pixel,
           resets => O3_h,
           Q => eje_x_aux);
			  
Contv: contador
	Generic map( Nbit => 10)
	Port map( clk => clk,
           reset => reset,
           enable => enable_v,
           resets => O3_v,
           Q => eje_y_aux);
			  
Comph: comparador
    Generic map( Nbit=> 10,
			  End_Of_Screen=>639,
			  Start_Of_Pulse=>655,
			  End_Of_Pulse=>751,
			  End_Of_Line=>799)
    Port map( clk => clk,
           reset => reset,
           data => eje_x_aux,
           O1 => Blank_H,
           O2 => HS,
           O3 => O3_h);

Compv: comparador
    Generic map( Nbit => 10,
			  End_Of_Screen => 479,
			  Start_Of_Pulse => 489,
			  End_Of_Pulse => 491,
			  End_Of_Line => 520)
    Port map( clk => clk,
           reset => reset,
           data => eje_y_aux,
           O1 => Blank_V,
           O2 => VS,
           O3 => O3_v);
			  
end Behavioral;

