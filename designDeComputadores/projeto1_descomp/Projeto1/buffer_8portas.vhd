library IEEE;
use ieee.std_logic_1164.all;

entity buffer_8portas is
    port(
        entrada  : in std_logic_vector(8 downto 0);
        habilita : in std_logic;
        saida    : out std_logic_vector(8 downto 0));
end entity;

architecture comportamento of buffer_8portas is
begin
    -- A saida esta ativa quando o habilita = 1.
    saida <= "ZZZZZZZZZ" when (habilita = '0') else entrada;
end architecture;