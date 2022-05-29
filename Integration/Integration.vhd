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
    SIGNAL FetchSig_NextPC : STD_LOGIC_VECTOR (31 DOWNTO 0);

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
    SIGNAL MemSig_OUTReset : STD_LOGIC;

    -- OUT SIGNALS FROM WB
    SIGNAL WBSig_write_value : STD_LOGIC_VECTOR (31 DOWNTO 0);

    --OUT FROM BUFFER 1
    SIGNAL Buff1Sig_pc_output : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Buff1Sig_inst_output : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Buff1Sig_OUTpropagatedreset : STD_LOGIC;

    -- OUT FROM BUFFER 2
    SIGNAL Buff2Sig_OUTControlSignals : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL Buff2Sig_OUTPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Buff2Sig_OUTRD1, BUff2Sig_OUTRD2, BUff2Sig_OUTImmValue : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Buff2Sig_OUTRS1, BUff2Sig_OUTRS2, BUff2Sig_OUTRD : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Buff2Sig_OUTPreset : STD_LOGIC;

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
    SIGNAL Buff4Sig_OUT_reset : STD_LOGIC;

    --IN TO MEMORY (RAM)
    SIGNAL MemSig_readAddress : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be read
    --OUT FROM MEMORY (RAM)
    SIGNAL MemSig_readData : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be read
    -- OUT SIGNALS FROM REGISTER FILE
    SIGNAL DecodeSig_RFData1, DecodeSig_RFData2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --OTHER SIGNALS
    SIGNAL SelOR_mem_in_use : STD_LOGIC;
    SIGNAL SigOR1_Mem : STD_LOGIC; -- OR in the memory stage
    SIGNAL sigOR2_Mem : STD_LOGIC; -- Or in the corner
    SIGNAL SigOr_Mux_Fetch : STD_LOGIC_VECTOR(0 DOWNTO 0); -- result of the mux in the corner result
    SIGNAL Sig_ReadEnable : STD_LOGIC;
    SIGNAL FLUSH : STD_LOGIC;
    SIGNAL B1enable : STD_LOGIC;
    SIGNAL B2enable : STD_LOGIC;
