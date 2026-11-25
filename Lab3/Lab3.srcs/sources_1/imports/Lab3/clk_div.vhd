--------------------------------------------------------------------------------
-- clk_div : clock divider / tick generator  (BEHAVIOURAL - allowed by Sec. 6)
-- Produces a one-clock-wide enable pulse (o_tick) every G_COUNT cycles of the
-- 100 MHz clock.  The rest of the design stays on the 100 MHz clock and uses
-- o_tick as a clock enable, so there is only one clock domain (Section 5.5).
--   G_COUNT = 100_000_000 -> 1 Hz tick   (FSM counters / timers, 1 count = 1 s)
--   G_COUNT =   1_000_000 -> 100 Hz tick (debouncer sampling)
-- Note: if your group uses the course-provided divider (which toggles a slow
-- clock), feed its output through a rising-edge detector to get this tick.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY clk_div IS
    GENERIC (G_COUNT : POSITIVE := 100_000_000);
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        o_tick     : OUT STD_LOGIC
    );
END clk_div;

ARCHITECTURE behavioural OF clk_div IS
    SIGNAL int_count : INTEGER RANGE 0 TO G_COUNT-1;
    SIGNAL int_tick  : STD_LOGIC;
BEGIN
    PROCESS (i_clock, i_resetBar)
    BEGIN
        IF (i_resetBar = '0') THEN
            int_count <= 0;
            int_tick  <= '0';
        ELSIF rising_edge(i_clock) THEN
            IF (int_count = G_COUNT-1) THEN
                int_count <= 0;
                int_tick  <= '1';
            ELSE
                int_count <= int_count + 1;
                int_tick  <= '0';
            END IF;
        END IF;
    END PROCESS;

    o_tick <= int_tick;
END behavioural;
