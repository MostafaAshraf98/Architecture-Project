LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Memory IS
    PORT (
        clk : IN STD_LOGIC; -- Memory Clock
        writeEnable : IN STD_LOGIC; -- Write Enable to allow writing
        readEnable : IN STD_LOGIC; -- Read Enable to allow reading
        address : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Address to where we want to access
        writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be written
        readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Data to be read
    );
END ENTITY Memory;

ARCHITECTURE a_Memory OF Memory IS
    TYPE memory_type IS ARRAY (0 TO 1048575) OF STD_LOGIC_VECTOR(31 DOWNTO 0); -- Array of size 2^20 to store data and act as Memory
    SIGNAL memory_data : memory_type;

BEGIN
    PROCESS (clk) IS
    BEGIN
        IF rising_edge(clk) THEN
            IF writeEnable = '1' THEN
                memory_data(to_integer(unsigned(address))) <= writeData;
            END IF;
        END IF;
    END PROCESS;

    readData <= memory_data(to_integer(unsigned(address))) WHEN readEnable = '1' ELSE
        (OTHERS => 'Z');

END a_Memory;