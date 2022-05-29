LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Fetch IS
    PORT (
        clk : IN STD_LOGIC;
        branch_address, memory_address : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        sel_br, sw_int, swap, hazard, hlt, mem_in_use, pc_mem, rst : IN STD_LOGIC;
        fetch_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        NextPC : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END ENTITY Fetch;
ARCHITECTURE arch_fetch OF Fetch IS
    COMPONENT mux8 IS
        GENERIC (n : INTEGER := 1);
        PORT (
            in0, in1, in2, in3, in4 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            out1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;


    SIGNAL mux8_output : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL next_pc : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Actualnext_pc : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL sel_freeze, sel_mem : STD_LOGIC;
    SIGNAL sel_mux8 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SIG_fetch_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MUXOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    PROCESS (clk)
    BEGIN
        IF (falling_edge(clk)) THEN
            next_pc <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(MUXOUT)) + 1, 32));
        END IF;
        IF (sel_mux8="000") then
            Actualnext_pc<=next_pc;
        END IF;
    END PROCESS;
    fetch_output <= MUXOUT;
    NextPC <= Actualnext_pc;

    sel_freeze <= sw_int OR swap OR hazard OR mem_in_use OR hlt;
    sel_mem <= pc_mem OR rst;
    sel_mux8 <= sel_br & sel_freeze & sel_mem;
    m1 : mux8 GENERIC MAP(
        n => 32) PORT MAP (
        in0 => Actualnext_pc,
        in1 => MUXOUT,
        in2 => branch_address,
        in3 => memory_address,
        in4 => (OTHERS => '0'),
        sel => sel_mux8,
        out1 => MUXOUT);

END arch_fetch;