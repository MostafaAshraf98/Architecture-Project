LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Buffer4_MEM_WB IS
    PORT (
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;

        ----IN From Memory----
        IN_Rs2_RD_DATA : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IN_Control_SIGNAL : IN STD_LOGIC_VECTOR(24 DOWNTO 0);
        IN_ALU_Value : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        IN_Memory_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        ----OUT To Write Back----
        OUT_Rs2_RD_DATA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        OUT_Control_SIGNAL : OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
        OUT_ALU_Value : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        OUT_Memory_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE a_Buffer4_MEM_WB OF Buffer4_MEM_WB IS

BEGIN
    PROCESS (clk)
    BEGIN

        IF (falling_edge(clk) AND enable = '1') THEN
            OUT_Rs2_RD_DATA <= IN_Rs2_RD_DATA;
            OUT_Control_SIGNAL <= IN_Control_SIGNAL;
            OUT_ALU_Value <= IN_ALU_Value;
            OUT_Memory_Data <= IN_Memory_Data;
        END IF;
    END PROCESS;
END ARCHITECTURE;