--------------------------------------------------------------------------------
-- comparatorN_gte : N-bit unsigned greater-than-or-equal comparator
-- Structural: ripple comparison chain from LSB to MSB.
-- o_gte = '1' when i_a >= i_b (unsigned).
--
-- Used twice in fsmController of the keyboard controller, with N = 4:
--   counter >= 9  : start bit and 8 data bits are in, skip the remaining bits
--   counter >= 11 : all 11 bits of the PS/2 frame received, back to idle
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY comparatorN_gte IS
    GENERIC (N : INTEGER := 4);
    PORT (
        i_a   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        i_b   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        o_gte : OUT STD_LOGIC
    );
END comparatorN_gte;

ARCHITECTURE structural OF comparatorN_gte IS
    SIGNAL int_bitEq : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL int_bitGt : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL int_chain : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
BEGIN
    bits : FOR i IN 0 TO N-1 GENERATE
        -- 1-bit equality and strictly-greater checks
        int_bitEq(i) <= NOT (i_a(i) XOR i_b(i));
        int_bitGt(i) <= i_a(i) AND (NOT i_b(i));

        firstBit : IF i = 0 GENERATE
            -- At LSB, A(0) >= B(0) if A(0) > B(0) OR A(0) = B(0)
            int_chain(0) <= int_bitGt(0) OR int_bitEq(0);
        END GENERATE firstBit;

        otherBits : IF i > 0 GENERATE
            int_chain(i) <= int_bitGt(i) OR (int_bitEq(i) AND int_chain(i-1));
        END GENERATE otherBits;
    END GENERATE bits;

    o_gte <= int_chain(N-1);
END structural;