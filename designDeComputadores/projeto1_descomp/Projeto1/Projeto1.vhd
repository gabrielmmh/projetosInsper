library ieee;
use ieee.std_logic_1164.all;

----------------------------------------
-- Por Gabriel Hermida e Pedro Civita --
----------------------------------------

entity Projeto1 is
	-- Parâmetros genéricos definem as larguras de dados, endereços e instruções
	generic (
	  larguraDados : natural := 9;  -- largura dos dados manipulados pelo sistema
	  larguraRAM : natural := 6;    -- largura do endereço de RAM
	  larguraAddr: natural := 10;   -- largura do endereço utilizado, e.g., PC, ROM
	  larguraInst : natural := 17   -- largura das instruções completas
	  --simulacao : boolean := TRUE-- opção para compilação condicional dependendo do alvo
	);
  -- Portas de entrada e saída definem os sinais utilizados pelo sistema
  port (
    CLOCK_50 : in std_logic;        -- Clock principal de 50 MHz

    PC_OUT  : out std_logic_vector(larguraAddr-1 downto 0);  -- Saída para o endereço do PC

    LEDR : out std_logic_vector(9 downto 0);  -- Saídas de LEDs para status ou debug

    HEX0: out std_logic_vector(6 downto 0);   -- Saídas para displays de sete segmentos
    HEX1: out std_logic_vector(6 downto 0);
    HEX2: out std_logic_vector(6 downto 0);
    HEX3: out std_logic_vector(6 downto 0);
    HEX4: out std_logic_vector(6 downto 0);
    HEX5: out std_logic_vector(6 downto 0);

    -- Saídas de debug para observar operações internas em tempo real
    DA_out: out std_logic_vector(larguraAddr-1 downto 0);
    DIN_out: out std_logic_vector(larguraDados-1 downto 0);
    DOUT_out: out std_logic_vector(larguraDados-1 downto 0);
    BLOCO_out: out std_logic_vector(larguraDados-1 downto 0);

    RDD: out std_logic; -- Leitura de dados
    WRR: out std_logic; -- Escrita de dados

    Opcode_OUT: out std_logic_vector(3 downto 0); -- Saída do opcode atual
    Instruction_OUT : out std_logic_vector(16 downto 0); -- Saída da instrução completa

	-- Sinais de controle para a ULA
    ULA_OUT: out std_logic_vector(8 downto 0); 
    ULAOP_OUT: out std_logic_vector(1 downto 0);

    CS: out std_logic_vector(12 downto 0); -- Sinais de controle
    SW  : in std_logic_vector(9 downto 0); -- Switches de entrada
    KEY : in std_logic_vector(3 downto 0); -- Botões de entrada
    FPGA_RESET_N : in std_logic -- Sinal de reset externo
  );
end entity;

