LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Stack_Pointer IS
    PORT (
        clk : IN STD_LOGIC; -- SP Clock
        rst : IN STD_LOGIC; -- SP Reset
        writeEnable : IN STD_LOGIC; -- Write Enable to allow checnging SP
        -- readEnable : IN STD_LOGIC; -- Read Enable to allow reading SP
        new_SP : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be written if we want to update it's value
        SP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Data to be read if we want to output it's value
    );
END ENTITY;

ARCHITECTURE a_Stack_Pointer OF Stack_Pointer IS

    --  Components
    -- Signals
    SIGNAL SP_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            SP_temp <= X"000FFFFF"; -- Initialize SP to 0x000FFFFE which is the last address in the memory
        ELSIF rising_edge(clk) THEN
            IF writeEnable = '1' THEN
                SP_temp <= new_SP;
            END IF;

        END IF;
    END PROCESS;
    SP <= SP_temp;
END ARCHITECTURE;