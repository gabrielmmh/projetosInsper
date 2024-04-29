LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxNat4x1 is
  port (
    entradaA_MUX, entradaB_MUX, entradaC_MUX, entradaD_MUX : in  natural;
    seletor_MUX : in  std_logic_vector(1 downto 0);
    saida_MUX   : out natural
  );
end entity;

architecture Behavioral of muxNat4x1 is
begin
    saida_MUX <= entradaA_MUX when (seletor_MUX = "00") else
					  entradaB_MUX when (seletor_MUX = "01") else
					  entradaC_MUX when (seletor_MUX = "10") else
				     entradaD_MUX;
end architecture;