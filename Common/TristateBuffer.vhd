LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY TristateBuffer IS
    PORT (
        Q : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        enable : IN STD_LOGIC;
        o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_TristateBuffer OF TristateBuffer IS
BEGIN
    o <= (OTHERS => 'Z') WHEN enable = '0'
        ELSE
        Q WHEN enable = '1';
END ARCHITECTURE;