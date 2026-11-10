--------------------------------------------------------------------------------
-- mux2to1N : N-bit 2-to-1 multiplexer
-- i_sel = '0' -> o_y = i_a ;  i_sel = '1' -> o_y = i_b
-- Used to select (MS counter, MSC_MAX) vs (SS counter, SSC_MAX) for the
-- shared comparator, and to pick the active digit's segments for the display.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2to1N IS
    GENERIC (N : INTEGER := 4);
    PORT (
        i_a   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        i_b   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        i_sel : IN  STD_LOGIC;
        o_y   : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );
END mux2to1N;

ARCHITECTURE structural OF mux2to1N IS
BEGIN
    bits : FOR i IN 0 TO N-1 GENERATE
        o_y(i) <= (i_a(i) AND (NOT i_sel)) OR (i_b(i) AND i_sel);
    END GENERATE bits;
END structural;
