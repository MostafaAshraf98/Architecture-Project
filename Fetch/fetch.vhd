LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Fetch IS
	PORT(
        clk : IN std_logic;
        branch_address, memory_address : IN std_logic_vector (31 DOWNTO 0);
        sel_br, sw_int, swap, hazard, hlt, mem_in_use, pc_mem, rst : In std_logic;
        fetch_output : INOUT std_logic_vector (31 DOWNTO 0)
		);
END ENTITY Fetch;


ARCHITECTURE arch_fetch of Fetch IS


COMPONENT mux8 IS
    GENERIC (n : INTEGER := 1);
    PORT (
        in0, in1, in2, in3,in4 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END COMPONENT ;

signal mux8_output :std_logic_vector (31 DOWNTO 0):= (others => '0');
signal next_pc : std_logic_vector (31 DOWNTO 0);
signal sel_freeze , sel_mem : std_logic;
signal sel_mux8 : std_logic_vector(2 DOWNTO 0);


BEGIN

process(clk)
    BEGIN
    IF rising_edge(clk) THEN
        next_pc <= std_logic_vector( to_unsigned( to_integer(unsigned(mux8_output)) + 1, 32) );

        
    elsif falling_edge(clk) THEN
        
        mux8_output <= fetch_output;
    end if;
    end process; 


    sel_freeze <= sw_int or swap or hazard or mem_in_use or hlt;
    sel_mem <= pc_mem or rst;
    sel_mux8 <= sel_br & sel_freeze & sel_mem ;
m1 : mux8 GENERIC MAP(
    n => 32) PORT MAP (
    in0 => next_pc,
    in1 => mux8_output,
    in2 => branch_address,
    in3 => memory_address,
    in4 => (others=>'0'),
    sel => sel_mux8,
    out1 => fetch_output);







end arch_fetch;
