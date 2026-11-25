--------------------------------------------------------------------------------
-- binToBCD : 4-bit binary (0 to 15) to two BCD digits  (bonus)
--   tens = 1 when value >= 10  ->  tens = b3.(b2 + b1)
--   ones = value         when tens = 0
--        = value + 6 mod 16 (same as value - 10) when tens = 1
-- The "+6" is built from a small ripple adder adding 0 t t 0.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY binToBCD IS
    PORT (
        i_bin  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_tens : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   -- BCD1 (left digit)
        o_ones : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)    -- BCD2 (right digit)
    );
END binToBCD;

ARCHITECTURE structural OF binToBCD IS
    SIGNAL t, c1, c2 : STD_LOGIC;
BEGIN
    t <= i_bin(3) AND (i_bin(2) OR i_bin(1));

    o_ones(0) <= i_bin(0);
    o_ones(1) <= i_bin(1) XOR t;
    c1        <= i_bin(1) AND t;
    o_ones(2) <= i_bin(2) XOR t XOR c1;
    c2        <= (i_bin(2) AND t) OR (i_bin(2) AND c1) OR (t AND c1);
    o_ones(3) <= i_bin(3) XOR c2;

    o_tens <= "000" & t;
END structural;
