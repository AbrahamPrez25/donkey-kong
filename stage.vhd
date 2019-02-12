----------------------------------------------------------------------------------
-- Asignatura: Complemetos de Electronica
-- Autores: Diego Lopez Morilla y Abraham Perez Hernandez
-- 
-- Descripcion: Archivo para establecer el escenario (plataformas y escaleras, por salidas separadas) 
--
----------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stage is
    Port ( eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  RGBe : out  STD_LOGIC_VECTOR (7 downto 0); --Salida de color de las escaleras
           RGBs : out  STD_LOGIC_VECTOR (7 downto 0)); --Salida de color de las plataformas
end stage;

architecture Behavioral of stage is

signal X, Y : unsigned (9 downto 0); --Señales auxiliares para los ejes X e Y

--CONSTANTES DE LIMITES DE PLATAFORMAS
constant grosor: unsigned (9 downto 0) := to_unsigned(15,10); --Pixeles de la mitad del grosor de las plataformas
constant medio_1: unsigned (9 downto 0) := to_unsigned(115,10); --Punto medio del eje Y donde se situa la plataforma 1
constant lim_izquierdo_1: unsigned (9 downto 0) := to_unsigned(110,10); --Limite izquierdo del eje X a partir del cual empieza la plataforma 1
constant lim_derecho_1: unsigned (9 downto 0) := to_unsigned(600,10); --Limite derecho del eje X a partir del cual acaba la plataforma 1 y empieza la zona final
constant medio_2: unsigned (9 downto 0) := to_unsigned(230,10); --Punto medio del eje Y donde se situa la plataforma 2
constant lim_derecho_2: unsigned (9 downto 0) := to_unsigned(550,10); --Limite derecho del eje X a partir del cual acaba la plataforma 2
constant medio_3: unsigned (9 downto 0) := to_unsigned(345,10); --Punto medio del eje Y donde se situa la tercera plataforma 3
constant lim_izquierdo_3: unsigned (9 downto 0) := to_unsigned(120,10); --Limite izquierdo del eje X a partir del cual empieza la plataforma 3
constant lim_superior_suelo: unsigned (9 downto 0) := to_unsigned(460,10); --Limite del eje Y 

--CONSTANTES DE DISEÑO DE ESCALERAS
constant grosor_escalera: unsigned (9 downto 0) := to_unsigned(20,10);
constant medio_esc_1: unsigned (9 downto 0) := to_unsigned(150,10);
constant medio_esc_2: unsigned (9 downto 0) := to_unsigned(500,10);
constant medio_esc_3: unsigned (9 downto 0) := to_unsigned(160,10);

--CONSTANTES DE COLORES
constant color_bloque_izq: STD_LOGIC_VECTOR (7 downto 0) := "00010100"; --Verde claro
constant color_bloque_der: STD_LOGIC_VECTOR (7 downto 0) := "00001000"; --Verde oscuro
constant color_escalera: STD_LOGIC_VECTOR (7 downto 0) := "01001010"; --Gris
constant color_final: STD_LOGIC_VECTOR (7 downto 0) := "11101101"; --Naranja

begin
	X <= unsigned(eje_x); --Conversion de STD_LOGIC_VECTOR a unsigned
	Y <= unsigned(eje_y);

	escenario : process(X, Y)
	begin
		--Comprueba la posición del driver con los limites de las distintas ESCALERAS, pitando la adecuada en cada momento
		if (X > (medio_esc_1 - grosor_escalera) and X <= (medio_esc_1 + grosor_escalera) and Y > (medio_1 - grosor) and Y <= (medio_2 - grosor)) then --Primera escalera
			RGBe <= color_escalera;
		elsif (X > (medio_esc_2 - grosor_escalera) and X <= (medio_esc_2 + grosor_escalera) and Y > (medio_2 - grosor) and Y <= (medio_3 - grosor)) then --Segunda escalera
			RGBe <= color_escalera;
		elsif (X > (medio_esc_3 - grosor_escalera) and X <= (medio_esc_3 + grosor_escalera) and Y > (medio_3 - grosor) and Y <= lim_superior_suelo) then --Tercera escalera
			RGBe <= color_escalera;
		else
			RGBe <= (others => '0');
		end if;
		
		--Comprueba la posición del driver con los limites de las distintas PLATAFORMAS, pitando la adecuada en cada momento
		if ( X > lim_izquierdo_1 and X <= lim_derecho_1 and Y > (medio_1 - grosor) and Y <= (medio_1 + grosor)) then --Primer stage
			RGBs <= color_bloque_izq;
		elsif ( X > lim_derecho_1 and Y > (medio_1 - grosor) and Y <= (medio_1 + grosor)) then --Zona final
			RGBs <= color_final; --FINAL
		elsif ( X < lim_derecho_2 and Y > (medio_2 - grosor) and Y <= (medio_2 + grosor)) then --Segundo stage
			RGBs <= color_bloque_der;
		elsif ( X > lim_izquierdo_3 and Y > (medio_3 - grosor) and Y <= (medio_3 + grosor)) then --Tercer stage
			RGBs <= color_bloque_izq;
		elsif ( Y > lim_superior_suelo ) then --Suelo
			RGBs <= color_bloque_der;
		else
			RGBs <= (others => '0');
		end if;
	end process;

end Behavioral;

