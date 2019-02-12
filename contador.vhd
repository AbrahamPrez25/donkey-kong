----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Contador con señal de habilitacion y reset sincrono
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
	 Generic ( Nbit : integer := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end contador;

architecture Behavioral of contador is

signal cuenta, p_cuenta : unsigned(Nbit-1 downto 0);

begin

	Q <= std_logic_vector(cuenta);
	
	sinc: process(clk, reset, enable) --Proceso síncrono. Cuando haya un flanco de subida de reloj, la salida de cuenta saldrá el próximo valor de cuenta (p_cuenta)
	begin
		if (reset = '1') then
			cuenta <= (others => '0');
		elsif (rising_edge(clk)) then
			cuenta <= p_cuenta;
		end if;
	end process;

	comb: process(cuenta, resets, enable) --Proceso combinacional. Cuando cambia el valor de la cuenta, se incrementa el proximo valor. 
	begin											  
		if (resets = '1') then
			p_cuenta <= (others => '0');
		elsif (enable = '1') then
			p_cuenta <= cuenta + 1;
		else
			p_cuenta <= cuenta;
		end if;
	end process;

end Behavioral;

