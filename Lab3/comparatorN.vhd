--------------------------------------------------------------------------------
-- comparatorN : N-bit equality comparator
-- Structural: one XNOR per bit (1-bit comparator) feeding an AND chain.
-- o_eq = '1' when i_a = i_b.  Signals "counter expired" to the FSM.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY comparatorN IS
    GENERIC (N : INTEGER := 4);
    PORT (
        i_a  : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        i_b  : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        o_eq : OUT STD_LOGIC
    );
END comparatorN;

ARCHITECTURE structural OF comparatorN IS
    SIGNAL int_bitEq, int_chain : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
BEGIN
    bits : FOR i IN 0 TO N-1 GENERATE
        -- 1-bit comparator
        int_bitEq(i) <= NOT (i_a(i) XOR i_b(i));

        firstBit : IF i = 0 GENERATE
            int_chain(0) <= int_bitEq(0);
        END GENERATE firstBit;

        otherBits : IF i > 0 GENERATE
            int_chain(i) <= int_chain(i-1) AND int_bitEq(i);
        END GENERATE otherBits;
    END GENERATE bits;

    o_eq <= int_chain(N-1);
END structural;
