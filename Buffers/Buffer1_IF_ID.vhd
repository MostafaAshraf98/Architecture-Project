LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Buffer1_IF_ID IS
    PORT (

        clk, enb, flush : IN STD_LOGIC;
        pc_input : IN STD_LOGIC_VECTOR (19 DOWNTO 0);
        inst_input : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        pc_output : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
        inst_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE a_Buffer1_IF_ID OF Buffer1_IF_ID IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF (falling_edge(clk) AND enb = '0') THEN
            pc_output <= pc_input;
            inst_output <= inst_input;
        ELSIF flush = '1' THEN
            pc_output <= (OTHERS => '0');
            inst_output <= (OTHERS => '0');

        END IF;
    END PROCESS;

END ARCHITECTURE;