-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "04/18/2024 16:50:35"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          Projeto1
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Projeto1_vhd_vec_tst IS
END Projeto1_vhd_vec_tst;
ARCHITECTURE Projeto1_arch OF Projeto1_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL BLOCO_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLOCK_50 : STD_LOGIC;
SIGNAL CS : STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL DA_out : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL DIN_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DOUT_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FPGA_RESET_N : STD_LOGIC;
SIGNAL HEX0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX4 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX5 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL Instruction_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL KEY : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL LEDR : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL Opcode_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL PC_OUT : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL RDD : STD_LOGIC;
SIGNAL SW : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL ULA_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ULAOP_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL WRR : STD_LOGIC;
COMPONENT Projeto1
	PORT (
	BLOCO_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	CLOCK_50 : IN STD_LOGIC;
	CS : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	DA_out : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
	DIN_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	DOUT_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	FPGA_RESET_N : IN STD_LOGIC;
	HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	Instruction_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	Opcode_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	PC_OUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
	RDD : OUT STD_LOGIC;
	SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	ULA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	ULAOP_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	WRR : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Projeto1
	PORT MAP (
-- list connections between master ports and signals
	BLOCO_out => BLOCO_out,
	CLOCK_50 => CLOCK_50,
	CS => CS,
	DA_out => DA_out,
	DIN_out => DIN_out,
	DOUT_out => DOUT_out,
	FPGA_RESET_N => FPGA_RESET_N,
	HEX0 => HEX0,
	HEX1 => HEX1,
	HEX2 => HEX2,
	HEX3 => HEX3,
	HEX4 => HEX4,
	HEX5 => HEX5,
	Instruction_OUT => Instruction_OUT,
	KEY => KEY,
	LEDR => LEDR,
	Opcode_OUT => Opcode_OUT,
	PC_OUT => PC_OUT,
	RDD => RDD,
	SW => SW,
	ULA_OUT => ULA_OUT,
	ULAOP_OUT => ULAOP_OUT,
	WRR => WRR
	);

-- CLOCK_50
t_prcs_CLOCK_50: PROCESS
BEGIN
	CLOCK_50 <= '1';
	WAIT FOR 1 ps;
	FOR i IN 1 TO 499999
	LOOP
		CLOCK_50 <= '0';
		WAIT FOR 1 ps;
		CLOCK_50 <= '1';
		WAIT FOR 1 ps;
	END LOOP;
	CLOCK_50 <= '0';
WAIT;
END PROCESS t_prcs_CLOCK_50;

-- FPGA_RESET_N
t_prcs_FPGA_RESET_N: PROCESS
BEGIN
	FPGA_RESET_N <= '1';
WAIT;
END PROCESS t_prcs_FPGA_RESET_N;
-- KEY[3]
t_prcs_KEY_3: PROCESS
BEGIN
	KEY(3) <= 'U';
WAIT;
END PROCESS t_prcs_KEY_3;
-- KEY[2]
t_prcs_KEY_2: PROCESS
BEGIN
	KEY(2) <= 'U';
WAIT;
END PROCESS t_prcs_KEY_2;
-- KEY[1]
t_prcs_KEY_1: PROCESS
BEGIN
	KEY(1) <= 'U';
WAIT;
END PROCESS t_prcs_KEY_1;
-- KEY[0]
t_prcs_KEY_0: PROCESS
BEGIN
	KEY(0) <= 'U';
WAIT;
END PROCESS t_prcs_KEY_0;
-- SW[9]
t_prcs_SW_9: PROCESS
BEGIN
	SW(9) <= 'U';
WAIT;
END PROCESS t_prcs_SW_9;
-- SW[8]
t_prcs_SW_8: PROCESS
BEGIN
	SW(8) <= 'U';
WAIT;
END PROCESS t_prcs_SW_8;
-- SW[7]
t_prcs_SW_7: PROCESS
BEGIN
	SW(7) <= 'U';
WAIT;
END PROCESS t_prcs_SW_7;
-- SW[6]
t_prcs_SW_6: PROCESS
BEGIN
	SW(6) <= 'U';
WAIT;
END PROCESS t_prcs_SW_6;
-- SW[5]
t_prcs_SW_5: PROCESS
BEGIN
	SW(5) <= 'U';
WAIT;
END PROCESS t_prcs_SW_5;
-- SW[4]
t_prcs_SW_4: PROCESS
BEGIN
	SW(4) <= 'U';
WAIT;
END PROCESS t_prcs_SW_4;
-- SW[3]
t_prcs_SW_3: PROCESS
BEGIN
	SW(3) <= 'U';
WAIT;
END PROCESS t_prcs_SW_3;
-- SW[2]
t_prcs_SW_2: PROCESS
BEGIN
	SW(2) <= 'U';
WAIT;
END PROCESS t_prcs_SW_2;
-- SW[1]
t_prcs_SW_1: PROCESS
BEGIN
	SW(1) <= 'U';
WAIT;
END PROCESS t_prcs_SW_1;
-- SW[0]
t_prcs_SW_0: PROCESS
BEGIN
	SW(0) <= 'U';
WAIT;
END PROCESS t_prcs_SW_0;
END Projeto1_arch;
