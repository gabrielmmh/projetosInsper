library ieee;
use ieee.std_logic_1164.all;

entity leds is
    port (
        escrita: in std_logic;
        dadosEntrada: in std_logic_vector(7 downto 0);
        bloco: in std_logic;
        endereco: in std_logic_vector(2 downto 0);
        clk: in std_logic;
		  A5: in std_logic;
        led1: out std_logic;
        led2: out std_logic;
        ledsV: out std_logic_vector(7 downto 0)
    );
end entity;

architecture comportamento of leds is
    -- Sinais de saída internos para os LEDs
    signal saidaLedsV: std_logic_vector(7 downto 0);
    signal saidaLed1: std_logic;
    signal saidaLed2: std_logic;

begin
    -- Registro para os LEDs vermelhos
    RegistradorLedsV: entity work.registradorGenerico
        generic map (larguraDados => 8)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaLedsV, 
		  ENABLE => escrita AND endereco(0) AND bloco AND NOT a5, 
		  CLK => clk,
		  RST => '0'
		  );

    -- Registro para o LED1
    RegistradorLed1: entity work.FlipFlop
        port map (
		  DIN => dadosEntrada(0), 
		  DOUT => saidaLed1, 
		  ENABLE => escrita AND endereco(1) AND bloco AND NOT a5, 
		  CLK => clk,
		  RST => '0'
		  );

    -- Registro para o LED2
    RegistradorLed2: entity work.FlipFlop
        port map (
		  DIN => dadosEntrada(0), 
		  DOUT => saidaLed2, 
		  ENABLE => escrita AND endereco(2) AND bloco AND NOT a5, 
		  CLK => clk,
		  RST => '0'
		  );

    -- Atribuição direta dos sinais de saída para os LEDs
    ledsV <= saidaLedsV;
    led1 <= saidaLed1;
    led2 <= saidaLed2;

end architecture;
