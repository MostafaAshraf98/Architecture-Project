LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CCR IS
    PORT (
        flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_CCR OF CCR IS
BEGIN

    PROCESS (rst, clk)
    BEGIN
        IF (rst = '1') THEN
            flags_out <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            flags_out <= flags_in;
        END IF;

    END PROCESS;

END ARCHITECTURE;