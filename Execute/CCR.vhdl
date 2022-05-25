LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CCR IS
    PORT (
        flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- The input Flags to the CCR Register.
        clk : IN STD_LOGIC; -- Clock.
        rst : IN STD_LOGIC; -- Rest Signal.
        flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Output Flags From the CCR Register.
    );
END ENTITY;

ARCHITECTURE a_CCR OF CCR IS
    SIGNAL f : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

    PROCESS (rst, clk)
    BEGIN
        -- If Reset Signal then the output is 0.
        IF (rst = '1') THEN
            f <= (OTHERS => '0');

            -- With every rising edge, we pass the input.
        ELSIF (rising_edge(clk)) THEN
            f <= flags_in;
        END IF;

    END PROCESS;
    flags_out <= f;

END ARCHITECTURE;