BEGIN
    --------------------PORT MAPPING FETCH--------------------------
    F : ENTITY work.Fetch PORT MAP (
        clk => clk,
        branch_address => Buff3Sig_OUT_PC_Branching,
        memory_address => WBSig_write_value,
        sel_br => MemSig_Sel_Branch,
        sw_int => Buff2Sig_OUTControlSignals(2),
        swap => Buff3Sig_OUT_ControlSignals(3),
        hazard => DecodeSig_HazardSignal,
        hlt => Buff2Sig_OUTControlSignals(4),
        mem_in_use => SelOR_mem_in_use,
        pc_mem => Buff4Sig_OUT_Control_SIGNAL(5),
        rst => Buff4Sig_OUT_reset,
        fetch_output => FetchSig_out,
        NextPC => FetchSig_NextPC
        );

    --------------PORT MAPPING BUFFER1 IF/ID--------------------------
    -- needs signals from excute buffer and decode buffer
    BUFF1_IF_ID : ENTITY work.Buffer1_IF_ID PORT MAP (
        clk => clk,
        propagatedreset => Buff4Sig_OUT_reset,
        enb => B1enable,
        flush => FLUSH,
        pc_input => FetchSig_NextPC,
        inst_input => MemSig_readData,
        pc_output => Buff1Sig_pc_output,
        inst_output => Buff1Sig_inst_output,
        OUTpropagatedreset => Buff1Sig_OUTpropagatedreset
        );

    -------------------PORT MAPPING DECODE----------------------
    D : ENTITY work.Decode PORT MAP (
        clk => clk,
        reset => rst,
        MemRead_EXCUTESTAGE => Buff2Sig_OUTControlSignals(8),
        RD_EXCUTESTAGE => ExecSig_outDestination,
        InputPC => Buff1Sig_pc_output,
        Instruction => Buff1Sig_inst_output,
        INPORTDATA => inPort,
        RFData1 => DecodeSig_RFData1,
        RFData2 => DecodeSig_RFData2,
        RD1 => DecodeSig_RD1,
        RD2 => DecodeSig_RD2,
        ImmValue => DecodeSig_ImmValue,
        RS1 => DecodeSig_RS1,
        RS2 => DecodeSig_RS2,
        RD => DecodeSig_RD,
        ControlSignals => DecodeSig_ControlSignals,
        HazardSignal => DecodeSig_HazardSignal);

    ----------REGISTER FILE PORT MAPING
    RF : ENTITY work.RegisterFile PORT MAP(
        clk => clk,
        WriteEnable => Buff4Sig_OUT_Control_SIGNAL(23),
        WriteAdd => Buff4Sig_OUT_Rs2_RD_DATA,
        WriteData => WBSig_write_value,
        ReadReg1 => Buff1Sig_inst_output(25 DOWNTO 23),
        ReadReg2 => Buff1Sig_inst_output(22 DOWNTO 20),
        ReadData1 => DecodeSig_RFData1,
        ReadData2 => DecodeSig_RFData2);
    --------------PORT MAPPING BUFFER2 ID/EX--------------------------

    BUFF2_ID_EX : ENTITY work.buf PORT MAP (
        rst => rst,
        clk => clk,
        Hazard => DecodeSig_HazardSignal,
        en => B2enable,
        flush => FLUSH,
        INPC => FetchSig_NextPC,
        Preset => Buff1Sig_OUTpropagatedreset,
        INControlSignals => DecodeSig_ControlSignals,
        INRD1 => DecodeSig_RD1,
        INRD2 => DecodeSig_RD2,
        INImmValue => DecodeSig_ImmValue,
        INRS1 => DecodeSig_RS1,
        INRS2 => DecodeSig_RS2,
        INRD => DecodeSig_RD,
        OUTControlSignals => Buff2Sig_OUTControlSignals,
        OUTPC => Buff2Sig_OUTPC,
        OUTRD1 => Buff2Sig_OUTRD1,
        OUTRD2 => BUff2Sig_OUTRD2,
        OUTImmValue => BUff2Sig_OUTImmValue,
        OUTRS1 => Buff2Sig_OUTRS1,
        OUTRS2 => BUff2Sig_OUTRS2,
        OUTRD => BUff2Sig_OUTRD,
        OUTPreset => Buff2Sig_OUTPreset
        );

    -------------------PORT MAPPING EXEC----------------------
    EXEC : ENTITY work.Execute_Unit PORT MAP(
        --In From Buffer
        clk => clk,
        rst => rst,
        PC => Buff2Sig_OUTPC,
        RD1 => Buff2Sig_OUTRD1,
        RD2 => BUff2Sig_OUTRD2,
        Imm => BUff2Sig_OUTImmValue,
        RS1 => Buff2Sig_OUTRS1,
        RS2 => BUff2Sig_OUTRS2,
        RD => BUff2Sig_OUTRD,
        ControlSignals => Buff2Sig_OUTControlSignals,
        INPreset => Buff1Sig_OUTpropagatedreset,

        -- IN From Other Stages (GLOBAL)
        dst_Mem => MemSig_out_Rs2_Rd,
        dst_WB => Buff4Sig_OUT_Rs2_RD_DATA,
        WB_MemStage => Buff3Sig_OUT_ControlSignals(23),
        WB_WBStage => Buff4Sig_OUT_Control_SIGNAL(23),
        ALU_DataMem => MemSig_out_ALU_Heap_Value,
        MEM_DataWB => WBSig_write_value,
        prevFlags => WBSig_write_value(22 DOWNTO 20),
        RTISignal => Buff4Sig_OUT_Control_SIGNAL(1),

        --OUT TO Buffer
        PC_Concatenated => ExecSig_PC_Concatenated,
        PC_Branching => ExecSig_PC_Branching,
        outControlSignals => ExecSig_outControlSignals,
        outJumpCondition => ExecSig_outJumpCondition,
        ALUResult => ExecSig_ALUResult,
        outRD2 => ExecSig_outRD2,
        outDestination => ExecSig_outDestination,

        --OUT TO Other Stages (GLOBAL)
        outRD => ExecSig_outRD,
        outMemReadSig => ExecSig_outMemReadSig,
        outSwapSig => ExecSig_outSwapSig,
        outPort => ExecSig_outPort
        );

    --------------PORT MAPPING BUFFER3 EX/MEM--------------------------
    BUFF3_EX_MEM : ENTITY work.Buffer3_EX_MEM PORT MAP(
        clk => clk,
        rst => rst,
        disable => Buff3Sig_OUT_ControlSignals(2),
        flush => Buff4Sig_OUT_Control_SIGNAL(0),
        --INPUTS TO Buffer From EXECUTE STAGE
        IN_PC_Concatenated => ExecSig_PC_Concatenated,
        IN_PC_Branching => ExecSig_PC_Branching,
        IN_ControlSignals => ExecSig_outControlSignals,
        IN_JumpCondition => ExecSig_outJumpCondition,
        IN_ALUResult => ExecSig_ALUResult,
        IN_RD2 => ExecSig_outRD2,
        IN_Destination => ExecSig_outDestination,
        --OUTPUTS From Buffer To Memory Stage
        OUT_PC_Concatenated => Buff3Sig_OUT_PC_Concatenated,
        OUT_PC_Branching => Buff3Sig_OUT_PC_Branching,
        OUT_ControlSignals => Buff3Sig_OUT_ControlSignals,
        OUT_JumpCondition => Buff3Sig_OUT_JumpCondition,
        OUT_ALUResult => Buff3Sig_OUT_ALUResult,
        OUT_RD2 => Buff3Sig_OUT_RD2,
        OUT_Destination => Buff3Sig_OUT_Destination
        );
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
        OUTReset => MemSig_OUTReset,
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
        IN_MEM_RESET => MemSig_OUTReset,
        ----OUT To Write Back----
        OUT_MEM_RESET => Buff4Sig_OUT_reset,
        OUT_Rs2_RD_DATA => Buff4Sig_OUT_Rs2_RD_DATA,
        OUT_Control_SIGNAL => Buff4Sig_OUT_Control_SIGNAL,
        OUT_ALU_Value => Buff4Sig_OUT_ALU_Value,
        OUT_Memory_Data => Buff4Sig_OUT_Memory_Data
        );
    -------------------PORT MAPPING WB UNIT-------------------
    WB : ENTITY work.write_back PORT MAP(
        alu => Buff4Sig_OUT_ALU_Value,
        memory => Buff4Sig_OUT_Memory_Data,
        rst => Buff4Sig_OUT_reset,
        hw_int => Buff4Sig_OUT_Control_SIGNAL(24),
        mem_alu_to_reg => Buff4Sig_OUT_Control_SIGNAL(7),
        write_value => WBSig_write_value
        );
    -------------------PORT MAPPING MULTIPLEXERS AND MEMORY-------------------

    -- Multiplexer Before the Memory (RAM)
    m1 : ENTITY work.mux2 GENERIC MAP(32) PORT MAP (
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
    ------------------------------------------OTHER GATES AND CONNECTIONS----------------------------------------------------
    SelOR_mem_in_use <= SigOR1_Mem OR Buff3Sig_OUT_ControlSignals(9);

    SigOR1_Mem <= Buff3Sig_OUT_ControlSignals(8) OR Buff3Sig_OUT_ControlSignals(24) OR rst;
    SigOR2_Mem <= Buff3Sig_OUT_ControlSignals(8) OR Buff3Sig_OUT_ControlSignals(9);
    Sig_ReadEnable <= SigOR1_Mem OR SigOr_Mux_Fetch(0);
    FLUSH <= Buff4Sig_OUT_Control_SIGNAL(0) OR MemSig_Sel_Branch;
    B1enable <= (rst AND Buff2Sig_OUTControlSignals(4)) OR ExecSig_outSwapSig OR DecodeSig_HazardSignal OR Buff3Sig_OUT_ControlSignals(2);
    B2enable <= (ExecSig_outSwapSig OR Buff3Sig_OUT_ControlSignals(2));

    outPort <= ExecSig_outPort;

END ARCHITECTURE;