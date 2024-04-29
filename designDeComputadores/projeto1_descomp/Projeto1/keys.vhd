library ieee;
use ieee.std_logic_1164.all;

entity keys is
    port (
        rd: in std_logic;                    -- Sinal de leitura, indica quando as chaves devem ser lidas.
        bloco: in std_logic;                 -- Sinal de seleção de bloco, usado para ativar a leitura neste módulo.
        endereco: in std_logic_vector(5 downto 0); -- Endereço, usado para selecionar qual chave está sendo acessada.
        clk : in std_logic;                  -- Clock, não utilizado diretamente neste trecho.
        A5  : in std_logic;                  -- Sinal adicional para controle de acesso.
        KEY0 : in std_logic;                 -- Entrada da chave 0.
        KEY1 : in std_logic;                 -- Entrada da chave 1.
        KEY2 : in std_logic;                 -- Entrada da chave 2.
        KEY3 : in std_logic;                 -- Entrada da chave 3.
        RESET_KEY : in std_logic;            -- Entrada para um botão de reset.
        leituraDados : out std_logic_vector(7 downto 0) -- Saída dos dados lidos das chaves.
    );
end entity;

architecture comportamento of keys is
begin
    -- Buffer para a chave 0.
    buffer_Key0: entity work.buffer_1porta
        port map (
            entrada => KEY0,
            habilita => rd AND endereco(0) AND bloco AND A5,
            saida => leituraDados(0)
        );
    
    -- Buffer para a chave 1.
    buffer_Key1: entity work.buffer_1porta
        port map (
            entrada => KEY1,
            habilita => rd AND endereco(1) AND bloco AND A5,
            saida => leituraDados(0) 
        );
    
    -- Buffer para a chave 2.
    buffer_Key2: entity work.buffer_1porta
        port map (
            entrada => KEY2,
            habilita => rd AND endereco(2) AND bloco AND A5,
            saida => leituraDados(0) 
        );
    
    -- Buffer para a chave 3.
    buffer_Key3: entity work.buffer_1porta
        port map (
            entrada => KEY3,
            habilita => rd AND endereco(3) AND bloco AND A5,
            saida => leituraDados(0) 
        );

    -- Buffer para o botão de reset.
    buffer_Reset: entity work.buffer_1porta
        port map (
            entrada => RESET_KEY,
            habilita => rd AND endereco(4) AND bloco AND A5,
            saida => leituraDados(0) 
        );
end architecture;
