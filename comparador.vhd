----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Comparador con tres salidas, desarrollado en la pr�ctica 3 de la asignatura
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparador is
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
end comparador;

architecture Behavioral of comparador is

signal p_O1, p_O2, p_O3 : STD_LOGIC;
signal data_in : unsigned (Nbit-1 downto 0);

begin

	data_in <= unsigned(data);

	sinc:process(clk, reset)
	begin
		if (reset = '1') then
			O1 <= '0';
			O2 <= '1';
			O3 <= '0';
		elsif (rising_edge(clk)) then
			O1 <= p_O1;
			O2 <= p_O2;
			O3 <= p_O3;
		end if;
	end process;

	comb: process(data_in)
	begin
		if (data_in > End_of_Screen) then
			p_O1 <= '1';
		else
			p_O1 <= '0';
		end if;
		
		if ((data_in > Start_Of_Pulse) and (data_in < End_Of_Pulse)) then
			p_O2 <= '0';
		else
			p_O2 <= '1';
		end if;
		
		if (data_in = End_Of_Line) then
			p_O3 <= '1';
		else
			p_O3 <= '0';
		end if;
	end process;

end Behavioral;

