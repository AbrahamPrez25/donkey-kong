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

signal RGBm,RGBs,RGBe,RGBb0,RGBb1,RGBb2,RGBin : STD_LOGIC_VECTOR(7 downto 0);
signal eje_x,eje_y : STD_LOGIC_VECTOR(9 downto 0);
signal refresh,resets,reset_cont : STD_LOGIC;
signal sobre_plataforma_m,sobre_escalera_m : STD_LOGIC;
signal sobre_plataforma_i, sobre_plataforma_d : STD_LOGIC_VECTOR (2 downto 0);
signal aparece,pintar : STD_LOGIC_VECTOR (2 downto 0);
signal enable : STD_LOGIC := '1';
signal cuenta, data_tiempos : STD_LOGIC_VECTOR( 28 downto 0);
signal addr_tiempos : STD_LOGIC_VECTOR( 3 downto 0);
signal addr_mario : STD_LOGIC_VECTOR(10 downto 0);
signal addr_barril,addr_barril0,addr_barril1,addr_barril2 : STD_LOGIC_VECTOR(7 downto 0);
signal data_mario, data_barril : STD_LOGIC_VECTOR(7 downto 0);

component mario is
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
end component;

component barril is
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
			  resets : out STD_LOGIC;
			  sobre_plataforma_m : out STD_LOGIC;
			  sobre_escalera_m : out STD_LOGIC;
			  sobre_plataforma_i : out STD_LOGIC_VECTOR (2 downto 0);
			  sobre_plataforma_d : out STD_LOGIC_VECTOR (2 downto 0));
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
			  aparece: out STD_LOGIC_VECTOR ( 2 downto 0));
end component;

COMPONENT memo_tiempos
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(28 DOWNTO 0)
  );
END COMPONENT;

COMPONENT memo_mario
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT memo_barril
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

begin

process (pintar,addr_barril0,addr_barril1,addr_barril2)
begin
	addr_barril <= (others => '0');
	if(pintar(0) = '1') then
		addr_barril<=addr_barril0;
	elsif(pintar(1) = '1') then
		addr_barril<=addr_barril1;
	elsif(pintar(2) = '1') then
		addr_barril<=addr_barril2;
	end if;
end process;


cont: contador
	Generic map ( Nbit=> 29)
	Port map ( clk=> clk,
			  reset => reset,
			  enable => enable,
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
			  
bloque_memoria_tiempos : memo_tiempos
  PORT MAP (
    clka => clk,
    addra => addr_tiempos,
    douta => data_tiempos);
  
bloque_memoria_mario : memo_mario
  PORT MAP (
    clka => clk,
    addra => addr_mario,
    douta => data_mario);
	 
bloque_memoria_barril : memo_barril
  PORT MAP (
    clka => clk,
    addra => addr_barril,
    douta => data_barril);	 
  
end Behavioral;

