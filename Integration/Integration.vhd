LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Integration IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        inPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        HWInt : IN STD_LOGIC;
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE a_Integration OF Integration IS

    -- OUT SIGNALS FROM FETCH
    SIGNAL FetchSig_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL FetchSig_NextPC: std_logic_vector (31 DOWNTO 0);

    -- OUT SIGNALS FROM DECODE 
    SIGNAL DecodeSig_RD1, DecodeSig_RD2, DecodeSig_ImmValue : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DecodeSig_RS1, DecodeSig_RS2, DecodeSig_RD : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DecodeSig_ControlSignals : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL DecodeSig_HazardSignal : STD_LOGIC;

    -- OUT SIGNALS FROM EXECUTE
    SIGNAL ExecSig_PC_Concatenated : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Concatenated PC.
    SIGNAL ExecSig_PC_Branching : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added to immediate PC.
    SIGNAL ExecSig_outControlSignals : STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
    SIGNAL ExecSig_outJumpCondition : STD_LOGIC; -- Jump Condition.
    SIGNAL ExecSig_ALUResult : STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output.
    SIGNAL ExecSig_outRD2 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 2.
    SIGNAL ExecSig_outDestination : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register.
    SIGNAL ExecSig_outRD : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register Destination.
    SIGNAL ExecSig_outMemReadSig : STD_LOGIC; -- Memory Read Signal.
    SIGNAL ExecSig_outSwapSig : STD_LOGIC; -- Swap Signal.
    SIGNAL ExecSig_outPort : STD_LOGIC_VECTOR(31 DOWNTO 0);-- Data to be written to the port.

    -- OUT SIGNALS FROM MEMORY
    SIGNAL MemSig_Sel_Branch : STD_LOGIC; -- Select Branch to Fetcher
    SIGNAL MemSig_out_ALU_Heap_Value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemSig_out_PC_Branch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemSig_out_Control_Signals : STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
    SIGNAL MemSig_out_Rs2_Rd : STD_LOGIC_VECTOR(2 DOWNTO 0); -- W
    SIGNAL MemSig_Address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemSig_Write_Data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- OUT SIGNALS FROM WB
    SIGNAL WBSig_write_value : STD_LOGIC_VECTOR (31 DOWNTO 0);

    --OUT FROM BUFFER 1
    SIGNAL Buff1Sig_pc_output : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Buff1Sig_inst_output : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- OUT FROM BUFFER 2
    SIGNAL Buff2Sig_OUTControlSignals : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL Buff2Sig_OUTPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Buff2Sig_OUTRD1, BUff2Sig_OUTRD2, BUff2Sig_OUTImmValue : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Buff2Sig_OUTRS1, BUff2Sig_OUTRS2, BUff2Sig_OUTRD : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- OUT FROM BUFFER 3
    SIGNAL Buff3Sig_OUT_PC_Concatenated : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Concatenated PC.
    SIGNAL Buff3Sig_OUT_PC_Branching : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added to immediate PC.
    SIGNAL Buff3Sig_OUT_ControlSignals : STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
    SIGNAL Buff3Sig_OUT_JumpCondition : STD_LOGIC; -- Jump Condition.
    SIGNAL Buff3Sig_OUT_ALUResult : STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output.
    SIGNAL Buff3Sig_OUT_RD2 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 2.
    SIGNAL Buff3Sig_OUT_Destination : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register.

    -- OUT FROM BUFFER 4
    SIGNAL Buff4Sig_OUT_Rs2_RD_DATA : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Buff4Sig_OUT_Control_SIGNAL : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL Buff4Sig_OUT_ALU_Value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Buff4Sig_OUT_Memory_Data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --IN TO MEMORY (RAM)
    SIGNAL MemSig_readAddress : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be read
    --OUT FROM MEMORY (RAM)
    SIGNAL MemSig_readData : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be read

    --OTHER SIGNALS
    SIGNAL SelOR_mem_in_use : STD_LOGIC;
    SIGNAL SigOR1_Mem : STD_LOGIC; -- OR in the memory stage
    SIGNAL sigOR2_Mem : STD_LOGIC; -- Or in the corner
    SIGNAL SigOr_Mux_Fetch : STD_LOGIC_VECTOR(0 DOWNTO 0); -- result of the mux in the corner result
    SIGNAL Sig_ReadEnable : STD_LOGIC;

