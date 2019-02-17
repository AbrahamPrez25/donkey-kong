----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Bloque multiplexor que permite a los barriles compartir la misma memoria
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_barriles is
    Port ( pintar : in  STD_LOGIC_VECTOR (2 downto 0);
           addr_barril0 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril1 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril2 : in  STD_LOGIC_VECTOR (7 downto 0);
           addr_barril : out  STD_LOGIC_VECTOR (7 downto 0));
end mux_barriles;

architecture Behavioral of mux_barriles is
begin

process (pintar, addr_barril0, addr_barril1, addr_barril2) --Multiplexor simple one-hot con prioridad
	begin
		addr_barril <= (others => '0'); --Por defecto, la dirección a la memoria es la inicial
		if (pintar(0) = '1') then --Si el barril 0 quiere acceder
			addr_barril <= addr_barril0; --La direccion de la memoria la pone el barril 0
		elsif (pintar(1) = '1') then --Si no, accede el barril 1
			addr_barril <= addr_barril1;
		elsif (pintar(2) = '1') then --Si no, accede el barril 2
			addr_barril <= addr_barril2;
		end if;
	end process;
end Behavioral;

