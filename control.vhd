----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Control de los vectores RGB de todos los bloques. Tambien comprueba
--					 la superposicion del Mario con el escenario (sobrePlataforma y 
--					 sobreEscalera) y la superposición de Mario y barril (reset sincrono)
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente al Mario
			  RGBb0 : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente al barril 0
			  RGBb1 : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente al barril 1
			  RGBb2 : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente al barril 2
           RGBs : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente al escenario
			  RGBe : in  STD_LOGIC_VECTOR (7 downto 0); --RGB correspondiente a las escaleras
           RGBin : out  STD_LOGIC_VECTOR (7 downto 0); --RGB de salida que va al driver
			  resets : out  STD_LOGIC; --Reset sincrono
			  sobre_plataforma_m : out  STD_LOGIC; --Control del Mario sobre las plataformas
			  sobre_escalera_m : out  STD_LOGIC; --Control del Mario sobre las escaleras
			  sobre_plataforma_i : out  STD_LOGIC_VECTOR (2 downto 0); --Control del barril sobre las plataformas en las que tienen que moverse hacia la izquierda
			  sobre_plataforma_d : out  STD_LOGIC_VECTOR (2 downto 0)); --Control del barril sobre las plataformas en las que tienen que moverse hacia la derecha
end control;

architecture Behavioral of control is

type estado_juego is (PLAYING, WIN);

--Todas las variables sincronas siguen la nomenclatura: 'variable' para el valor actual y 'p_variable' para el del proximo ciclo de reloj
signal estado, p_estado : estado_juego; --Estado de la maquina
signal sobrePlat_m, p_sobrePlat_m, sobreEsc_m, p_sobreEsc_m : STD_LOGIC; --Señales internas de las salidas de control para poder ser leidas
signal sobrePlat_i, p_sobrePlat_i,sobrePlat_d, p_sobrePlat_d : STD_LOGIC_VECTOR (2 downto 0); --Señales internas de las salidas de control para poder ser leidas
signal p_RGBin : STD_LOGIC_VECTOR (7 downto 0);

--CONSTANTES DE COLORES
constant color_bloque_izq : STD_LOGIC_VECTOR (7 downto 0) := "00010100"; --Verde clarete
constant color_bloque_der : STD_LOGIC_VECTOR (7 downto 0) := "00001000"; --Verde oscurete
constant color_escalera : STD_LOGIC_VECTOR(7 downto 0):= "01001010"; --Gris
constant color_negro : STD_LOGIC_VECTOR (7 downto 0):= "00000000"; --Negro
constant color_final : STD_LOGIC_VECTOR (7 downto 0) := "11101101"; --Naranja
constant pto_control : STD_LOGIC_VECTOR (7 downto 0) := "00011111"; --Amarillo