BEGIN
    --------------------PORT MAPPING FETCH--------------------------
    f : ENTITY work.Fetch PORT MAP (
        clk => clk,
        branch_address => Buff3Sig_OUT_PC_Branching,
        memory_address => WBSig_write_value,
        sel_br => MemSig_Sel_Branch,
        sw_int => Buff2Sig_OUTControlSignals(2),
        swap => Buff2Sig_OUTControlSignals(3),
        hazard => DecodeSig_HazardSignal,
        hlt => Buff2Sig_OUTControlSignals(4),
        mem_in_use => SelOR_mem_in_use,
        pc_mem => Buff4Sig_OUT_Control_SIGNAL(5),
        rst => rst,
        fetch_output => FetchSig_out
        );

    --------------PORT MAPPING BUFFER1 IF/ID--------------------------
    -- needs signals from excute buffer and decode buffer
    -- FB: Entity work.Buffer1_IF_ID PORTMAP (

    --     clk=>clk,
    --     enb=>,
    --     flush =>;
    --     pc_input => ,
    --     inst_input =>,
    --     pc_output =>,
    --     inst_output=> 
    -- );

    -------------------PORT MAPPING DECODE----------------------
    D: Entity work.Decode PORT MAP (
        clk => clk,
        reset => rst,
        MemRead_EXCUTESTAGE =>Buff2Sig_OUTControlSignals(8),
        RD_EXCUTESTAGE =>BUff2Sig_OUTRD,
        InputPC =>Buff1Sig_pc_output,
        Instruction =>Buff1Sig_inst_output,
        INPORTDATA =>inPort,
        RD1 =>DecodeSig_RD1, 
        RD2 =>DecodeSig_RD2, 
        ImmValue =>DecodeSig_ImmValue,
        RS1 =>DecodeSig_RS1,
        RS2 =>DecodeSig_RS2, 
        RD  =>DecodeSig_RD,
        ControlSignals  =>DecodeSig_ControlSignals,
        HazardSignal  =>DecodeSig_HazardSignal);
        

    --------------PORT MAPPING BUFFER2 ID/EX--------------------------
    

    -------------------PORT MAPPING EXEC----------------------

    --------------PORT MAPPING BUFFER3 EX/MEM--------------------------

    -------------------PORT MAPPING MEMORY UNIT-------------------
    memUnit : ENTITY work.Memory_Unit PORT MAP(
        -- In from Global input
        rst => rst,
        clk => clk,
        Interrupt => Buff3Sig_OUT_ControlSignals(24),
        Control_Signals => Buff3Sig_OUT_ControlSignals,

        -- In From  EX/MEM
        PC_Concat => Buff3Sig_OUT_PC_Concatenated,
        PC_Branch => Buff3Sig_OUT_PC_Branching,
        in_Jump_Condition => Buff3Sig_OUT_JumpCondition,
        ALU_Heap_Value => Buff3Sig_OUT_ALUResult,
        RD2 => Buff3Sig_OUT_RD2,
        Rs2_Rd => Buff3Sig_OUT_Destination,

        -- Out to Global
        Sel_Branch => MemSig_Sel_Branch,
        out_ALU_Heap_Value => MemSig_out_ALU_Heap_Value,
        out_PC_Branch => MemSig_out_PC_Branch,

        -- OUT to MEM/WB
        out_Control_Signals => MemSig_out_Control_Signals,
        out_Rs2_Rd => MemSig_out_Rs2_Rd,

        --Out to memory itself
        Address => MemSig_Address,
        Write_Data => MemSig_Write_Data
        );

    --------------PORT MAPPING BUFFER4 MEM/WB--------------------------
    BUFF4_MEM_WB : ENTITY work.Buffer4_MEM_WB PORT MAP(
        clk => clk,
        enable => '1',

        ----IN From Memory----
        IN_Rs2_RD_DATA => MemSig_out_Rs2_Rd,
        IN_Control_SIGNAL => MemSig_out_Control_Signals,
        IN_ALU_Value => MemSig_out_ALU_Heap_Value,
        IN_Memory_Data => MemSig_readData,

        ----OUT To Write Back----
        OUT_Rs2_RD_DATA => Buff4Sig_OUT_Rs2_RD_DATA,
        OUT_Control_SIGNAL => Buff4Sig_OUT_Control_SIGNAL,
        OUT_ALU_Value => Buff4Sig_OUT_ALU_Value,
        OUT_Memory_Data => Buff4Sig_OUT_Memory_Data
        );
    -------------------PORT MAPPING WB UNIT-------------------
    --------------------- Multiplexer Before the Memory (RAM)------------------------------
    m1 : ENTITY work.mux2 GENERIC MAP(1) PORT MAP (
        IN1 => FetchSig_out,
        IN2 => MemSig_Address,
        SEl => SelOR_mem_in_use,
        OUT1 => MemSig_readAddress);

    -- Multiplexer In the corner
    m2 : ENTITY work.mux2 GENERIC MAP(1) PORT MAP (
        IN1 => "1",
        IN2 => "0",
        SEl => SigOR2_Mem,
        OUT1 => SigOr_Mux_Fetch);

    -- The memory Itself (RAM)
    mem : ENTITY work.Memory PORT MAP (
        clk => clk,
        writeEnable => Buff3Sig_OUT_ControlSignals(9),
        readEnable => Sig_ReadEnable,
        address => MemSig_readAddress,
        writeData => MemSig_Write_Data,
        readData => MemSig_readData
        );

    SelOR_mem_in_use <= Buff3Sig_OUT_ControlSignals(8) OR Buff3Sig_OUT_ControlSignals(9);

    SigOR1_Mem <= Buff3Sig_OUT_ControlSignals(8) OR Buff3Sig_OUT_ControlSignals(24) OR rst;
    SigOR2_Mem <= Buff3Sig_OUT_ControlSignals(8) OR Buff3Sig_OUT_ControlSignals(9);
    Sig_ReadEnable <= SigOR1_Mem OR SigOR2_Mem;

END ARCHITECTURE;