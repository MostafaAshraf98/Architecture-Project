LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
    PORT (
        clk : IN STD_LOGIC; -- Clock used for the Swap operation.
        rst : IN STD_LOGIC; -- Reset Signal.
        inA, inB : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU inputs (The operands).
        ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Serves as a selector for the ALU operation.
        result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- The output of the ALU.
        flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- The output flags.
    );
END ENTITY;

ARCHITECTURE a_ALU OF ALU IS
    -- Using the n-bit adder component for all the adding operations.
    COMPONENT my_nadder IS
        GENERIC (n : INTEGER := 8);
        PORT (
            a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            cin : IN STD_LOGIC;
            s : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            cout : OUT STD_LOGIC);

    END COMPONENT;

    -- Signals for the result of all the ALU operations (We have a total of 11 ALU operation).
    SIGNAL PassA, INC, SetCarry, NOT_Operation, Subtraction, Addition, AddImmediate, AND_Operation, ADD2, Swap, PassB : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Signals for the carry flag Result of the arithmetic operations only (We have total of 5 arithmetic operations). 
    SIGNAL carry_Inc, carry_Subtraction, carry_Addition, carry_AddImmediate, carry_ADD2 : STD_LOGIC := '0';
    -- Signal holding the resulting output flag of this ALU operation. -- Initially the output flags from the operation is "000".``
    SIGNAL flags_Sig : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    -- Swap operation takes 2 cycles , this flag determine which cycle we are at.
    SIGNAL swap_Flag : STD_LOGIC := '0';
    -- Signal holding the final result of this ALU operation.
    SIGNAL result_Sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Signal holding (NOT B) , Used for the subtraction operation.
    SIGNAL b_inverted : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    PROCESS (rst, clk)
    BEGIN

        -- If it is a clk rising edge and it is swap operation, then we need to swap the operands.
        IF (rising_edge(clk) AND ALUOp = "1001") THEN
            -- If it is the first swapping cycle then pass the operand A.
            IF (swap_Flag = '0') THEN
                Swap <= inA;
                swap_Flag <= '1';
                -- Else the pass the operand B.
            ELSE
                Swap <= inB;
                swap_Flag <= '0';
            END IF;
        END IF;

    END PROCESS;
    b_inverted <= NOT inB;
    a1 : my_nadder GENERIC MAP(32) PORT MAP(inB, (OTHERS => '0'), '1', INC, carry_Inc); -- Adding 1 by using the carry.
    a2 : my_nadder GENERIC MAP(32) PORT MAP(inA, b_inverted, '1', Subtraction, carry_Subtraction); -- Subtracting by using the A - B = A + (NOT B) + 1 where the 1 is added using the carry.
    a3 : my_nadder GENERIC MAP(32) PORT MAP(inA, inB, '0', Addition, carry_Addition); -- Adding by using the A + B.
    a4 : my_nadder GENERIC MAP(32) PORT MAP(inA, inB, '0', AddImmediate, carry_AddImmediate); -- Adding by using the A + Imm.
    a5 : my_nadder GENERIC MAP(32) PORT MAP(inB, X"00000002", '0', ADD2, carry_ADD2); -- Adding 2 to the input

    PassA <= inA; -- Pass the operand A As the output result of the ALU.
    PassB <= inB; -- Pass the operand B As the output result of the ALU.
    SetCarry <= (OTHERS => '0'); -- The result of the ALU does not matter but the carry flag is set to 1.
    NOT_Operation <= NOT(inB); -- Perform NOT operation on the operand A.
    And_operation <= inA AND inB; -- Perform AND operation on the operand A and B.

    WITH ALUOp SELECT
        result_Sig <= PassA WHEN "0000", -- PassA operation.
        SetCarry WHEN "0001", -- Set Carry operation.
        INC WHEN "0010", -- Increment operation.
        NOT_Operation WHEN "0011", -- Not operation.
        Subtraction WHEN "0100", -- Subtraction Operation.
        Addition WHEN "0101", -- Addition operation.
        AddImmediate WHEN "0110", -- Add immediate operation.
        And_operation WHEN "0111", -- And operation.
        ADD2 WHEN "1000", -- Increment 2 Operation.
        Swap WHEN "1001", -- Swap operation.
        PassB WHEN "1010", -- PassB operation.
        (OTHERS => 'X') WHEN OTHERS; -- For instructions that does not use ALU.

    -- Zero Flag
    -- Zero Flag do not change if the operation is: Pass InA, Pass InB, SetCarry, Swap.
    flags_Sig(0) <= flags_Sig(0) WHEN (ALUOp = "0000" OR ALUOp = "1010" OR ALUOp = "1001" OR ALUOp = "0001")
ELSE
    '1' WHEN (signed(result_Sig) = 0)
ELSE
    '0';

    -- Negative Flag
    -- Negative Flag do not change if the operation is: Pass InA, Pass InB, SetCarry, Swap.
    flags_Sig(1) <= flags_Sig(1) WHEN (ALUOp = "0000" OR ALUOp = "1010" OR ALUOp = "1001" OR ALUOp = "0001")
ELSE
    '1' WHEN (signed(result_Sig) < 0)
ELSE
    '0';

    -- Carry flag
    -- Carry flag does not change if the operation is PassA, PassB, swap and =0 when   Not, And.
    flags_Sig(2) <= flags_Sig(2) WHEN (ALUOp = "0000" OR ALUOp = "1010" OR ALUOp = "1001")
ELSE
    '1' WHEN ALUOp = "0001" -- Set Carry operation.
ELSE
    carry_Inc WHEN ALUOp = "0010" -- Increment operation.
ELSE
    carry_Subtraction WHEN ALUOp = "0100" -- Subtraction operation.
ELSE
    carry_Addition WHEN ALUOp = "0101" -- Addition 2 Reg. operation.
ELSE
    carry_AddImmediate WHEN ALUOp = "0110" -- Addition with immediate operation.
ELSE
    carry_ADD2 WHEN ALUOp = "1000" -- Increment 2 operation.
ELSE
    '0';

    result <= result_Sig;
    flags_Out <= flags_Sig;
END ARCHITECTURE;