LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Buffer1_IF_ID IS
    PORT (

        clk, enb, flush, propagatedreset : IN STD_LOGIC;
        pc_input : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        inst_input : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        pc_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        inst_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        OUTpropagatedreset : OUT STD_LOGIC

    );
END ENTITY;

ARCHITECTURE a_Buffer1_IF_ID OF Buffer1_IF_ID IS
BEGIN
    PROCESS (clk)
        VARIABLE Enableflag : STD_LOGIC := '0';
        VARIABLE Flushflag : STD_LOGIC := '0';
    BEGIN
        IF (falling_edge(clk) AND enb = '1' AND Enableflag = '0') THEN
            Enableflag := '1';
        ELSIF (falling_edge(clk) AND Enableflag = '1') THEN
            Enableflag := '0';
        END IF;

        IF (falling_edge(clk) AND flush = '1' AND Flushflag = '0') THEN
            Flushflag := '1';
        ELSIF (falling_edge(clk) AND Flushflag = '1') THEN
            Flushflag := '0';
        END IF;

        IF (falling_edge(clk)) THEN

            IF Flushflag = '1' THEN
                pc_output <= (OTHERS => '0');
                inst_output <= (OTHERS => '0');
            ELSIF (Enableflag = '0') THEN
                pc_output <= pc_input;
                inst_output <= inst_input;
                OUTpropagatedreset <= propagatedreset;

            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;