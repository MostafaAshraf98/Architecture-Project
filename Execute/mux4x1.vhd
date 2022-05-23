LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux4 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        in0, in1, in2, in3 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END;

ARCHITECTURE arch1 OF mux4 IS
BEGIN
    out1 <= in0
        WHEN sel(0) = '0' AND sel(1) = '0'
        ELSE
        in1 WHEN sel(0) = '1' AND sel(1) = '0'
        ELSE
        in2 WHEN sel(0) = '0' AND sel(1) = '1'
        ELSE
        in3;
END ARCHITECTURE;