library ieee;
use ieee.std_logic_1164.all;

-- Definição da entidade CPU com parâmetros genéricos e portas de I/O
entity CPU is
  generic (
     larguraDados        : natural := 9; -- Largura dos dados manipulados pela CPU
     larguraAddr         : natural := 10; -- Largura do endereço de memória
     larguraInst         : natural := 17; -- Largura da instrução
     larguraEndBancoRegs : natural := 3; -- Largura do endereço do banco de registradores
     larguraStack      : natural := 3 -- Largura do endereço para uma Stack usada para pilha
  );
  port (
     -- Portas para debug e sinais de controle
     ULA_OUT: out std_logic_vector(8 downto 0);
     ULAOP_OUT: out std_logic_vector(1 downto 0);
     CS: out std_logic_vector(12 downto 0);

     -- Sinais de controle principal
     CLOCK   : in  std_logic;
     RST     : in  std_logic;
     Rd      : out std_logic;
     Wr      : out std_logic;

     -- Endereçamento e dados para memória de instrução e dados
     ROM_Address : out std_logic_vector(9 downto 0);
     Instruction_IN : in std_logic_vector(16 downto 0);
     Data_IN : in std_logic_vector(8 downto 0);
     Data_OUT : out std_logic_vector(8 downto 0);
     Data_Address : out std_logic_vector(9 downto 0)
  );
end entity;

