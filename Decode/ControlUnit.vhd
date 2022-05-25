LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ControlUnit IS
	PORT(
		clk,reset,INT : IN std_logic;
		opCode  : IN std_logic_vector(5 DOWNTO 0);
		SignalVector : OUT  std_logic_vector(23 DOWNTO 0));
END ENTITY ControlUnit;

ARCHITECTURE ControlUnit OF ControlUnit IS
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
BEGIN
PROCESS(opcode) IS
BEGIN

	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='0';
	RegDst<="00";
	ALUOp<="0000";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='0';
	MemWrite<='0';
	MemRead<='0';
	MemAluToReg<='0';
	PcRd2<='0';
	PcMem<='0';
	HLT<='0';
	SWAP<='0';
	SWInt<='0';
	RTISIg<='0';
	Flush<='0';
IF opCode="000000" THEN
	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='0';
	RegDst<="00";
	ALUOp<="0001";
ELSIF opCode="000001" then
	RegWrite<='1';
	InPort<='0';
	OutPort<='0';
	RegImm<='0';
	RegDst<="01";
	ALUOp<="0011";
ELSIF opCode="000010" then
	RegWrite<='1';
	InPort<='0';
	OutPort<='0';
	RegImm<='0';
	RegDst<="01";
	ALUOp<="0010";
ELSIF opCode="000011" then
	OutPort<='1';
ELSIF opCode="000100" then
	RegWrite<='1';
	InPort<='1';
ELSIF opCode="000101" then
	RegWrite<='1';
ELSIF opCode="000110" then
	RegWrite<='1';
	RegDst<="01";
	ALUOp<="1001";
	SWAP<='1';
ELSIF opCode="000111" then
	RegWrite<='1';
	ALUOp<="0101";
ELSIF opCode="001000" then
	RegWrite<='1';
	ALUOp<="0100";
ELSIF opCode="001001" then
	RegWrite<='1';
	ALUOp<="0111";

ELSIF opCode="010000" then
	RegWrite<='1';
	RegImm<='1';
	RegDst<="01";
	ALUOp<="0110";

ELSIF opCode="010001" then
	SpHeap<='1';
	MemWrite<='1';
	MemAluToReg<='1';
ELSIF opCode="010010" then
	RegWrite<='1';
	RegDst<="01";
	Branch<='0';
	SpHeap<='1';
	MemWrite<='0';
	MemRead<='1';
	MemAluToReg<='1';

ELSIF opCode="010011" then
	RegWrite<='1';
	RegImm<='1';
	RegDst<="01";
	ALUOp<="1010";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='0';
	MemWrite<='0';
	MemRead<='1';
	MemAluToReg<='1';
ELSIF opCode="010100" then
	RegWrite<='1';
	RegImm<='1';
	RegDst<="01";
	ALUOp<="0110";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='0';
	MemWrite<='0';
	MemRead<='1';
	MemAluToReg<='1';
ELSIF opCode="010101" then
	RegImm<='1';
	RegDst<="00";
	ALUOp<="0110";
	JmpCond<="00";
	MemWrite<='1';

ELSIF opCode="100000" then
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1010";
	JmpCond<="00";
	Branch<='1';
ELSIF opCode="100001" then
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1010";
	JmpCond<="01";
	Branch<='1';
ELSIF opCode="100010" then
	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1010";
	JmpCond<="10";
	Branch<='1';
ELSIF opCode="100011" then
	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1010";
	JmpCond<="11";
	Branch<='1';
ELSIF opCode="100100" then
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1010";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='1';
	MemWrite<='1';
	MemRead<='0';
	MemAluToReg<='0';
	PcRd2<='1';
	PcMem<='1';
	Flush<='1';
ELSIF opCode="100101" then
	SpHeap<='1';
	MemWrite<='0';
	MemRead<='1';
	MemAluToReg<='0';
	PcRd2<='0';
	PcMem<='1';
	Flush<='1';
ELSIF opCode="100110" then
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1000";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='1';
	MemWrite<='1';
	PcRd2<='1';
	PcMem<='1';
	SWInt<='1';
	RTISIg<='0';
	Flush<='1';
ELSIF opCode="100111" then
	-- to be implemented
	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='1';
	RegDst<="00";
	ALUOp<="1000";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='1';
	MemWrite<='0';
	MemRead<='1';
	MemAluToReg<='0';
	PcRd2<='1';
	PcMem<='1';
	HLT<='0';
	SWAP<='0';
	SWInt<='1';
	RTISIg<='0';
	Flush<='1';
ELSIF opCode="110000" then
	RegWrite<='0';
	InPort<='0';
	OutPort<='0';
	RegImm<='0';
	RegDst<="00";
	ALUOp<="0000";
	JmpCond<="00";
	Branch<='0';
	SpHeap<='0';
	MemWrite<='0';
	MemRead<='0';
	MemAluToReg<='0';
	PcRd2<='0';
	PcMem<='0';
	HLT<='0';
	SWAP<='0';
	SWInt<='0';
	RTISIg<='0';
	Flush<='0';
ELSIF opCode="110001" then
	HLT<='1';
END IF;
end process;
SIGNALVECTOR<= RegWrite & InPort & OutPort & RegImm & RegDst & ALUOp & JmpCond & Branch & SpHeap & MemWrite & MemRead & MemAluToReg & PcRd2 & PcMem & HLT & SWAP & SWInt & RTISIg & Flush;
		
END ControlUnit;