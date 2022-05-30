LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Memory_Unit IS
    PORT (
        -- In from Global input
        rst, clk : IN STD_LOGIC; -- Reset from global
        Interrupt : IN STD_LOGIC; -- Interrupt from Global
        Control_Signals : IN STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.

        -- In From  EX/MEM
        PC_Concat : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_Branch : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in_Jump_Condition : IN STD_LOGIC; -- Jump Condition.
        ALU_Heap_Value : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- RD2 from input
        Rs2_Rd : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- W

        -- Out to Global
        Sel_Branch : OUT STD_LOGIC; -- Select Branch to Fetcher
        out_ALU_Heap_Value : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_PC_Branch : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- OUT to MEM/WB
        OUTReset : OUT STD_LOGIC; -- we propagate the reset to fetch
        out_Control_Signals : OUT STD_LOGIC_VECTOR(24 DOWNTO 0); -- Control Signals.
        out_Rs2_Rd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- W

        --Out to memory itself
        Address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Write_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_Memory_Unit OF Memory_Unit IS

    --  Components
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

    COMPONENT mux8 IS
        GENERIC (n : INTEGER := 1);
        PORT (
            in0, in1, in2, in3, in4 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT my_nadder IS
        GENERIC (n : INTEGER := 8);
        PORT (
            a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            cin : IN STD_LOGIC;
            s : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            cout : OUT STD_LOGIC);

    END COMPONENT;

    COMPONENT Stack_Pointer IS
        PORT (
            clk : IN STD_LOGIC; -- SP Clock
            rst : IN STD_LOGIC; -- SP Reset
            writeEnable : IN STD_LOGIC; -- Write Enable to allow checnging SP
            -- readEnable : IN STD_LOGIC; -- Read Enable to allow reading SP
            new_SP : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be written if we want to update it's value
            SP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Data to be read if we want to output it's value
        );
    END COMPONENT;
    -- Signals
    SIGNAL writeDataOutValue : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL addressSelector : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rstAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL interruptAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL stachPointerAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL addressOutVal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL newStackPointerVal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --Temp
    SIGNAL SP_Plus1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL carry_Inc_SP, carry_Dec_SP : STD_LOGIC := '0';
    SIGNAL SP_Minus1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL COUNT: STD_LOGIC_VECTOR(2 downTO 1);
    SIGNAL ST_HP: STD_LOGIC;

BEGIN
    
    rstAddress(31 DOWNTO 0) <= X"00000000";
    interruptAddress(31 DOWNTO 0) <= X"00000001";
    -- stachPointerAddress(31 DOWNTO 0) <= X"22222222";
    PROCESS(clk,rst) IS
		Variable C:INTEGER;
			BEGIN
				IF rst='1' THEN
					C:=0;
				ELSIF rising_edge(clk) THEN  
					IF Control_Signals(2) = '1' THEN
						C:=C+1;
                    END IF;
                END IF;
                If (Control_Signals(2) = '1' AND C=2) then
                    out_Control_Signals(10 DOWNTO 7)<="0011";
                    addressSelector <= Interrupt & rst & '0';
                    C:=0;
                    ST_HP<='0';
                ELSE 
                out_Control_Signals(10 DOWNTO 7)<=Control_Signals(10 DOWNTO 7);
                addressSelector <= Interrupt & rst & Control_Signals(10);
                ST_HP<=Control_Signals(10);
                END IF;
		END PROCESS;
    a1 : my_nadder GENERIC MAP(32) PORT MAP(stachPointerAddress, (OTHERS => '0'), '1', SP_Plus1, carry_Inc_SP);
    a2 : my_nadder GENERIC MAP(32) PORT MAP(stachPointerAddress, (OTHERS => '1'), '0', SP_Minus1, carry_Dec_SP);

    newStackPointerVal <= SP_Plus1 WHEN(Control_Signals(8) = '1') --increment SP when Memory read aka pop
        ELSE
        SP_Minus1 WHEN(Control_Signals(9) = '1');--increment SP when Memory write aka push

    -- Set the SP value
    sp1 : Stack_Pointer PORT MAP(
        clk => clk,
        rst => rst,
        writeEnable => ST_HP, -- we will edit the SP CS (SP/Heap) = 1
        new_SP => newStackPointerVal,
        SP => stachPointerAddress
    );

    m1 : mux2 GENERIC MAP(
        n => 32) PORT MAP(
        IN1 => RD2,
        IN2 => PC_Concat,
        SEl => Control_Signals(6),
        OUT1 => writeDataOutValue);

    m2 : mux8 GENERIC MAP(
        n => 32) PORT MAP (
        in0 => ALU_Heap_Value, -- to pass Heap (ALU Result)
        in1 => rstAddress, -- to pass the reset address (0)
        in2 => interruptAddress, -- to pass the interrupt address (1)
        in3 => stachPointerAddress, -- to pass SP as Address
        in4 => X"00000004", -- for debugging purposes
        sel => addressSelector,
        out1 => addressOutVal

    );
    OUTReset<=rst;
    Write_Data <= writeDataOutValue;
    Address <= addressOutVal;
    out_Control_Signals(24 DOWNTO 11) <= Control_Signals(24 DOWNTO 11);
    out_Control_Signals(6 DOWNTO 0) <= Control_Signals(6 DOWNTO 0);
    out_Rs2_Rd <= Rs2_Rd;
    out_ALU_Heap_Value <= ALU_Heap_Value;
    out_PC_Branch <= PC_Branch;
    Sel_Branch <= in_Jump_Condition AND Control_Signals(11); -- pass the Selector for Branch by anding the Branch Signal with the jump condition
END ARCHITECTURE;