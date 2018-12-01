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
			  up : in STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0));
end juego;

architecture Behavioral of juego is

signal RGBm_RGBin : std_logic_vector(7 downto 0);
signal eje_x,eje_y : std_logic_vector(9 downto 0);
signal refresh : std_logic;
component mario is
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
           refresh : in  STD_LOGIC);
end component;

component VGA_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out std_logic_vector(9 downto 0);
			  eje_y : out std_logic_vector(9 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGBout : out  STD_LOGIC_VECTOR (7 downto 0);
			  refresh : out STD_LOGIC);
end component;

begin

driver:  VGA_driver
    Port map( clk => clk,
           reset => reset,
			  RGBin => RGBm_RGBin,
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
           eje_x => eje_x,
           eje_y => eje_y,
           RGBm => RGBm_RGBin,
           refresh =>refresh);

end Behavioral;

