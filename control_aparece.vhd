----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Control de la aparicion de los barriles, cuando el contador coincida con el numero
--					 de la memoria, la señal de aparicion del barril se pondra a nivel alto
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_aparece is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           cuenta : in  STD_LOGIC_VECTOR (28 downto 0); --Contador
           data : in  STD_LOGIC_VECTOR (28 downto 0); --Numero pseudoaleatorio sacado de la memoria
           address : out  STD_LOGIC_VECTOR (3 downto 0); --Direccion para acceder a la memoria de numeros pseudoaleatorios
           reset_cont : out  STD_LOGIC; --Para resetear el contador
			  aparece: out  STD_LOGIC_VECTOR (2 downto 0)); --Salida para controlar la aparicion de los tres barriles
end control_aparece;

architecture Behavioral of control_aparece is

--Todas las variables sincronas siguen la nomenclatura: 'variable' para el valor actual y 'p_variable' para el del proximo ciclo de reloj
signal p_addr, addr: STD_LOGIC_VECTOR (3 downto 0); 
signal p_reset_cont : STD_LOGIC;
signal p_apar, apar : STD_LOGIC_VECTOR (2 downto 0);

begin
	address <= addr;
	aparece <= apar;
	sinc : process(clk, reset)
	begin
		if (reset = '1') then
			addr <= (others => '0');
			reset_cont <= '0';
			apar <= "100"; --Por defecto el primer barril aparece cuando inicia el juego
		elsif (rising_edge(clk)) then
			addr <= p_addr;
			reset_cont <= p_reset_cont;
			apar <= p_apar;
		end if;
	end process;
	
	comb: process(data, cuenta, addr, apar)
	begin
		if(data = cuenta) then --Si el valor extraido de la memoria coincide con el contador
			p_reset_cont <= '1'; --Se pone el contador a cero
			p_addr <= std_logic_vector(unsigned(addr) + 1); --La posicion en memoria se aumenta para que el numero pseudoaleatorio siguiente sea otro
			p_apar <= apar(0) & apar(2) & apar(1); --El vector de aparece rota para que aparezca el siguiente
		else
			p_reset_cont <= '0';
			p_addr <= addr;
			p_apar <= apar;
		end if;
	
	end process;

end Behavioral;

