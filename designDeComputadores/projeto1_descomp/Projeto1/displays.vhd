library ieee;
use ieee.std_logic_1164.all;

entity displays is
    port (
        escrita: in std_logic;
        dadosEntrada: in std_logic_vector(3 downto 0);
        bloco: in std_logic;
        endereco: in std_logic_vector(5 downto 0);
        clk: in std_logic;
		  A5: in std_logic;
        disp0: out std_logic_vector(6 downto 0);
        disp1: out std_logic_vector(6 downto 0);
        disp2: out std_logic_vector(6 downto 0);
		  disp3: out std_logic_vector(6 downto 0);
        disp4: out std_logic_vector(6 downto 0);
        disp5: out std_logic_vector(6 downto 0)
    );
end entity;

architecture comportamento of displays is

    signal saidaReg0: std_logic_vector(3 downto 0);
	 signal saidaReg1: std_logic_vector(3 downto 0);
	 signal saidaReg2: std_logic_vector(3 downto 0);
	 signal saidaReg3: std_logic_vector(3 downto 0);
	 signal saidaReg4: std_logic_vector(3 downto 0);
	 signal saidaReg5: std_logic_vector(3 downto 0);
	 
	 signal saidaDisp0: std_logic_vector(6 downto 0);
	 signal saidaDisp1: std_logic_vector(6 downto 0);
	 signal saidaDisp2: std_logic_vector(6 downto 0);
	 signal saidaDisp3: std_logic_vector(6 downto 0);
	 signal saidaDisp4: std_logic_vector(6 downto 0);
	 signal saidaDisp5: std_logic_vector(6 downto 0);
	 
begin
    -- Registradores dos Displays
    registrador0: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg0, 
		  ENABLE => escrita AND endereco(0) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );
	 
	 registrador1: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg1, 
		  ENABLE => escrita AND endereco(1) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );
		  
	 registrador2: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg2, 
		  ENABLE => escrita AND endereco(2) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );
		  
	 registrador3: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg3, 
		  ENABLE => escrita AND endereco(3) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );

	 registrador4: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg4, 
		  ENABLE => escrita AND endereco(4) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );
		  
	 registrador5: entity work.registradorGenerico
        generic map (larguraDados => 4)
        port map (
		  DIN => dadosEntrada, 
		  DOUT => saidaReg5, 
		  ENABLE => escrita AND endereco(5) AND bloco AND A5, 
		  CLK => clk,
		  RST => '0'
		  );
	  
	 -- Conversores dos Displays
		  
    conversor0: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg0,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp0
		  );
		 
	 conversor1: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg1,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp1
		  );
	 
	 conversor22: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg2,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp2
		  );
		  
	 conversor3: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg3,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp3
		  );
		  
	 conversor4: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg4,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp4
		  );
		  
	 conversor5: entity work.conversorHex7Seg
		  port map (
		  dadoHex => saidaReg5,
		  apaga => '0',
		  negativo => '0',
		  overFlow => '0',
		  saida7seg => saidaDisp5
		  );
		  
		  
    -- Atribuição dos sinais de saída dos Displays
	 
    disp0 <= saidaDisp0;
	 disp1 <= saidaDisp1;
	 disp2 <= saidaDisp2;
	 disp3 <= saidaDisp3;
	 disp4 <= saidaDisp4;
	 disp5 <= saidaDisp5;


end architecture;
