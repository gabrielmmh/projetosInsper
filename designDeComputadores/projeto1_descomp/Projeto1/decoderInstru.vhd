library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port (
    opcode : in std_logic_vector(3 downto 0); -- Código da operação a ser decodificada
    flagE  : in std_logic;                    -- Flag de igualdade, usada em decisões condicionais
    flagN  : in std_logic;                    -- Flag de negativo, usada em decisões condicionais
    saida : out std_logic_vector(12 downto 0) -- Saída de sinais de controle
  );
end entity;

architecture comportamento of decoderInstru is
  -- Aliases para facilitar a leitura e associação de cada bit da saída a um sinal de controle específico.
  alias RAM_WriteEnable : std_logic is saida(0);
  alias RAM_ReadEnable : std_logic is saida(1);
  alias Hab_Flag : std_logic is saida(2);
  alias ULA_Operation : std_logic_vector(1 downto 0) is saida(4 downto 3);
  alias REGA_Enable : std_logic is saida(5);
  alias MUX1_Select : std_logic is saida(6);
  alias RET_B : std_logic is saida(7);
  alias JMP_B : std_logic is saida(8);
  alias Hab_Esc_SP : std_logic is saida(9);
  alias selOprt : std_logic is saida(10);
  alias Hab_We : std_logic is saida(11);
  alias Hab_Re : std_logic is saida(12);

  -- Declaração de constantes para representar cada opcode.
  constant NOP   : std_logic_vector(3 downto 0) := "0000";
  constant LDA   : std_logic_vector(3 downto 0) := "0001";
  constant SOMA  : std_logic_vector(3 downto 0) := "0010";
  constant SUB   : std_logic_vector(3 downto 0) := "0011";
  constant LDI   : std_logic_vector(3 downto 0) := "0100";
  constant STA   : std_logic_vector(3 downto 0) := "0101";
  constant JMP   : std_logic_vector(3 downto 0) := "0110";
  constant JEQ   : std_logic_vector(3 downto 0) := "0111";
  constant CHECK : std_logic_vector(3 downto 0) := "1000";
  constant JSR   : std_logic_vector(3 downto 0) := "1001";
  constant RET   : std_logic_vector(3 downto 0) := "1010";
  constant ANDI  : std_logic_vector(3 downto 0) := "1011"; -- ANDI = AND INSTRUCTION (AND é uma palavra reservada em VHDL)
  constant JLT   : std_logic_vector(3 downto 0) := "1100";
  constant JNE   : std_logic_vector(3 downto 0) := "1101";

  begin
    -- Atribuição condicional de sinais de controle baseada no opcode e nas flags.
    RAM_WriteEnable <= '1' when (opcode = STA) else '0';
    RAM_ReadEnable  <= '1' when (opcode = LDA OR opcode = SOMA OR opcode = SUB OR opcode = CHECK OR opcode = ANDI) else '0';
    Hab_Flag        <= '1' when (opcode = CHECK) else '0';
    ULA_Operation   <= "00" when (opcode = SUB OR opcode = CHECK) else 
                        "01" when (opcode = SOMA) else
                        "10" when (opcode = ANDI) else
                        "11";
    REGA_ENABLE     <= '1' when (opcode = LDA OR opcode = SOMA OR opcode = SUB OR opcode = LDI OR opcode = ANDI) else '0';
    MUX1_SELECT     <= '1' when (opcode = LDI) else '0';
    RET_B           <= '1' when (opcode = RET) else '0';
    JMP_B           <= '1' when (opcode = JMP) OR (opcode = JLT AND flagN = '1') OR 
                        (opcode = JEQ AND flagE = '1') OR (opcode = JNE AND flagE = '0') OR
                        (opcode = JSR) else '0';
    Hab_Esc_SP      <= '1' when (opcode = JSR) OR (opcode = RET) else '0';
    selOprt         <= '1' when (opcode = JSR) else '0';
    Hab_We          <= '1' when (opcode = JSR) else '0';
    Hab_Re          <= '1' when (opcode = RET) else '0';
    
end architecture;