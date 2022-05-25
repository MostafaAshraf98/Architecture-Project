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
    out1 <= in0 when sel = "000"
	else	in1 when sel = "010"
	else	in2 when sel = "100"
	else 	in3 when sel ="001"
    else    in4 when sel="UUU"
    else (others=>'Z');
END ARCHITECTURE;
