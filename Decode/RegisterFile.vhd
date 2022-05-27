LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY RegisterFile IS
	PORT(
		clk : IN std_logic;
		WriteEnable : IN std_logic;
		WriteAdd,ReadReg1,ReadReg2 : IN  std_logic_vector(2 DOWNTO 0);
		WriteData  : IN  std_logic_vector(31 DOWNTO 0);
		ReadData1,ReadData2 : OUT std_logic_vector(31 DOWNTO 0));
END ENTITY RegisterFile;

ARCHITECTURE syncRF OF RegisterFile IS

	TYPE RF_type IS ARRAY(0 TO 7) OF std_logic_vector(31 DOWNTO 0);
	SIGNAL RegFile : RF_type ;
	
	BEGIN
		PROCESS(clk) IS
			BEGIN
				IF falling_edge(clk) THEN  
					IF WriteEnable = '1' THEN
						RegFile(to_integer(unsigned(WriteAdd))) <= WriteData;
					END IF;
				END IF;
		END PROCESS;
		
		ReadData1 <= RegFile(to_integer(unsigned(ReadReg1)));
		ReadData2 <= RegFile(to_integer(unsigned(ReadReg2)));
END syncRF;
