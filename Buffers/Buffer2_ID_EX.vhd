LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY buf IS

    PORT (
        rst, clk, en, flush, Preset : IN STD_LOGIC;
        INPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        INControlSignals : IN STD_LOGIC_VECTOR(24 DOWNTO 0);
        INRD1, INRD2, INImmValue : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        INRS1, INRS2, INRD : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        OUTPreset: OUT STD_LOGIC;
        OUTControlSignals : OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
        OUTPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        OUTRD1, OUTRD2, OUTImmValue : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        OUTRS1, OUTRS2, OUTRD : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));

END ENTITY;

ARCHITECTURE buf_arch OF buf IS
BEGIN

    PROCESS (clk)
    VARIABLE Enableflag: STD_LOGIC :='0';
    BEGIN

        IF (falling_edge(clk) AND en='1' AND Enableflag='0') THEN 
            Enableflag:='1';
        ELSIF(falling_edge(clk) AND Enableflag='1') THEN
            Enableflag:='0';
        END IF;
        IF (falling_edge(clk)) THEN
            IF (flush = '1' OR rst = '1') THEN
                OUTControlSignals <= (OTHERS => '0');
                OUTPC <= (OTHERS => '0');
                OUTRD1 <= (OTHERS => '0');
                OUTRD2 <= (OTHERS => '0');
                OUTImmValue <= (OTHERS => '0');
                OUTRS1 <= (OTHERS => '0');
                OUTRS2 <= (OTHERS => '0');
                OUTRD <= (OTHERS => '0');
                
            ELSIF (Enableflag = '0') THEN
                OUTControlSignals <= INControlSignals;
                OUTPC <= INPC;
                OUTRD1 <= INRD1;
                OUTRD2 <= INRD2;
                OUTImmValue <= INImmValue;
                OUTRS1 <= INRS1;
                OUTRS2 <= INRS2;
                OUTRD <= INRD;
                OUTPreset<=Preset;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;