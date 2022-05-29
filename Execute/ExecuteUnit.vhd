LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Execute_Unit IS
    PORT (
        ---------------------In From Buffer------------------------------------------------
        clk : IN STD_LOGIC; -- Clock used for the swapping.
        rst, INPreset : IN STD_LOGIC; -- Reset Signal and propagated reset to reset CCR.
        PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Program Counter.
        RD1, RD2, Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 1, Read Data 2, Immediate.
        RS1, RS2, RD : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register Source 1, Register Source 2, Register Destination.
        ControlSignals : IN STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.

        ----------------------- IN From Other Stages (GLOBAL)----------------------------------------
        dst_Mem, dst_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register of the instruction in the memory stage and write back stage (used for forwarding).
        WB_MemStage, WB_WBStage : IN STD_LOGIC; -- These are the control signals that indicates whether or not we write back to the register file in the previous instructions that are currently in the memory stage and write back stage.
        ALU_DataMem, MEM_DataWB : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output and Memory Output from the two previous instructions (used for forwarding).
        prevFlags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Flags from the previous instruction (used when returning from interrupt).
        RTISignal : IN STD_LOGIC; -- RTI Signal.

        -------------------------OUT TO Buffer-----------------------------------
        PC_Concatenated : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Concatenated PC.
        PC_Branching : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added to immediate PC.
        outControlSignals : OUT STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
        outJumpCondition : OUT STD_LOGIC; -- Jump Condition.
        ALUResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output.
        outRD2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 2.
        outDestination : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register.

        -------------------------OUT TO Other Stages (GLOBAL)-----------------------------------
        outRD : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register Destination.
        outMemReadSig : OUT STD_LOGIC; -- Memory Read Signal.
        outSwapSig : OUT STD_LOGIC; -- Swap Signal.
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Data to be written to the port.
    );
