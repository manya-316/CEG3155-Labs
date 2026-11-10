--------------------------------------------------------------------------------
-- sevenSegDecoder : BCD digit to seven-segment pattern  (bonus)
-- Output is ACTIVE LOW for the Nexys A7 (0 = segment on).
-- o_seg(6 downto 0) = g f e d c b a  ->  SEG(0)=CA ... SEG(6)=CG
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sevenSegDecoder IS
    PORT (
        i_bcd : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END sevenSegDecoder;

ARCHITECTURE dataflow OF sevenSegDecoder IS
BEGIN
    WITH i_bcd SELECT
        o_seg <= "1000000" WHEN "0000",
                 "1111001" WHEN "0001",
                 "0100100" WHEN "0010",
                 "0110000" WHEN "0011",
                 "0011001" WHEN "0100",
                 "0010010" WHEN "0101",
                 "0000010" WHEN "0110",
                 "1111000" WHEN "0111",
                 "0000000" WHEN "1000",
                 "0010000" WHEN "1001",
                 "1111111" WHEN OTHERS;
END dataflow;
