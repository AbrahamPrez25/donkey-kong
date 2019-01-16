----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:14:34 11/12/2018 
-- Design Name: 
-- Module Name:    dibuja - Behavioral 
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

entity dibuja is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  moving_x : in STD_LOGIC;
			  moving_y : in STD_LOGIC;
			  enable_move : in STD_LOGIC;
			  eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RED : out  STD_LOGIC_VECTOR (2 downto 0);
           GRN : out  STD_LOGIC_VECTOR (2 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (1 downto 0));
end dibuja;

architecture Behavioral of dibuja is
signal p_RED,p_GRN : STD_logic_vector(2 downto 0);
signal p_BLUE : std_logic_vector(1 downto 0);
signal leftbound_x,rightbound_x,upbound_y,downbound_y,leftbound_x_ext,rightbound_x_ext,upbound_y_ext,downbound_y_ext : unsigned(9 downto 0);
signal p_leftbound_x,p_rightbound_x,p_upbound_y,p_downbound_y,p_leftbound_x_ext,p_rightbound_x_ext,p_upbound_y_ext,p_downbound_y_ext : unsigned(9 downto 0);

begin

	dib: process(eje_x,eje_y,leftbound_x,rightbound_x,upbound_y,downbound_y,leftbound_x_ext,rightbound_x_ext,upbound_y_ext,downbound_y_ext)
	begin
		p_RED<="111";--Todo rojo por defecto
		p_GRN<="000";
		p_BLUE<="00";
		
		
		if( ((downbound_y_ext < upbound_y_ext ) and ( (unsigned(eje_y)<(downbound_y_ext)) or (unsigned(eje_y)>(upbound_y_ext)) )) or --Si está en transicion de abajo a arriba
			 ((rightbound_x_ext < leftbound_x_ext) and ( (unsigned(eje_x)<(rightbound_x_ext)) or (unsigned(eje_x)>(leftbound_x_ext)) )) or --Si está en transicion de derecha a izquierda
			 (unsigned(eje_x)>leftbound_x_ext and unsigned(eje_x)<rightbound_x_ext) or --Si está en la banda vertical
			 (unsigned(eje_y)<downbound_y_ext and unsigned(eje_y)>upbound_y_ext)) then --Si está en la banda horizontal
			p_RED<="111";
			p_GRN<="111"; --Bandas blancas anchas (+30 pixeles)
			p_BLUE<="11";
		end if;
		
		if( ((downbound_y < upbound_y ) and ( (unsigned(eje_y)<(downbound_y)) or (unsigned(eje_y)>(upbound_y)) )) or --Si está en transicion de arriba a abajo
			 ((rightbound_x < leftbound_x) and ( (unsigned(eje_x)<(rightbound_x)) or (unsigned(eje_x)>(leftbound_x)) )) or --Si está en transicion de derecha a izquierda
			 (unsigned(eje_x)>leftbound_x and unsigned(eje_x)<rightbound_x) or --Si está en la banda vertical
			 (unsigned(eje_y)<downbound_y and unsigned(eje_y)>upbound_y)) then --Si está en la banda horizontal
			p_RED<="000";
			p_GRN<="000"; --Bandas azules estrechas
			p_BLUE<="10";
		end if;
		
	end process;


	barras: process(enable_move,moving_x,moving_y,leftbound_x,rightbound_x,upbound_y,downbound_y,leftbound_x_ext,rightbound_x_ext,upbound_y_ext,downbound_y_ext)
	begin
			if(moving_y = '1' and enable_move = '1') then
				p_leftbound_x <= leftbound_x+1;
				p_rightbound_x <= rightbound_x+1;
				p_leftbound_x_ext <= leftbound_x_ext+1;
				p_rightbound_x_ext <= rightbound_x_ext+1;
			else
				p_leftbound_x <= leftbound_x;
				p_rightbound_x <= rightbound_x;
				p_leftbound_x_ext <= leftbound_x_ext;
				p_rightbound_x_ext <= rightbound_x_ext;
			end if;
			
			if(moving_x = '1' and enable_move = '1') then
				p_upbound_y <= upbound_y+1;
				p_downbound_y <= downbound_y+1;
				p_upbound_y_ext <= upbound_y_ext+1;
				p_downbound_y_ext <= downbound_y_ext+1;
			else
				p_upbound_y <= upbound_y;
				p_downbound_y <= downbound_y;
				p_upbound_y_ext <= upbound_y_ext;
				p_downbound_y_ext <= downbound_y_ext;
			end if;
			
			if( leftbound_x = 639 ) then
				p_leftbound_x <= to_unsigned(0,10);
			end if;
			
			if( rightbound_x = 639 ) then
				p_rightbound_x <= to_unsigned(0,10);
			end if;
			
			if( upbound_y = 479 ) then
				p_upbound_y <= to_unsigned(0,10);
			end if;
			
			if( downbound_y = 479 ) then
				p_downbound_y <= to_unsigned(0,10);
			end if;
			
			if( leftbound_x_ext = 639 ) then
				p_leftbound_x_ext <= to_unsigned(0,10);
			end if;
			
			if( rightbound_x_ext = 639 ) then
				p_rightbound_x_ext <= to_unsigned(0,10);
			end if;
			
			if( upbound_y_ext = 479 ) then
				p_upbound_y_ext <= to_unsigned(0,10);
			end if;
			
			if( downbound_y_ext = 479 ) then
				p_downbound_y_ext <= to_unsigned(0,10);
			end if;
	end process;

	sinc: process(clk,reset) --Proceso síncrono. Cuando haya un flanco de subida de reloj, la salida de cuenta saldrá el próximo valor de cuenta (p_cuenta)
	begin
		if(reset='1') then
			RED<=(others=>'0');
			GRN<=(others=>'0');
			BLUE<=(others=>'0');
			leftbound_x <= to_unsigned(193,10);
			rightbound_x <= to_unsigned(233,10);
			upbound_y <= to_unsigned(220,10);
			downbound_y <= to_unsigned(260,10);
			leftbound_x_ext <= to_unsigned(183,10);
			rightbound_x_ext <= to_unsigned(243,10);
			upbound_y_ext <= to_unsigned(210,10);
			downbound_y_ext <= to_unsigned(270,10);
		elsif(rising_edge(clk)) then
			RED<=p_RED;
			GRN<=p_GRN;
			BLUE<=p_BLUE;
			leftbound_x <= p_leftbound_x;
			rightbound_x <= p_rightbound_x;
			upbound_y <= p_upbound_y;
			downbound_y <= p_downbound_y;
			leftbound_x_ext <= p_leftbound_x_ext;
			rightbound_x_ext <= p_rightbound_x_ext;
			upbound_y_ext <= p_upbound_y_ext;
			downbound_y_ext <= p_downbound_y_ext;
		end if;
	end process;

end Behavioral;

