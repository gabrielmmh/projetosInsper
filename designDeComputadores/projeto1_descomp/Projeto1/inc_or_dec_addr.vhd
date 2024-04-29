library ieee;
use ieee.std_logic_1164.all;  -- Importa a biblioteca padrão para operações lógicas.
use ieee.numeric_std.all;     -- Importa a biblioteca para operações aritméticas.

-- Declaração da entidade 'inc_or_dec_addr'.
entity inc_or_dec_addr is
    generic
    (
        larguraDados : natural := 3;  -- Define a largura do vetor de dados.
        constante : natural := 1      -- Define o valor da constante de incremento ou decremento.
    );
    port (
      entrada:  in STD_LOGIC_VECTOR((larguraDados-1) downto 0);  -- Entrada do vetor de dados.
      seletor:  in std_logic;  -- Seletor para decidir entre incremento ('1') ou decremento ('0').
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0)  -- Saída do vetor de dados após operação.
    );
end entity;

-- Arquitetura 'comportamento' do incrementador ou decrementador de endereço.
architecture comportamento of inc_or_dec_addr is

   signal point_next     : STD_LOGIC_VECTOR((larguraDados-1) downto 0);  -- Sinal intermediário para o valor incrementado.
   signal point_previous : STD_LOGIC_VECTOR((larguraDados-1) downto 0);  -- Sinal intermediário para o valor decrementado.
    
	begin
		-- Calcula o valor incrementado da entrada e converte de volta para std_logic_vector.
		point_next     <= std_logic_vector(unsigned(entrada) + constante);
      -- Calcula o valor decrementado da entrada e converte de volta para std_logic_vector.
      point_previous <= std_logic_vector(unsigned(entrada) - constante);
		
      -- Atribui ao sinal de saída o valor incrementado ou decrementado baseado no valor do seletor.
      saida <= point_next when (seletor = '1') else
					point_previous;
end architecture;