--------------------------------------------------------------------------------
-- counterN : N-bit synchronous up counter with enable and synchronous clear
-- Structural: N enARdFF_2 flip-flops plus a ripple-carry incrementer.
--   bit i toggles when all lower bits are 1 (carry(i) = q(i-1)...q(0))
--   i_clear has priority and loads all zeros on the next clock edge.
-- Used for: MS green counter, SS green counter, MS yellow timer (MT),
--           SS yellow timer (ST) and the 17-bit display refresh counter.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY counterN IS
    GENERIC (N : INTEGER := 4);
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_enable   : IN  STD_LOGIC;   -- count up by one on this clock edge
        i_clear    : IN  STD_LOGIC;   -- synchronous clear (priority)
        o_count    : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );
END counterN;

ARCHITECTURE structural OF counterN IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_q, int_d, int_carry : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL int_ffEnable : STD_LOGIC;
BEGIN
    -- Flip-flops load when counting or clearing
    int_ffEnable <= i_enable OR i_clear;

    -- Incrementer carry chain
    int_carry(0) <= '1';

    bits : FOR i IN 0 TO N-1 GENERATE
        -- next value = (q + 1) unless clearing
        int_d(i) <= (int_q(i) XOR int_carry(i)) AND (NOT i_clear);

        carryChain : IF i < N-1 GENERATE
            int_carry(i+1) <= int_carry(i) AND int_q(i);
        END GENERATE carryChain;

        bitFF : enARdFF_2
            PORT MAP (i_resetBar => i_resetBar,
                      i_d        => int_d(i),
                      i_enable   => int_ffEnable,
                      i_clock    => i_clock,
                      o_q        => int_q(i),
                      o_qBar     => OPEN);
    END GENERATE bits;

    o_count <= int_q;
END structural;
