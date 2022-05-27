LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Buffer1_IF_ID IS
    PORT (

        clk : IN std_logic;
        pc_input : IN std_logic_vector (19 DOWNTO 0);
        inst_input : IN std_logic_vector (31 DOWNTO 0);
        pc_output : OUT std_logic_vector (19 DOWNTO 0);
        inst_output : OUT std_logic_vector (31 DOWNTO 0);
 
    );
END ENTITY;

ARCHITECTURE a_Buffer1_IF_ID OF Buffer1_IF_ID IS

BEGIN
    process(clk)
    IF falling_edge(clk) THEN
        pc_output <= pc_input;
        inst_output <= inst_input;

    END IF;


    end process;



END ARCHITECTURE;