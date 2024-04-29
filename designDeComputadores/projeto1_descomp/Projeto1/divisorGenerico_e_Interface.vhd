LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;  -- Importação de bibliotecas IEEE para lógica e tipos numéricos padrão.

-- Entidade 'divisorGenerico_e_Interface' descreve um divisor de frequência com interface para controle externo.
entity divisorGenerico_e_Interface is
   port(
      clk      :   in std_logic;             -- Clock de entrada para a base do divisor.
      habilitaLeitura : in std_logic;        -- Sinal para habilitar a leitura da saída.
      limpaLeitura : in std_logic;           -- Sinal para resetar a saída.
      div : in natural;                      -- Fator de divisão para o divisor de clock.
      leituraUmSegundo :   out std_logic     -- Saída do sinal dividido, controlada pela habilitação.
   );
end entity;

-- Arquitetura 'interface' para a entidade divisorGenerico_e_Interface.
architecture interface of divisorGenerico_e_Interface is
  signal sinalUmSegundo : std_logic;          -- Sinal intermediário que representa o clock dividido.
  signal saidaclk_reg1seg : std_logic;        -- Sinal de saída do divisor de clock.

begin
  -- Instanciação do componente 'divisorGenerico' para dividir o clock de entrada.
  baseTempo: entity work.divisorGenerico
             port map (
               clk => clk, 
               divisor => div, 
               saida_clk => saidaclk_reg1seg
             );

  -- Flip-flop para manter o estado do sinal um segundo após a divisão do clock.
  registraUmSegundo: entity work.FlipFlop
     port map (
       DIN => '1',                      -- Dado de entrada fixo (normalmente usado para definir o estado).
       DOUT => sinalUmSegundo,          -- Saída do flip-flop conectada ao sinal intermediário.
       ENABLE => '1',                   -- Habilitação do flip-flop (sempre ativo).
       CLK => saidaclk_reg1seg,         -- Clock do flip-flop, recebendo o clock dividido.
       RST => limpaLeitura              -- Reset do flip-flop controlado externamente.
     );

  -- Saída tristate controlada pelo sinal 'habilitaLeitura'.
  -- Quando habilitada, a saída mostra 'sinalUmSegundo'; caso contrário, fica em alta impedância ('Z').
  leituraUmSegundo <= sinalUmSegundo when habilitaLeitura = '1' else 'Z';

end architecture interface;