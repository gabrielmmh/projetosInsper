LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;  -- Biblioteca adicional para o uso de tipos numéricos padrão.

-- Declaração da entidade 'divisorGenerico', que define o módulo divisor de frequência.
entity divisorGenerico is
    port(
      clk      :   in std_logic;       -- Sinal de clock de entrada.
      divisor  :   in natural;         -- Divisor que define a frequência de saída.
      saida_clk :  out std_logic       -- Sinal de clock de saída, com frequência dividida.
    );
end entity;

-- Comentário geral sobre a entidade:
-- O valor "n" do divisor define a divisão por "2n".
-- Ou seja, n é metade do período da frequência de saída, determinando assim a frequência dividida.

-- Arquitetura 'divInteiro' do divisor genérico utilizando um contador simples.
architecture divInteiro of divisorGenerico is
    signal tick : std_logic := '0';  -- Sinal auxiliar que alterna estados para gerar o clock de saída.
    signal contador : integer range 0 to 50000001 := 0;  -- Contador para controle da divisão.

begin
    -- Processo que responde ao sinal de clock de entrada.
    process(clk)
    begin
        if rising_edge(clk) then  -- Ação tomada na borda de subida do clock.
            if contador = divisor then  -- Se o contador atinge o valor do divisor...
                contador <= 0;  -- O contador é reiniciado.
                tick <= not tick;  -- Inverte o estado do sinal 'tick'.
            else
                contador <= contador + 1;  -- Incrementa o contador.
            end if;
        end if;
    end process;

    saida_clk <= tick;  -- O sinal de saída do clock é igual ao sinal 'tick'.
end architecture divInteiro;