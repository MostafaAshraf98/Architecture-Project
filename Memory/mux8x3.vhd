LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux8 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        in0, in1, in2, in3, in4 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END mux8;

ARCHITECTURE arch1 OF mux8 IS
BEGIN
    out1 <= in0 WHEN sel = "000"
        ELSE
        in1 WHEN sel = "010"
        ELSE
        in2 WHEN sel = "100"
        ELSE
        in3 WHEN sel = "001"
        ELSE
        in4 WHEN sel = "UUU"
        ELSE
        (OTHERS => 'Z');
END ARCHITECTURE;