library ieee;
use ieee.std_logic_1164.all;

-- Declaração da entidade 'switchs' com suas entradas e saídas.
entity switchs is
    port (
        rd: in std_logic;                       -- Sinal de leitura, ativa a leitura dos switches
        bloco: in std_logic;                    -- Sinal que indica se o bloco relevante está ativo
        endereco: in std_logic_vector(5 downto 0); -- Endereço para identificar qual switch está sendo acessado
        A5  : in std_logic;                     -- Sinal adicional para condicionar a leitura
        SW0_7: in std_logic_vector(7 downto 0); -- Vetor de entradas dos switches 0 a 7
        SW8 : in std_logic;                     -- Entrada do switch 8
        SW9 : in std_logic;                     -- Entrada do switch 9
        leituraDados : out std_logic_vector(7 downto 0) -- Saída dos dados lidos dos switches
    );
end entity;

-- Arquitetura comportamental da entidade 'switchs'.
architecture comportamento of switchs is
begin
    -- Buffer para os switches de 0 a 7.
    bufferSW: entity work.buffer_8portas
        port map (
            entrada => SW0_7,                      -- Entrada direta dos switches 0 a 7
            habilita => rd AND endereco(0) AND bloco AND NOT A5, -- Condição de habilitação baseada no sinal de leitura, endereço, bloco e A5
            saida => leituraDados                  -- Os dados lidos são enviados para a saída
        );

    -- Buffer para o switch 8.
    bufferSW8: entity work.buffer_1porta
        port map (
            entrada => SW8,                        -- Entrada do switch 8
            habilita => rd AND endereco(1) AND bloco AND NOT A5, -- Condição de habilitação específica para o switch 8
            saida => leituraDados(0)               -- O estado do switch 8 é colocado no bit mais baixo dos dados de saída
        );

    -- Buffer para o switch 9.
    bufferSW9: entity work.buffer_1porta
        port map (
            entrada => SW9,                        -- Entrada do switch 9
            habilita => rd AND endereco(2) AND bloco AND NOT A5, -- Condição de habilitação específica para o switch 9
            saida => leituraDados(0)               -- O estado do switch 9 é colocado no bit mais baixo dos dados de saída
        );
end architecture;
