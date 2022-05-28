LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY RegDstUnit IS
    PORT (
        clk : IN STD_LOGIC; -- Clock used for the Swap operation (Exhange the destination);
        rst : IN STD_LOGIC; -- Reset Signal.
        Rd, RS2, RS1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- RD, RS1,RS2 (Register Source and Destination).
        regDst : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- 2 Bit Control Signal.
        ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4 Bit ALU operation Signal (Used for Swap Operation).
        dst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- The WB destination Register.
    );

END ENTITY;

ARCHITECTURE a_RegDstUnit OF RegDstUnit IS
    SIGNAL Swap : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL swap_Flag : STD_LOGIC := '0'; -- Swap operation takes 2 cycles , this flag determine which cycle we are at.
BEGIN
    PROCESS (clk)
    BEGIN

        -- If it is a clk rising edge and it is swap operation, then we need to swap the operands.
        IF (rising_edge(clk) AND ALUOp = "1001") THEN
            -- If it is the first swapping cycle then pass the operand A.
            IF (swap_Flag = '0') THEN
                Swap <= RS2;
                swap_Flag <= '1';
                -- Else the pass the operand B.
            ELSE
                Swap <= RS1;
                swap_Flag <= '0';
            END IF;
        END IF;

    END PROCESS;

    dst <= Swap WHEN ALUOp = "1001"
        ELSE
        Rd WHEN RegDst = "00"
        ELSE
        RS2 WHEN RegDst = "01"
        ELSE
        RS1 WHEN RegDst = "10";

END ARCHITECTURE;