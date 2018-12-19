----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:45:46 12/01/2018 
-- Design Name: 
-- Module Name:    juego - Behavioral 
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

entity juego is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           left : in  STD_LOGIC;
           right : in  STD_LOGIC;
			  --up : in STD_LOGIC;
           --down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
			  aparece : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0));
end juego;

architecture Behavioral of juego is

signal RGBm,RGBs,RGBb,RGBin : STD_LOGIC_VECTOR(7 downto 0);
signal eje_x,eje_y : STD_LOGIC_VECTOR(9 downto 0);
signal refresh : STD_LOGIC;
signal sobre_plataforma_m,sobre_plataforma_i,sobre_plataforma_d : STD_LOGIC;

component mario is
    Port ( left : in  STD_LOGIC;
           right : in  STD_LOGIC;
           --up : in  STD_LOGIC;
           --down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBm : out  STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC;
			  sobre_plataforma : in STD_LOGIC);
end component;

component barril is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBb : out  STD_LOGIC_VECTOR (7 downto 0);
           refresh : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
			  sobre_plataforma_i : in STD_LOGIC;
			  sobre_plataforma_d : in STD_LOGIC);
end component;

component VGA_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out STD_LOGIC_VECTOR(9 downto 0);
			  eje_y : out STD_LOGIC_VECTOR(9 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0);
			  refresh : out STD_LOGIC);
end component;

component stage is
    Port ( eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGBb : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0);
			  --aparece : out STD_LOGIC;
			  sobre_plataforma_m : out STD_LOGIC;
			  sobre_plataforma_i : out STD_LOGIC;
			  sobre_plataforma_d : out STD_LOGIC);
end component;

begin

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
           --up => up,
           --down => down,
           jump => jump,
           clk => clk,
           reset => reset,
           eje_x => eje_x,
           eje_y => eje_y,
           RGBm => RGBm,
           refresh => refresh,
			  sobre_plataforma => sobre_plataforma_m);

bloque_barril: barril
    Port map( clk => clk,
           reset => reset,
           eje_x => eje_x,
           eje_y => eje_y,
           RGBb => RGBb,
           refresh => refresh,
           aparece => aparece,
			  sobre_plataforma_i => sobre_plataforma_i,
			  sobre_plataforma_d => sobre_plataforma_d);

bloque_escenario: stage
    Port map( eje_x => eje_x,
           eje_y => eje_y,
           RGBs => RGBs);

bloque_control: control
    Port map( clk => clk,
           reset => reset,
           RGBm => RGBm,
           RGBb => RGBb,
           RGBs => RGBs,
           RGBin => RGBin,
			  --aparece => aparece,
			  sobre_plataforma_m => sobre_plataforma_m,
			  sobre_plataforma_i => sobre_plataforma_i,
			  sobre_plataforma_d => sobre_plataforma_d);

end Behavioral;

