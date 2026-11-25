--------------------------------------------------------------------------------
-- digitalFilter : digital filter for the PS/2 keyboard clock (Figure 13)
--
-- Structural:
--   1. An 8-bit shift register samples the raw keyboard clock on every rising
--      edge of the 100 MHz global clock (one sample every 10 ns).
--   2. A combinational circuit looks at the 8 samples:
--          set   = all eight samples are '1'
--          reset = all eight samples are '0'
--   3. An SR flip-flop holds the filtered clock:
--          set = '1'   -> o_filteredClock = '1'
--          reset = '1' -> o_filteredClock = '0'
--          neither     -> o_filteredClock keeps its value
--
-- The output therefore only changes once the keyboard clock has been stable
-- for 8 x 10 ns = 80 ns, which removes glitches and reflections on the cable.
--
-- The SR element is a clocked SR flip-flop built from enARdFF_2 with
-- D = S + R'.Q, so the block stays fully synchronous and has no combinational
-- loop (no ALLOW_COMBINATORIAL_LOOPS waiver needed in the XDC).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY digitalFilter IS
    PORT (
        i_clock         : IN  STD_LOGIC;   -- 100 MHz global clock
        i_resetBar      : IN  STD_LOGIC;
        i_keyboardClock : IN  STD_LOGIC;   -- raw PS/2 clock from the keyboard
        o_filteredClock : OUT STD_LOGIC    -- filtered keyboard clock
    );
END digitalFilter;

ARCHITECTURE structural OF digitalFilter IS
    COMPONENT shiftRegister
        GENERIC (N : INTEGER := 8);
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_shift    : IN  STD_LOGIC;
            i_d        : IN  STD_LOGIC;
            o_q        : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_hc    : STD_LOGIC_VECTOR(7 DOWNTO 0);   -- last 8 samples (HC[7..0])
    SIGNAL int_set   : STD_LOGIC;
    SIGNAL int_reset : STD_LOGIC;
    SIGNAL int_srD   : STD_LOGIC;                      -- SR flip-flop next value
    SIGNAL int_srQ   : STD_LOGIC;                      -- SR flip-flop output
BEGIN
    -- 1. sampling window, shifts on every global clock edge
    sampleReg : shiftRegister
        GENERIC MAP (N => 8)
        PORT MAP (
            i_clock    => i_clock,
            i_resetBar => i_resetBar,
            i_shift    => '1',
            i_d        => i_keyboardClock,
            o_q        => int_hc
        );

    -- 2. combinational circuit: 8-input AND and 8-input NOR
    int_set   <= int_hc(7) AND int_hc(6) AND int_hc(5) AND int_hc(4) AND
                 int_hc(3) AND int_hc(2) AND int_hc(1) AND int_hc(0);

    int_reset <= NOT (int_hc(7) OR int_hc(6) OR int_hc(5) OR int_hc(4) OR
                      int_hc(3) OR int_hc(2) OR int_hc(1) OR int_hc(0));

    -- 3. SR flip-flop: Q+ = S + R'.Q
    int_srD <= int_set OR ((NOT int_reset) AND int_srQ);

    srFF : enARdFF_2
        PORT MAP (
            i_resetBar => i_resetBar,
            i_d        => int_srD,
            i_enable   => '1',
            i_clock    => i_clock,
            o_q        => int_srQ,
            o_qBar     => OPEN
        );

    o_filteredClock <= int_srQ;
END structural;