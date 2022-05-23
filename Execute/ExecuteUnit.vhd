LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Execute_Unit IS
    PORT (
        clk : IN STD_LOGIC; -- Clock used for the swapping.
        PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Program Counter.
        RD1, RD2, Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 1, Read Data 2, Immediate.
        RS1, RS2, RD : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register Source 1, Register Source 2, Register Destination.
        ControlSignals : IN STD_LOGIC_VECTOR(23 DOWNTO 0); -- Control Signals.
        dst_Mem, dst_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register of the instruction in the memory stage and write back stage (used for forwarding).
        WB_MemStage, WB_WBStage : IN STD_LOGIC; -- These are the control signals that indicates whether or not we write back to the register file in the previous instructions that are currently in the memory stage and write back stage.
        ALU_DataMem, MEM_DataWB : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output and Memory Output from the two previous instructions (used for forwarding).
        prevFlags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Flags from the previous instruction (used when returning from interrupt).
        RTISignal : IN STD_LOGIC; -- RTI Signal.
    );
END ENTITY;
ARCHITECTURE a_Execute_Unit OF Execute_Unit IS
BEGIN

END ARCHITECTURE;