-- Arquitetura do Projeto1, descrevendo a lógica e conexão entre sinais internos e entidades
architecture arquitetura of Projeto1 is
  -- Sinais internos para controle de operações e estado
  signal CLK         : std_logic;  -- Sinal de clock processado internamente
  signal Wr          : std_logic;  -- Sinal de escrita
  signal Rd          : std_logic;  -- Sinal de leitura
  
  -- Sinais para tratamento de entradas de botões com debounce
  signal KEY_0_TRT1  : std_logic;
  signal KEY_0_TRT2  : std_logic;
  signal KEY_1_TRT1  : std_logic;
  signal KEY_1_TRT2  : std_logic;
  signal KEY_2_TRT1  : std_logic;
  signal KEY_2_TRT2  : std_logic;
  signal KEY_3_TRT1  : std_logic;
  signal KEY_3_TRT2  : std_logic;
  signal RST_TRT1    : std_logic;  -- Sinal tratado de reset
  signal RST_TRT2    : std_logic;  -- Sinal tratado de reset
  
  -- Sinais para controle de reset dos botões e contador de tempo
  signal limpaLeitura_KEY_0       : std_logic;
  signal limpaLeitura_KEY_1       : std_logic;
  signal limpaLeitura_KEY_2       : std_logic;
  signal limpaLeitura_KEY_3       : std_logic;
  signal limpaLeitura_TimeCounter : std_logic;
  
  -- Sinais para ajuste de velocidade de operação ou simulação
  signal velocidade  : std_logic_vector(1 downto 0);
  signal divisor     : natural;  -- Controla divisão de tempo
  
  -- Sinais de endereço e dados para memória e instruções
  signal ROM_Address : std_logic_vector(larguraAddr-1 downto 0);
  signal dataAddress : std_logic_vector(larguraAddr-1 downto 0);
  
  -- Sinais para dados de instrução e saídas de registros
  signal instruction : std_logic_vector(larguraInst-1 downto 0);
  
  signal leituraDados: std_logic_vector(larguraDados-1 downto 0); -- Dados lidos
  signal REGS_OUT    : std_logic_vector(larguraDados-1 downto 0); -- Dados de saída dos registros
  signal Bloco       : std_logic_vector(larguraDados-1 downto 0); -- Controle de bloco de memória
  signal enderecoDec : std_logic_vector(larguraDados-1 downto 0); -- Decodificação de endereço

  begin
	-- Atribui o clock do sistema a um sinal interno CLK para uso em toda a arquitetura.
	CLK <= CLOCK_50;
  
	-- Passa o endereço atual do contador de programa para uma saída externa, PC_OUT.
	PC_OUT <= ROM_Address;
	
	-- Limpeza condicional de leitura dos botões baseada em endereços e condição de escrita.

	-- @511: Limpa o estado do botão 0 se a condição específica de endereço e escrita for verdadeira.
	limpaLeitura_KEY_0      <= dataAddress(8) AND dataAddress(7) AND dataAddress(6) AND dataAddress(5) AND dataAddress(4) AND 
						            dataAddress(3) AND dataAddress(2) AND dataAddress(1) AND dataAddress(0) AND Wr;

	-- @510: Limpa o estado do botão 1 com uma condição ligeiramente alterada (bit menos significativo invertido).
	limpaLeitura_KEY_1      <= dataAddress(8) AND dataAddress(7) AND dataAddress(6) AND dataAddress(5) AND dataAddress(4) AND 
						            dataAddress(3) AND dataAddress(2) AND dataAddress(1) AND (NOT dataAddress(0)) AND Wr;

	-- @509: Limpa o estado do botão 2, modificando outra parte do endereço.					
	limpaLeitura_KEY_2      <= dataAddress(8) AND dataAddress(7) AND dataAddress(6) AND dataAddress(5) AND dataAddress(4) AND 
						            dataAddress(3) AND dataAddress(2) AND (NOT dataAddress(1)) AND dataAddress(0) AND Wr;

	-- @508: Limpa o estado do botão 3, com duas partes do endereço invertidas.
	limpaLeitura_KEY_3      <= dataAddress(8) AND dataAddress(7) AND dataAddress(6) AND dataAddress(5) AND dataAddress(4) AND 
						            dataAddress(3) AND dataAddress(2) AND (NOT dataAddress(1)) AND (NOT dataAddress(0)) AND Wr;

	-- @507: Limpa o contador de tempo sob condições específicas de endereço e escrita.						 
	limpaLeitura_TimeCounter <= dataAddress(8) AND dataAddress(7) AND dataAddress(6) AND dataAddress(5) AND dataAddress(4) AND 
						            dataAddress(3) AND (NOT dataAddress(2)) AND dataAddress(1) AND dataAddress(0) AND Wr;
	
	-- Saídas de debug para monitoramento dos sinais internos e estados relevantes.
	DA_out <= dataAddress;            -- Mostra o endereço de dados atual.
	DIN_out <= leituraDados;          -- Mostra os dados sendo lidos.
	DOUT_out <= REGS_OUT;             -- Mostra os dados de saída dos registradores.
	BLOCO_out <= Bloco;               -- Mostra o estado do bloco atual (útil para memória segmentada).
	RDD <= Rd;                        -- Indica se uma operação de leitura está ativa.
	WRR <= Wr;                        -- Indica se uma operação de escrita está ativa.
	Opcode_OUT <= instruction(16 downto 13); -- Extrai o opcode da instrução atual para debug.
	Instruction_OUT <= instruction(16 downto 0); -- Mostra a instrução completa para análise.

	-- Instanciação da CPU com mapeamento genérico e mapeamento de portas
	CPU : entity work.CPU generic map(
		larguraDados => larguraDados,  -- Define a largura dos dados usados pela CPU
		larguraAddr => larguraAddr     -- Define a largura dos endereços usados pela CPU
	) port map (
		CLOCK => CLK,                  -- Clock do sistema conectado à CPU
		RST => RST_TRT1,               -- Sinal de reset tratado conectado à CPU
		Rd => Rd,                      -- Sinal de leitura disponível para a CPU
		Wr => Wr,                      -- Sinal de escrita disponível para a CPU
		ROM_Address => ROM_Address,    -- Endereço de ROM conectado à CPU
		Instruction_IN => instruction, -- Instrução atual sendo passada para a CPU
		Data_IN => leituraDados,       -- Dados de entrada para a CPU vindo da RAM
		Data_OUT => REGS_OUT,          -- Saída de dados da CPU para a RAM
		Data_Address => dataAddress,   -- Endereço de dados manipulado pela CPU
		ULA_OUT => ULA_OUT,            -- Saída da ULA para fins de depuração
		ULAOP_OUT => ULAOP_OUT,        -- Operação da ULA para fins de depuração
		CS => CS                       -- Sinais de controle da CPU
	);

	-- Instanciação da memória ROM
	ROM : entity work.memoriaROM generic map (
		dataWidth => larguraInst,      -- Largura das instruções que a ROM irá armazenar
		addrWidth => larguraAddr       -- Largura do endereço para a ROM
	) port map (
		Endereco => ROM_Address,       -- Endereço de leitura conectado à ROM
		Dado => instruction            -- Instrução lida da ROM
	);			  
					
	-- Instanciação da memória RAM
	RAM : entity work.memoriaRAM  generic map (
		dataWidth => larguraDados,     -- Largura dos dados que a RAM irá armazenar
		addrWidth => larguraRAM        -- Largura do endereço para a RAM
	) port map (
		addr => dataAddress(5 downto 0), -- Endereço de dados para a RAM
		we => Wr,                       -- Sinal de escrita para a RAM
		re => Rd,                       -- Sinal de leitura para a RAM
		habilita => Bloco(0),           -- Habilitação de segmento de memória específico
		dado_in => REGS_OUT,            -- Dados de entrada para a RAM
		dado_out => leituraDados,       -- Dados de saída da RAM
		clk => CLK                      -- Clock conectado à RAM
	);

	-- Decodificação de blocos de memória
	DecBloc : entity work.decoder3x8
		port map (
		entrada => dataAddress(8 downto 6), -- Entrada do decodificador de bloco
		saida => Bloco                      -- Saída para seleção de bloco
	);

	-- Decodificação de endereço dentro do bloco
	DecAddr : entity work.decoder3x8
		port map (
		entrada => dataAddress(2 downto 0), -- Entrada do decodificador de endereço
		saida => enderecoDec                -- Saída para seleção de endereço específico
	);

	-- Controle de LEDs para indicar estados ou valores
	LEDs: entity work.leds
		port map (
		clk => clk,                         -- Clock do sistema
		escrita => Wr,                      -- Sinal de escrita para ativar LEDs
		dadosEntrada => REGS_OUT(7 downto 0), -- Dados de entrada para os LEDs
		Bloco => Bloco(4),                  -- Uso de um bloco específico para controle
		A5 => dataAddress(5),
		endereco => enderecoDec(2 downto 0),
		ledsV => LEDR(7 downto 0),          -- Saída para LEDs individuais
		led1 => LEDR(8), 
		led2 => LEDR(9)
	);

	-- Controle dos displays de sete segmentos
	DISPLAYs: entity work.displays
		port map (
		clk => clk,                         -- Clock do sistema
		escrita => Wr,                      -- Sinal de escrita para controlar displays
		dadosEntrada => REGS_OUT(3 downto 0), -- Dados de entrada para os displays
		Bloco => Bloco(4),                  -- Uso de um bloco específico para controle
		A5 => dataAddress(5),
		endereco => enderecoDec(5 downto 0),
		disp0 => HEX0,                      -- Conexões individuais para cada display
		disp1 => HEX1,
		disp2 => HEX2,
		disp3 => HEX3,
		disp4 => HEX4,
		disp5 => HEX5
	);

	-- Processamento de entradas de switches
	bufferSW: entity work.buffer_8portas
		port map (
		entrada => '0' & SW(7 downto 0),    -- Entrada extendida com '0' para alinhamento
		habilita => Rd AND enderecoDec(0) AND Bloco(5) AND NOT dataAddress(5),
		saida => leituraDados               -- Saída de dados processados pelos switches
	);

	--	KEY 0 @352
	-- Detecção de borda para o botão 0
	detector_Borda_Key0: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50,                   -- Clock do sistema
			entrada => NOT KEY(0),             -- Inverte o sinal do botão 0
			saida => KEY_0_TRT1                -- Saída vai para o tratamento do flip flop
		);

	-- Flip Flop para estabilização do sinal do botão 0
	FF_Key0: entity work.FlipFlop
		port map (
			DIN => '1',                        -- Entrada fixa em '1'
			DOUT => KEY_0_TRT2,                -- Saída tratada do sinal do botão 0
			ENABLE => '1',                     -- Sempre habilitado
			CLK => KEY_0_TRT1,                 -- Operado no sinal tratado de borda
			RST => limpaLeitura_KEY_0          -- Reset baseado na condição específica de endereço
		);

	-- Buffer para armazenar o estado tratado do botão 0
	buffer_Key0: entity work.buffer_1porta
		port map (
			entrada => KEY_0_TRT2,             -- Entrada do estado tratado
			habilita => Rd AND enderecoDec(0) AND Bloco(5) AND dataAddress(5), -- Habilitado sob condições específicas
			saida => leituraDados(0)           -- Saída para o dado lido
		);

	--	KEY 1 @353
	-- Detecção de borda para o botão 1
	detector_Borda_Key1: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50,                   -- Clock do sistema
			entrada => NOT KEY(1),             -- Inverte o sinal do botão 1
			saida => KEY_1_TRT1                -- Saída vai para o tratamento do flip flop
		);

	-- Flip Flop para estabilização do sinal do botão 1
	FF_Key1: entity work.FlipFlop
		port map (
			DIN => '1',                        -- Entrada fixa em '1'
			DOUT => KEY_1_TRT2,                -- Saída tratada do sinal do botão 1
			ENABLE => '1',                     -- Sempre habilitado
			CLK => KEY_1_TRT1,                 -- Operado no sinal tratado de borda
			RST => limpaLeitura_KEY_1          -- Reset baseado na condição específica de endereço
		);

	-- Buffer para armazenar o estado tratado do botão 1
	buffer_Key1: entity work.buffer_1porta
		port map (
			entrada => KEY_1_TRT2,             -- Entrada do estado tratado
			habilita => Rd AND enderecoDec(1) AND Bloco(5) AND dataAddress(5), -- Habilitado sob condições específicas
			saida => leituraDados(0)           -- Saída para o dado lido
		);

	--	KEY 2 @354
	-- Detecção de borda para o botão 2
	detector_Borda_Key2: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50, 
			entrada => NOT KEY(2), 
			saida => KEY_2_TRT1
		);

	-- Flip Flop para estabilização do sinal do botão 2
	FF_Key2: entity work.FlipFlop
		port map (
			DIN => '1', 
			DOUT => KEY_2_TRT2, 
			ENABLE => '1', 
			CLK => KEY_2_TRT1,
			RST => limpaLeitura_KEY_2
		);

	-- Buffer para armazenar o estado tratado do botão 2
	buffer_Key2: entity work.buffer_1porta
		port map (
			entrada => KEY_2_TRT2,
			habilita => Rd AND enderecoDec(2) AND Bloco(5) AND dataAddress(5),
			saida => leituraDados(0) 
		);

	--	KEY 3 @355
	-- Detecção de borda para o botão 3
	detector_Borda_Key3: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50, 
			entrada => NOT KEY(3), 
			saida => KEY_3_TRT1
		);

	-- Flip Flop para estabilização do sinal do botão 3
	FF_Key3: entity work.FlipFlop
		port map (
			DIN => '1', 
			DOUT => KEY_3_TRT2, 
			ENABLE => '1', 
			CLK => KEY_3_TRT1,
			RST => limpaLeitura_KEY_3
		);

	-- Buffer para armazenar o estado tratado do botão 3
	buffer_Key3: entity work.buffer_1porta
		port map (
			entrada => KEY_3_TRT2,
			habilita => Rd AND enderecoDec(3) AND Bloco(5) AND dataAddress(5),
			saida => leituraDados(0) 
		);

	-- Detecção e tratamento do sinal de reset (direto para a CPU, então não atribuímos endereço).
	detector_Borda_Rst: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50, 
			entrada => NOT FPGA_RESET_N, 
			saida => RST_TRT1
		);

	-- TIME COUNTER @356
	-- Configuração do contador de tempo baseado em switches
	muxVel: entity work.muxNat4x1 
	port map (
		entradaA_MUX => 25000000,          -- Diferentes divisores de tempo
		entradaB_MUX => 250000,
		entradaC_MUX => 25000,
		entradaD_MUX => 2500,
		seletor_MUX => SW(9 downto 8),     -- Seleção via switches
		saida_MUX => divisor               -- Saída para o divisor selecionado
	);

	-- Interface para o contador de tempo que usa o divisor configurado
	interfaceBaseTempo : entity work.divisorGenerico_e_Interface
	port map (
		clk => CLOCK_50,
		habilitaLeitura => Rd AND enderecoDec(4) AND Bloco(5) AND dataAddress(5),
		limpaLeitura => limpaLeitura_TimeCounter, -- Limpeza baseada em condições específicas de endereço
		div => divisor,
		leituraUmSegundo => leituraDados(0)       -- Saída da contagem de um segundo
	);

end architecture;