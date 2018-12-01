----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:05:32 11/12/2018 
-- Design Name: 
-- Module Name:    contador - Behavioral 
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

entity contador is
	 Generic (Nbit: INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end contador;

architecture Behavioral of contador is

signal cuenta, p_cuenta: unsigned(Nbit-1 downto 0);
begin
	Q <= std_logic_vector(cuenta);
	sinc: process(clk,reset,enable) --Proceso síncrono. Cuando haya un flanco de subida de reloj, la salida de cuenta saldrá el próximo valor de cuenta (p_cuenta)
	begin
		if(reset='1') then
			cuenta<=(others=>'0');
		elsif(rising_edge(clk)) then
			cuenta<=p_cuenta;
		end if;
	end process;

	comb: process(cuenta,resets,enable) --Proceso combinacional. Cuando cambia el valor de la cuenta, se incrementa el proximo valor. 
								 --Cuando se llega al tope, se lanza un pulso de la saturacion
	begin
		if( resets='1' ) then
			p_cuenta<=(others=>'0');
		elsif( enable='1' ) then
			p_cuenta<=cuenta+1;
		else
			p_cuenta<=cuenta;
		end if;
	end process;

end Behavioral;

