library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULA is
    generic ( larguraDados : natural := 4 );
    port (
      entradaA, entradaB:  in STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      seletor:  in std_logic_vector(1 downto 0);
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0)
    );
end entity;

architecture comportamento of ULA is

   signal soma :      STD_LOGIC_VECTOR((larguraDados-1) downto 0);
   signal subtracao : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal passa : 	 STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal op_and : 	 STD_LOGIC_VECTOR((larguraDados-1) downto 0);
    
	begin
		subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
      soma      <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
		passa     <= entradaB;
		op_and    <= STD_LOGIC_VECTOR(entradaA AND entradaB);
		
      saida <= subtracao when (seletor = "00") else
		         soma      when (seletor = "01") else 
					op_and    when (seletor = "10") else
					passa;
end architecture;