LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Buffer3_EX_MEM IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        disable : IN STD_LOGIC;
        flush : IN STD_LOGIC;
        -------------INPUTS TO Buffer From EXECUTE STAGE---------------
        IN_PC_Concatenated : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Concatenated PC.
        IN_PC_Branching : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added to immediate PC.
        IN_ControlSignals : IN STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
        IN_JumpCondition : IN STD_LOGIC; -- Jump Condition.
        IN_ALUResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output.
        IN_RD2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 2.
        IN_Destination : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination Register.
        ------------OUTPUTS From Buffer To Memory Stage
        OUT_PC_Concatenated : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Concatenated PC.
        OUT_PC_Branching : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added to immediate PC.
        OUT_ControlSignals : OUT STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
        OUT_JumpCondition : OUT STD_LOGIC; -- Jump Condition.
        OUT_ALUResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU Output.
        OUT_RD2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Data 2.
        OUT_Destination : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Destination Register.
    );
END ENTITY;

ARCHITECTURE a_Buffer3_IF_ID OF Buffer3_EX_MEM IS
BEGIN

    PROCESS (rst, clk)
        VARIABLE Enableflag : STD_LOGIC := '0';
        VARIABLE Flushflag : STD_LOGIC := '0';
    BEGIN
        IF (falling_edge(clk) AND disable = '1' AND Enableflag = '0') THEN
            Enableflag := '1';
        ELSIF (falling_edge(clk) AND Enableflag = '1') THEN
            Enableflag := '0';
        END IF;

        IF (falling_edge(clk) AND flush = '1' AND Flushflag = '0') THEN
            Flushflag := '1';
        ELSIF (falling_edge(clk) AND Flushflag = '1') THEN
            Flushflag := '0';
        END IF;
        IF (falling_edge(clk) OR rising_edge(clk)) AND(rst = '1' OR Flushflag = '1' OR Enableflag = '1') THEN
            ------------OUTPUTS From Buffer To Memory Stage
            OUT_PC_Concatenated <= (OTHERS => '0');
            OUT_PC_Branching <= (OTHERS => '0');
            OUT_ControlSignals <= (OTHERS => '0');
            OUT_JumpCondition <= '0';
            OUT_ALUResult <= (OTHERS => '0');
            OUT_RD2 <= (OTHERS => '0');
            OUT_Destination <= (OTHERS => '0');
        ELSIF ((falling_edge(clk)) AND Enableflag = '0') THEN
            OUT_PC_Concatenated <= IN_PC_Concatenated;
            OUT_PC_Branching <= IN_PC_Branching;
            OUT_ControlSignals <= IN_ControlSignals;
            OUT_JumpCondition <= IN_JumpCondition;
            OUT_ALUResult <= IN_ALUResult;
            OUT_RD2 <= IN_RD2;
            OUT_Destination <= IN_Destination;
        END IF;
    END PROCESS;

END ARCHITECTURE;