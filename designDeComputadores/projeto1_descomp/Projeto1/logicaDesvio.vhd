library ieee;
use ieee.std_logic_1164.all;

-- Declaração da entidade logicaDesvio, que define as portas para entradas de controle JMP e RET
-- e uma saída de vetor de dois bits que determinará o comportamento de desvio.
entity logicaDesvio is
  port ( 
    JMP : in std_logic;          -- Sinal de entrada para comando de Jump (salto condicional)
    RET : in std_logic;          -- Sinal de entrada para comando de Return (retorno de subrotina)
    saida : out std_logic_vector(1 downto 0)  -- Saída que determina a ação de desvio a ser tomada
  );
end entity;

-- Arquitetura comportamental da entidade logicaDesvio
architecture comportamento of logicaDesvio is

  -- Constantes para representar os estados lógicos ativo e desativo
  constant ativo  : std_logic := '1';
  constant desativo  : std_logic := '0';

  begin
    -- A saída é definida baseada nos sinais de entrada JMP e RET
    saida <= "01" when (JMP = ativo) else  -- Se JMP está ativo, a saída será "01"
            "10" when (RET = ativo) else  -- Se RET está ativo, a saída será "10"
            "00";                          -- Se nenhum está ativo, a saída será "00"
         
end architecture;