architecture arch of CPU is
  -- Sinais internos para controle de dados, endereços e lógica de operações
  signal REGS_OUT : std_logic_vector(8 downto 0);
  signal REGS_Enable : std_logic;
  signal REGS_Addr : std_logic_vector(2 downto 0);

  -- Multiplexadores para seleção de dados
  signal MUX1_To_ULA_B : std_logic_vector(8 downto 0);
  signal MUX1_Select : std_logic;

  -- Controle do próximo endereço do PC
  signal NextPC : std_logic_vector(larguraAddr-1 downto 0);
  signal MUXProxPC_Select : std_logic_vector(1 downto 0);
  signal MUXProxPC_To_PC : std_logic_vector(9 downto 0);

  -- Gerenciamento de sub-rotinas e pilha
  signal RegRET : std_logic_vector(2 downto 0);
  signal Hab_Esc_SP : std_logic;
  signal FlagZero : std_logic;
  signal FlagNeg  : std_logic;
  signal Hab_Flag : std_logic;

  -- ULA e suas operações
  signal ULA_Output : std_logic_vector(8 downto 0);
  signal ULA_Operation : std_logic_vector(1 downto 0);
  signal ULAisZero : std_logic;
  signal ULAisNegative: std_logic;

  -- Decodificação de instruções e controle de sinais
  signal ControlSignals : std_logic_vector(12 downto 0);
  signal selOprt   : std_logic;
  signal incDecOut : std_logic_vector(2 downto 0);
  signal muxSROut  : std_logic_vector(2 downto 0);
  signal dadoLido  : std_logic_vector(9 downto 0);
  signal Hab_Re    : std_logic;
  signal Hab_We    : std_logic;

  -- Lógica de desvio condicional
  signal JMP : std_logic;
  signal JEQ : std_logic;
  signal JSR : std_logic;
  signal RET : std_logic;

  -- Controle de leitura e escrita de memória RAM e ROM
  signal RAM_ReadEnable : std_logic;
  signal RAM_WriteEnable : std_logic;
  signal sig_ROM_Address : std_logic_vector(9 downto 0);
  
  begin
  
    -- Instantiação do banco de registradores: armazena e fornece acesso rápido aos dados usados pela CPU.
    bancoReg : entity work.bancoRegistradoresArqRegMem generic map (
      larguraDados => larguraDados,
      larguraEndBancoRegs => larguraEndBancoRegs
    ) port map (
      clk => CLOCK,
      endereco => Instruction_IN(12 downto 10),  -- Endereço do registrador a ser acessado.
      dadoEscrita => ULA_Output,                 -- Dados de saída da ULA para escrita no registrador.
      habilitaEscrita => REGS_Enable,            -- Sinal para habilitar a escrita no registrador.
      saida => REGS_OUT                          -- Saída dos dados do registrador.
    );
    
    -- Instantiação de multiplexador para seleção dos dados de entrada da ULA.
    MUX1: entity work.muxGenerico2x1 generic map (larguraDados => larguraDados) port map (
      entradaA_MUX => Data_IN,                   -- Dados vindos da memória de dados.
      entradaB_MUX => Instruction_IN(8 downto 0),-- Dados imediatos vindos da instrução.
      seletor_MUX => MUX1_Select,                -- Seletor que escolhe a entrada para a ULA.
      saida_MUX => MUX1_To_ULA_B                 -- Saída do multiplexador para a ULA.
    );
    
    -- Instantiação de multiplexador para seleção do valor do Stack Pointer.
    MUX_SR: entity work.muxGenerico2x1 generic map (larguraDados => larguraStack) port map (
      entradaA_MUX => incDecOut,
      entradaB_MUX => RegRET,
      seletor_MUX => selOprt,
      saida_MUX => muxSROut
    );
    
    -- Incremento ou decremento do endereço do Stack Pointer.
    incDecAddr: entity work.inc_or_dec_addr generic map (larguraDados => larguraStack) port map (
      entrada => RegRET,
      seletor => selOprt,
      saida => incDecOut 
    );
    
    -- Instantiação do registrador do ponteiro de pilha (Stack Pointer).
    stackPointer: entity work.registradorGenerico generic map (larguraDados => larguraStack) port map (
      DIN => incDecOut, 
      DOUT => RegRET, 
      ENABLE => Hab_Esc_SP, 
      CLK => CLOCK,
      RST => RST
    );
    
    -- Instantiação da Stack usada para armazenamento temporário no contexto de chamadas de subrotina.
    Stack: entity work.memoriaRAM generic map (dataWidth => larguraAddr, addrWidth => larguraStack) port map (
      addr => muxSROut, 
      we => Hab_We, 
      re => Hab_Re,
      habilita => '1', 
      dado_in => NextPC, 
      dado_out => dadoLido, 
      clk => CLOCK
    );
    
    -- Multiplexador para determinar o próximo valor do PC com base em condições de desvio.
    MUXProxPC: entity work.muxGenerico4x1 generic map (larguraDados => larguraAddr) port map (
      entradaA_MUX => NextPC,
      entradaB_MUX => Instruction_IN(9 downto 0),
      entradaC_MUX => dadoLido,
      entradaD_MUX => "0000000000",
      seletor_MUX => MUXProxPC_Select,
      saida_MUX => MUXProxPC_To_PC
    );
    
    -- Flip-flops para manter os estados das flags Zero e Negativo.
    FF_Equal: entity work.FlipFlop port map (
      DIN => ULAisZero, 
      DOUT => FlagZero, 
      ENABLE => Hab_Flag, 
      CLK => CLOCK,
      RST => RST
    );
    
    FF_Neg: entity work.FlipFlop port map (
      DIN => ULAisNegative, 
      DOUT => FlagNeg, 
      ENABLE => Hab_Flag, 
      CLK => CLOCK,
      RST => RST
    );
    
    -- Registrador para armazenar e atualizar o endereço atual de execução (Program Counter).
    PC: entity work.registradorGenerico generic map (larguraDados => larguraAddr) port map (
      DIN => MUXProxPC_To_PC, 
      DOUT => sig_ROM_Address, 
      ENABLE => '1', 
      CLK => CLOCK,
      RST => RST
    );
    
    -- Adicionador constante para incrementar o PC a cada ciclo de instrução.
    incrementaPC: entity work.somaConstante generic map (larguraDados => larguraAddr, constante => 1) port map (
      entrada => sig_ROM_Address, 
      saida => NextPC
    );
    
    -- Instanciação da ULA para realizar operações aritméticas e lógicas.
    ULA: entity work.ULA generic map(larguraDados => larguraDados) port map (
      entradaA => REGS_OUT, 
      entradaB => MUX1_To_ULA_B, 
      saida => ULA_Output, 
      seletor => ULA_Operation
    );
    
    -- Decodificador de instruções para determinar sinais de controle com base no opcode.
    DEC_Instrucao: entity work.decoderInstru port map (
      opcode => Instruction_IN(16 downto 13), 
      flagE => FlagZero,
      flagN => FlagNeg,
      saida => ControlSignals
    );
    
    -- Lógica de controle para operações de desvio, como jumps e returns.
    BranchLogic: entity work.logicaDesvio port map (
      JMP => JMP, 
      RET => RET,
      saida => MUXProxPC_Select
    );
    
    -- Atribuições de saída para controle de leitura e escrita, e debug.
    Hab_Re <= ControlSignals(12);
    Hab_We <= ControlSignals(11);
    selOprt <= ControlSignals(10);
    Hab_Esc_SP <= ControlSignals(9);
    JMP <= ControlSignals(8);
    RET <= ControlSignals(7);
    MUX1_Select <= ControlSignals(6);
    REGS_Enable <= ControlSignals(5);
    ULA_Operation(1) <= ControlSignals(4);
    ULA_Operation(0) <= ControlSignals(3);
    Hab_Flag <= ControlSignals(2);
    RAM_ReadEnable <= ControlSignals(1);
    RAM_WriteEnable <= ControlSignals(0);
  
    Rd <= RAM_ReadEnable;
    Wr <= RAM_WriteEnable;
    ROM_Address <= sig_ROM_Address;
    Data_OUT <= REGS_OUT;
    Data_Address <= Instruction_IN(9 downto 0);
  
    -- Saídas de debug para monitoramento do estado da ULA e controle.
    ULA_OUT <= ULA_Output;
    ULAOP_OUT <= ULA_Operation;
    CS <= ControlSignals;
    
    -- Calcula condições de flag para zero e negativo baseado na saída da ULA.
    ULAisZero <= not (ULA_Output(7) or ULA_Output(6) or ULA_Output(5) or ULA_Output(4) 
     or ULA_Output(3) or ULA_Output(2) or ULA_Output(1) or ULA_Output(0));
    
    ULAisNegative <= ULA_Output(7);
    
  end arch;  