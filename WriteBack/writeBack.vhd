LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY write_back is
    PORT(
    alu , memory : IN std_logic_vector (31 DOWNTO 0);
    rst , hw_int, mem_alu_to_reg : IN std_logic;
    write_value : OUT std_logic_vector (31 DOWNTO 0)

    );


END ENTITY write_back;


ARCHITECTURE arch_wb of write_back is

COMPONENT mux2 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        IN1, IN2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        SEl : IN STD_LOGIC;
        OUT1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END COMPONENT;

signal sel_value : std_logic;

BEGIN
sel_value <= rst or hw_int or mem_alu_to_reg; 

m1 : mux2 GENERIC MAP(
    n => 32) PORT MAP (
    IN1 =>alu,
    IN2 =>memory,
    sel => sel_value,
    out1 => write_value);


END ARCHITECTURE;

