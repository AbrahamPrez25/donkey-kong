----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:44:19 01/18/2019 
-- Design Name: 
-- Module Name:    control_aparece - Behavioral 
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

entity control_aparece is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           cuenta : in  STD_LOGIC_VECTOR (28 downto 0);
           data : in  STD_LOGIC_VECTOR (28 downto 0);
           address : out  STD_LOGIC_VECTOR (3 downto 0);
           reset_cont : out  STD_LOGIC;
			  aparece: out STD_LOGIC_VECTOR ( 2 downto 0));
end control_aparece;

architecture Behavioral of control_aparece is
signal p_addr, addr: STD_LOGIC_VECTOR (3 downto 0);
signal p_reset_cont : STD_LOGIC;
signal p_apar,apar : STD_LOGIC_VECTOR (2 downto 0);
begin
	address <= addr;
	aparece <= apar;
	sinc: process(clk,reset)
	begin
		if (reset = '1') then
			addr <= (others => '0');
			reset_cont <= '0';
			apar <= "100";
		elsif(rising_edge(clk)) then
			addr <= p_addr;
			reset_cont <= p_reset_cont;
			apar <= p_apar;
		end if;
	end process;
	
	comb: process(data, cuenta,addr,apar)
	begin
		if( data = cuenta ) then
			p_reset_cont <= '1';
			p_addr <= std_logic_vector(unsigned(addr) + 1);
			p_apar <= apar(0)&apar(2)&apar(1);
		else
			p_reset_cont <= '0';
			p_addr <= addr;
			p_apar <= apar;
		end if;
	
	end process;

end Behavioral;

