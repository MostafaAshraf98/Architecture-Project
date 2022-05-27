LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        IN1, IN2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        SEl : IN STD_LOGIC;
        OUT1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END ENTITY mux2;

ARCHITECTURE
    arch1 OF mux2 IS
BEGIN
    OUT1 <= IN1 WHEN SEl = '0' ELSE
        IN2;
END arch1;