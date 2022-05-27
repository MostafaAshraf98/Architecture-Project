Library ieee;
use ieee.std_logic_1164.all;
ENTITY my_nDFF IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst,en : IN std_logic;
d : IN std_logic_vector(n-1 DOWNTO 0);
q : OUT std_logic_vector(n-1 DOWNTO 0));
END my_nDFF;
ARCHITECTURE a_my_nDFF OF my_nDFF
IS
BEGIN
q<=x"505684AF";
END a_my_nDFF;