END ENTITY;
ARCHITECTURE a_Execute_Unit OF Execute_Unit IS
    COMPONENT ALU IS
        PORT (
            clk : IN STD_LOGIC; -- Clock used for the Swap operation.
            rst : IN STD_LOGIC; -- Reset Signal.
            inA, inB : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU inputs (The operands).
            ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Serves as a selector for the ALU operation.
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- The output of the ALU.
            flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- The output flags.
        );
    END COMPONENT;

    COMPONENT ForwardingUnit IS
        PORT (
            RS1, RS2, dst_Mem, dst_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- These are the operand registers and the registers in the Memory and write back stage of the previous Instructions.
            WB_MemStage, WB_WBStage : IN STD_LOGIC; -- These are the control signals that indicates whether or not we write back to the register file in the previous instructions that are currently in the memory stage and write back stage.
            Fwd1, Fwd2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- These are the control signals that indicates whether or not we forward the operands of the next stages (previous instructions in the pipe).
        );
    END COMPONENT;

    COMPONENT mux2 IS
        GENERIC (n : INTEGER := 1);
        PORT (
            IN1, IN2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            SEl : IN STD_LOGIC;
            OUT1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    COMPONENT mux4 IS
        GENERIC (n : INTEGER := 1);
        PORT (
            in0, in1, in2, in3 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT RegDstUnit IS
        PORT (
            clk : IN STD_LOGIC; -- Clock used for the Swap operation (Exhange the destination);
            rst : IN STD_LOGIC; -- Reset Signal.
            Rd, RS2, RS1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- RD, RS1,RS2 (Register Source and Destination).
            regDst : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- 2 Bit Control Signal.
            ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4 Bit ALU operation Signal (Used for Swap Operation).
            dst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- The WB destination Register.
        );
    END COMPONENT;

    COMPONENT TristateBuffer IS
        PORT (
            Q : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            enable : IN STD_LOGIC;
            o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT CCR IS
        PORT (
            flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- The input Flags to the CCR Register.
            clk : IN STD_LOGIC; -- Clock.
            rst,Preset : IN STD_LOGIC; -- Rest Signal.
            flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Output Flags From the CCR Register.
        );
    END COMPONENT;

    -- Signals For The outputs of the internal Components.
    SIGNAL mux4_op1_out, mux4_op2_out, mux2_op2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Fwd1, Fwd2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ALU_Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_Flags : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL CCR_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mux4_destination_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mux2_flags_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mux4_jumpCond_out : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL tristate_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_con : STD_LOGIC_VECTOR (31 DOWNTO 0) := X"00000000";
BEGIN

    m1 : mux4 GENERIC MAP(
        n => 32) PORT MAP (
        in0 => RD1,
        in1 => ALU_DataMem,
        in2 => MEM_DataWB,
        in3 => (OTHERS => '0'),
        sel => Fwd1,
        out1 => mux4_op1_out);

    m2 : mux4 GENERIC MAP(
        n => 32) PORT MAP (
        in0 => RD2,
        in1 => ALU_DataMem,
        in2 => MEM_DataWB,
        in3 => (OTHERS => '0'),
        sel => Fwd2,
        out1 => mux4_op2_out);

    m3 : mux2 GENERIC MAP(
        n => 32) PORT MAP (
        IN1 => mux4_op2_out,
        IN2 => Imm,
        sel => ControlSignals(20),
        out1 => mux2_op2_out);

    a : ALU PORT MAP(
        clk => clk,
        rst => rst,
        inA => mux4_op1_out,
        inB => mux2_op2_out,
        ALUOp => ControlSignals(17 DOWNTO 14),
        result => ALU_Result,
        flags_Out => ALU_Flags
    );
    f : ForwardingUnit PORT MAP(
        RS1 => RS1,
        RS2 => RS2,
        dst_Mem => dst_Mem,
        dst_WB => dst_WB,
        WB_MemStage => WB_MemStage,
        WB_WBStage => WB_WBStage,
        Fwd1 => Fwd1,
        Fwd2 => Fwd2
    );

    r : RegDstUnit GENERIC MAP(
        n => 3) PORT MAP (
        clk => clk,
        rst => rst,
        Rd => RD,
        RS2 => RS2,
        RS1 => RS1,
        regDst => ControlSignals(19 DOWNTO 18),
        ALUOP => ControlSignals(17 DOWNTO 14),
        dst => mux4_destination_out
    );

    m4 : mux2 GENERIC MAP(
        n => 3) PORT MAP (
        IN1 => ALU_Flags,
        IN2 => prevFlags,
        sel => RTISignal,
        out1 => mux2_flags_out);

    c : CCR PORT MAP(
        Preset=>INPreset,
        flags_in => mux2_flags_out,
        clk => clk,
        rst => rst,
        flags_out => CCR_out
    );

    m5 : mux4 GENERIC MAP(
        n => 1) PORT MAP (
        in0 => CCR_out(0 DOWNTO 0),
        in1 => CCR_out(1 DOWNTO 1),
        in2 => CCR_out(2 DOWNTO 2),
        in3 => "1",
        sel => ControlSignals(13 DOWNTO 12),
        out1 => mux4_jumpCond_out);

    tri : TristateBuffer PORT MAP(
        Q => mux4_op1_out,
        enable => ControlSignals(21),
        o => tristate_out
    );

    pc_con(19 DOWNTO 0) <= PC (19 DOWNTO 0);
    pc_con(22 DOWNTO 20) <= CCR_out;
    PC_Concatenated <= pc_con;

    PC_Branching <= STD_LOGIC_VECTOR(signed(PC) + signed(Imm(29 DOWNTO 0) & "00"));

    outControlSignals <= ControlSignals;
    outJumpCondition <= mux4_jumpCond_out(0);
    ALUResult <= ALU_Result;
    outRD2 <= RD2;
    outDestination <= mux4_destination_out;
    outRD <= RD;
    outMemReadSig <= ControlSignals(8);
    outSwapSig <= ControlSignals(3);
    outPort <= tristate_out;

END ARCHITECTURE;