Library ieee;
use ieee.std_logic_1164.all;

entity buf is 

port(
rst, clk,en,flush : in std_logic;
INPC : IN std_logic_vector(31 DOWNTO 0);
INControlSignals : IN std_logic_vector(24 DOWNTO 0);
INRD1,INRD2,INImmValue : IN  std_logic_vector(31 DOWNTO 0);
INRS1,INRS2,INRD : IN  std_logic_vector(2 DOWNTO 0);
OUTControlSignals  : OUT  std_logic_vector(24 DOWNTO 0);
OUTPC : OUT std_logic_vector(31 DOWNTO 0);
OUTRD1,OUTRD2,OUTImmValue : OUT  std_logic_vector(31 DOWNTO 0);
OUTRS1,OUTRS2,OUTRD : OUT  std_logic_vector(2 DOWNTO 0));

end entity;

Architecture buf_arch of buf is
begin
Process( clk)
begin
    if(falling_edge(clk)) THEN
    if(flush= '1') THEN
    OUTControlSignals <= (others=>'0');
    OUTPC <= (others=>'0');
    OUTRD1 <= (others=>'0');
    OUTRD2 <= (others=>'0');
    OUTImmValue <= (others=>'0');
    OUTRS1 <= (others=>'0');
    OUTRS2 <= (others=>'0');
    OUTRD <= (others=>'0');
    else if(en= '0') THEN
    OUTControlSignals <= INControlSignals;
    OUTPC <= INPC;
    OUTRD1 <= INRD1;
    OUTRD2 <= INRD2;
    OUTImmValue <= INImmValue;
    OUTRS1 <= INRS1;
    OUTRS2 <= INRS2;
    OUTRD <= INRD;
    end if;
    END IF;
end if;
end process;
end Architecture;