begin
	sobre_plataforma_m <= sobrePlat_m;
	sobre_escalera_m <= sobreEsc_m;
	sobre_plataforma_i <= sobrePlat_i;
	sobre_plataforma_d <= sobrePlat_d;

	sinc : process(clk, reset)
	--Bloque sincrono con reset sincrono y asincrono
	begin
		if(reset = '1') then
			sobrePlat_m <= '0';
			sobreEsc_m <= '0';
			sobrePlat_i <= (others => '0');
			sobrePlat_d <= (others => '0');
			RGBin <= (others => '0');
			estado <= PLAYING;
		elsif(rising_edge(clk)) then
			sobreEsc_m <= p_sobreEsc_m;
			sobrePlat_m <= p_sobrePlat_m;
			sobrePlat_i <= p_sobrePlat_i;
			sobrePlat_d <= p_sobrePlat_d;
			RGBin <= p_RGBin;
			estado <= p_estado;
		end if;
	end process;

	comb : process(RGBm, RGBe, RGBs, RGBb0, RGBb1, RGBb2, sobrePlat_m, sobreEsc_m, sobrePlat_i, sobrePlat_d, estado)
	begin
		case estado is 
			
			when PLAYING =>
						--Prioridad para pintar
						if (not (RGBm = color_negro)) then --Primero Mario
							p_RGBin <= RGBm;
						elsif (not (RGBb0 = color_negro)) then --Despues barril 0
							p_RGBin <= RGBb0;
						elsif (not (RGBb1 = color_negro)) then --Despues barril 1
							p_RGBin <= RGBb1;
						elsif (not (RGBb2 = color_negro)) then --Despues barril 2
							p_RGBin <= RGBb2;
						elsif (not (RGBe = color_negro)) then --Despues escaleras
							p_RGBin <= RGBe;
						else
							p_RGBin <= RGBs; --Despues el escenario
						end if;
						
						--Sobreplataforma de barril 0
						if (RGBb0 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final)) then --Si el punto de control del barril esta en una plataforma de un color en la que el barril deba ir hacia la izquierda
							p_sobrePlat_d(0) <= '0'; --Se desactiva el control de que esta en una plataforma en la que deba ir hacia la derecha
							p_sobrePlat_i(0) <= '1'; --Y se activa el control de que esta sobre una que deba ir hacia la izquierda
						elsif (RGBb0 = pto_control and RGBs = color_bloque_der) then --Si el punto de control del barril esta en una plataforma de un color en la que el barril deba ir hacia la derecha
							p_sobrePlat_d(0) <= '1'; --Se activa el control de que esta en una plataforma en la que deba ir hacia la derecha
							p_sobrePlat_i(0) <= '0'; --Y se desactiva el control de que esta sobre una que deba ir hacia la izquierda
						elsif (RGBb0 = pto_control and RGBs = color_negro) then --Si el punto de control no coincide con ningun color de una plataforma
							p_sobrePlat_i(0) <= '0'; --Se desactiva el control de que esta en una plataforma en la que deba ir hacia la izquierda
							p_sobrePlat_d(0) <= '0'; --Y se desactiva tambien el control de que esta sobre una que debe ir hacia la derecha
						else --En cualquier otro caso
							p_sobrePlat_i(0) <= sobrePlat_i(0); --Se mantiene el valor anterior
							p_sobrePlat_d(0) <= sobrePlat_d(0); --Se mantiene el valor anterior
						end if;
						
						--Sobreplataforma de barril 1: mismo comportamiento que el barril 0
						if (RGBb1 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final)) then
							p_sobrePlat_d(1) <= '0';
							p_sobrePlat_i(1) <= '1';
						elsif (RGBb1 = pto_control and RGBs = color_bloque_der) then
							p_sobrePlat_d(1) <= '1';
							p_sobrePlat_i(1) <= '0';
						elsif (RGBb1 = pto_control and RGBs = color_negro) then
							p_sobrePlat_i(1) <= '0';
							p_sobrePlat_d(1) <= '0';
						else
							p_sobrePlat_i(1) <= sobrePlat_i(1);
							p_sobrePlat_d(1) <= sobrePlat_d(1);
						end if;
						
						--Sobreplataforma de barril 2: mismo comportamiento que el barril 0
						if (RGBb2 = pto_control and (RGBs = color_bloque_izq or RGBs = color_final)) then
							p_sobrePlat_d(2) <= '0';
							p_sobrePlat_i(2) <= '1';
						elsif (RGBb2 = pto_control and RGBs = color_bloque_der) then
							p_sobrePlat_d(2) <= '1';
							p_sobrePlat_i(2) <= '0';
						elsif (RGBb2 = pto_control and RGBs = color_negro) then
							p_sobrePlat_i(2) <= '0';
							p_sobrePlat_d(2) <= '0';
						else
							p_sobrePlat_i(2) <= sobrePlat_i(2);
							p_sobrePlat_d(2) <= sobrePlat_d(2);
						end if;
						
						
						--Sobreplataforma de Mario
						if ((RGBm = pto_control and RGBe = color_escalera)) then --Si el punto de control del Mario esta sobre una escalera
							p_sobreEsc_m <= '1'; --Se activa el control de que esta sobre una escalera
						elsif( (RGBm = pto_control and RGBe = color_negro)) then --En caso que este sobre negro (color de fondo del escenario)
							p_sobreEsc_m <= '0'; --Se desactiva el control de que esta sobre una escalera
						else --En otro caso
							p_sobreEsc_m <= sobreEsc_m; --Se mantiene el valor anterior
						end if;
						
						if ((RGBm = pto_control and (RGBs = color_bloque_izq)) or (RGBm = pto_control and RGBs = color_bloque_der)) then --Si el punto de control del Mario esta en una plataforma
							p_sobrePlat_m <= '1'; --Se activa el control de que esta sobre una plataforma
						elsif (RGBm = pto_control and RGBs = color_negro) then --En caso que este sobre negro (color de fondo del escenario)
							p_sobrePlat_m <= '0'; --Se desactiva el control de que esta sobre una plataforma
						else --En otro caso
							p_sobrePlat_m <= sobrePlat_m; --Se mantiene el valor anterior
						end if;
						
						--Control de final
						if (RGBm = pto_control and RGBs = color_final) then --Si el punto de control del Mario ha llegado a la plataforma final
							p_estado <= WIN; --Se pasa al estado de ganar
						else --En otro caso
							p_estado <= estado; --Se mantiene el estado anterior
						end if;
						
						--Control de muerte
						if ((not (RGBm = color_negro)) and ((not (RGBb0 = color_negro)) or (not (RGBb1 = color_negro)) or (not (RGBb2 = color_negro)))) then --Si se superpone algun barril con el Mario
							resets <= '1'; --Se da un reset sincrono para empezar de nuevo
						else
							resets <= '0';
						end if;
					
				when WIN => --Fin del juego, todo bloqueado hasta reset asincrono
					p_sobreEsc_m <= sobreEsc_m;
					p_sobrePlat_m <= sobrePlat_m;
					p_sobrePlat_i <= sobrePlat_i;
					p_sobrePlat_d <= sobrePlat_d;
					p_RGBin <= color_bloque_izq; --Toda la pantalla en verde
					p_estado <= WIN;
					resets <= '0';
			end case;
	end process;

end Behavioral;

