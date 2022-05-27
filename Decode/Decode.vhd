LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Decode IS
	PORT(
        clk	: IN STD_LOGIC;
        reset	: IN STD_LOGIC;
        MemRead_EXCUTESTAGE	: IN STD_LOGIC;
        RD_EXCUTESTAGE	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	    InputPC : IN std_logic_vector(31 DOWNTO 0);
	    Instruction : IN std_logic_vector(31 DOWNTO 0);
        INPORTDATA: IN std_logic_vector(31 DOWNTO 0);
	    RD1,RD2,ImmValue : OUT  std_logic_vector(31 DOWNTO 0);
	    RS1,RS2,RD : OUT  std_logic_vector(2 DOWNTO 0);
	    ControlSignals  : OUT  std_logic_vector(24 DOWNTO 0);
        HazardSignal : OUT std_logic);
END ENTITY Decode;

ARCHITECTURE Decode OF Decode IS
COMPONENT RegisterFile IS
PORT(
    clk : IN std_logic;
    WriteEnable : IN std_logic;
    WriteAdd,ReadReg1,ReadReg2 : IN  std_logic_vector(2 DOWNTO 0);
    WriteData  : IN  std_logic_vector(31 DOWNTO 0);
    ReadData1,ReadData2 : OUT std_logic_vector(31 DOWNTO 0));
END COMPONENT RegisterFile;

COMPONENT ControlUnit IS
	PORT(
		clk,reset : IN std_logic;
		opCode  : IN std_logic_vector(5 DOWNTO 0);
		SignalVector : OUT  std_logic_vector(24 DOWNTO 0));
END COMPONENT ControlUnit;

COMPONENT my_nDFF IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst,en : IN std_logic;
d : IN std_logic_vector(n-1 DOWNTO 0);
q : OUT std_logic_vector(n-1 DOWNTO 0));
END  COMPONENT my_nDFF;

COMPONENT mux2 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        IN1, IN2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        SEl : IN STD_LOGIC;
        OUT1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END COMPONENT mux2;

COMPONENT HazardDU IS
	PORT(
		clk : IN std_logic;
		MemRead : IN std_logic;
		RS1,RS2,RD : IN  std_logic_vector(2 DOWNTO 0);
		hazard1 : OUT std_logic);
END COMPONENT HazardDU;
SIGNAL OpCode: std_logic_vector(5 DOWNTO 0);
SIGNAL Reg1Add:std_logic_vector(2 DOWNTO 0);
SIGNAL Reg2Add:std_logic_vector(2 DOWNTO 0);
SIGNAL Reg1Data:std_logic_vector(31 DOWNTO 0);
SIGNAL Reg2Data:std_logic_vector(31 DOWNTO 0);
SIGNAL CONTSIG:std_logic_vector(24 DOWNTO 0);

-----------------------------------------------------------------------------------------
--CONTROL UNIT SIGNALS-------------------------
SIGNAL RegWrite:std_logic:='0';
SIGNAL InPort:std_logic:='0';
SIGNAL OutPort:std_logic:='0';
SIGNAL RegImm:std_logic:='0';
SIGNAL RegDst:std_logic_vector(1 DOWNTO 0):="00";
SIGNAL ALUOp:std_logic_vector(3 DOWNTO 0):="0000";
SIGNAL JmpCond:std_logic_vector(1 DOWNTO 0):="00";
SIGNAL Branch:std_logic:='0';
SIGNAL SpHeap:std_logic:='0';
SIGNAL MemWrite:std_logic:='0';
SIGNAL MemRead:std_logic:='0';
SIGNAL MemAluToReg:std_logic:='0';
SIGNAL PcRd2:std_logic:='0';
SIGNAL PcMem:std_logic:='0';
SIGNAL HLT:std_logic:='0';
SIGNAL SWAP:std_logic:='0';
SIGNAL SWInt:std_logic:='0';
SIGNAL RTISIg:std_logic:='0';
SIGNAL Flush:std_logic:='0';
SIGNAL HWINT:std_logic:='0';
--HAZARD SIGNAL----------------------------
SIGNAL hazardSig:std_logic:='0';

	BEGIN

    RF: RegisterFile PORT MAP(clk => clk,WriteEnable => '0',WriteAdd => (OTHERS=>'0'),WriteData => (OTHERS=>'0'),ReadReg1 => Reg1Add,ReadReg2 => Reg2Add,ReadData1 => Reg1Data,ReadData2 => Reg2Data);
    CU: ControlUnit PORT MAP(clk=>clk,reset=>reset,opCode=>Opcode, signalVector=>CONTSIG);
    -- INPORTREG: my_nDFF GENERIC MAP(32) PORT MAP(clk=>clk,Rst=>reset,en=>'0',d=>(OTHERS=>'0'),q=>INPORTDATA);
    INPORTMUX: mux2 GENERIC MAP(32) PORT MAP(SEl=>InPort,IN1=>Reg1Data ,IN2=>INPORTDATA,OUT1=>RD1);
    HDU: HazardDU PORT MAP(clk=>clk,MemRead=>MemRead_EXCUTESTAGE,RS1=>Reg1Add,RS2=>Reg2Add,RD=>RD_EXCUTESTAGE,hazard1=>hazardSig);
    HDUMUX: mux2 GENERIC MAP(25) PORT MAP(SEl=>hazardSig,IN1=>CONTSIG,IN2=>(OTHERS=>'0'),OUT1=>ControlSignals);
    

    InPort<=CONTSIG(22);
    Opcode<=Instruction(31 DOWNTO 26);
    Reg1Add<=Instruction(25 DOWNTO 23);
    Reg2Add<=Instruction(22 DOWNTO 20);
    RD2<=Reg2Data;
    ImmValue<= x"0000" & Instruction(15 DOWNTO 0);
    RS1<=Instruction(25 DOWNTO 23);
    RS2<=Instruction(22 DOWNTO 20);
    RD<=Instruction(19 DOWNTO 17);
    HazardSignal<=hazardSig;
	
END Decode;