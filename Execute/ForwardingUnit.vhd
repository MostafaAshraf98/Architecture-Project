LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ForwardingUnit IS
    PORT (
        RS1, RS2, dst_Mem, dst_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- These are the operand registers and the registers in the Memory and write back stage of the previous Instructions.
        WB_MemStage, WB_WBStage : IN STD_LOGIC; -- These are the control signals that indicates whether or not we write back to the register file in the previous instructions that are currently in the memory stage and write back stage.
        Fwd1, Fwd2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- These are the control signals that indicates whether or not we forward the operands of the next stages (previous instructions in the pipe).
    );
END ENTITY;

ARCHITECTURE a_ForwardingUnit OF ForwardingUnit IS
BEGIN

    Fwd1 <= "01" WHEN (RS1 = dst_Mem AND WB_MemStage = '1')
        ELSE
        "10" WHEN (RS1 = dst_WB AND WB_WBStage = '1')
        ELSE
        "00";

    Fwd2 <= "01" WHEN (RS2 = dst_Mem AND WB_MemStage = '1')
        ELSE
        "10" WHEN (RS2 = dst_WB AND WB_WBStage = '1')
        ELSE
        "00";

END ARCHITECTURE;