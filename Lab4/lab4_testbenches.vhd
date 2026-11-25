--------------------------------------------------------------------------------
-- lab4_testbenches.vhd : unit test benches for the keyboard controller (Lab 4)
--   enARdFF_2_tb, comparatorN_gte_tb, dec_7seg_tb, shiftRegister_tb,
--   counter4bit_tb, fallEdgeDetector_tb, digitalFilter_tb, fsmController_tb,
--   sevenSegDisplay_tb

--------------------------------------------------------------------------------
-- enARdFF_2_tb : test bench for the D flip-flop with enable and async reset
--
-- Checks, in order:
--   1. reset low forces q = '0' and qBar = '1', whatever d and enable are
--   2. with enable = '1' the flip-flop takes d on the rising clock edge
--   3. with enable = '0' it keeps its value even if d changes
--   4. the reset is asynchronous: it clears q without waiting for a clock edge
--
-- Inputs change on falling clock edges and outputs are checked on the next
-- falling edge, so exactly one rising edge lies between the two.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY enARdFF_2_tb IS
END enARdFF_2_tb;

ARCHITECTURE testbench OF enARdFF_2_tb IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_d        : STD_LOGIC := '0';
    SIGNAL tb_enable   : STD_LOGIC := '0';
    SIGNAL tb_q        : STD_LOGIC;
    SIGNAL tb_qBar     : STD_LOGIC;
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : enARdFF_2
        PORT MAP (
            i_resetBar => tb_resetBar,
            i_d        => tb_d,
            i_enable   => tb_enable,
            i_clock    => tb_clock,
            o_q        => tb_q,
            o_qBar     => tb_qBar
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        PROCEDURE check (
            CONSTANT condition : IN BOOLEAN;
            CONSTANT message   : IN STRING
        ) IS
        BEGIN
            IF condition THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- waits for the next falling clock edge (one rising edge goes by)
        PROCEDURE tick IS
        BEGIN
            WAIT UNTIL falling_edge(tb_clock);
        END PROCEDURE tick;
    BEGIN
        -- 1. reset wins over d and enable
        tb_resetBar <= '0';
        tb_d        <= '1';
        tb_enable   <= '1';
        tick;
        check(tb_q = '0' AND tb_qBar = '1', "reset holds q = 0 even with d = 1 and enable = 1");

        -- 2. enable = 1: q follows d on the rising edge
        tb_resetBar <= '1';
        tick;
        check(tb_q = '1' AND tb_qBar = '0', "enable = 1: q takes d = 1");

        -- 3. enable = 0: q holds
        tb_enable <= '0';
        tb_d      <= '0';
        tick;
        tick;
        check(tb_q = '1' AND tb_qBar = '0', "enable = 0: q keeps 1 while d = 0");

        tb_enable <= '1';
        tick;
        check(tb_q = '0' AND tb_qBar = '1', "enable = 1: q takes d = 0");

        -- 4. asynchronous reset, applied between two clock edges
        tb_d <= '1';
        tick;
        check(tb_q = '1', "q is 1 again before the reset test");
        WAIT FOR 2 ns;
        tb_resetBar <= '0';
        WAIT FOR 1 ns;
        check(tb_q = '0' AND tb_qBar = '1', "asynchronous reset clears q between clock edges");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- comparatorN_gte_tb : test bench for the N-bit >= comparator (N = 4)
--
-- The comparator is combinational, so there is no clock. A new pair (a, b) is
-- applied every 10 ns and o_gte must be '1' exactly when a >= b.
--   Part 1: b = 9,  a = 0..15   (the "counter >= 9" test used by the FSM)
--   Part 2: b = 11, a = 0..15   (the "counter >= 11" test used by the FSM)
--   Part 3: all 256 combinations of a and b
-- Only failures are listed one by one, each part ends with a PASS/FAIL line.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY comparatorN_gte_tb IS
END comparatorN_gte_tb;

ARCHITECTURE testbench OF comparatorN_gte_tb IS
    COMPONENT comparatorN_gte
        GENERIC (N : INTEGER := 4);
        PORT (
            i_a   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            i_b   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            o_gte : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL tb_a   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL tb_b   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL tb_gte : STD_LOGIC;
BEGIN
    uut : comparatorN_gte
        GENERIC MAP (N => 4)
        PORT MAP (
            i_a   => tb_a,
            i_b   => tb_b,
            o_gte => tb_gte
        );

    stimulus : PROCESS
        VARIABLE errors : INTEGER := 0;

        -- applies a = 0..15 against one value of b and counts wrong answers
        PROCEDURE sweep (CONSTANT b : IN INTEGER) IS
            VARIABLE expected : STD_LOGIC;
        BEGIN
            tb_b <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
            FOR a IN 0 TO 15 LOOP
                tb_a <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
                WAIT FOR 10 ns;
                IF a >= b THEN
                    expected := '1';
                ELSE
                    expected := '0';
                END IF;
                IF tb_gte /= expected THEN
                    errors := errors + 1;
                    REPORT "FAIL: a = " & INTEGER'IMAGE(a) & ", b = " & INTEGER'IMAGE(b)
                        SEVERITY ERROR;
                END IF;
            END LOOP;
        END PROCEDURE sweep;

        PROCEDURE summary (CONSTANT message : IN STRING) IS
        BEGIN
            IF errors = 0 THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
            errors := 0;
        END PROCEDURE summary;
    BEGIN
        -- Part 1: counter >= 9
        sweep(9);
        summary("a >= 9 is correct for a = 0..15");

        -- Part 2: counter >= 11
        sweep(11);
        summary("a >= 11 is correct for a = 0..15");

        -- Part 3: every combination
        FOR b IN 0 TO 15 LOOP
            sweep(b);
        END LOOP;
        summary("a >= b is correct for all 256 combinations");

        REPORT "End of test bench" SEVERITY NOTE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- dec_7seg_tb : test bench for the hexadecimal to 7-segment decoder
--
-- The decoder is combinational, so there is no clock. Each of the 16 hex
-- digits is applied for 10 ns and the seven outputs are compared with the
-- segments that should be lit for that digit.
--
-- The decoder outputs are active low ('0' = segment on), which is what the
-- Nexys A7 display needs, so the expected value is the inverse of the table.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY dec_7seg_tb IS
END dec_7seg_tb;

ARCHITECTURE testbench OF dec_7seg_tb IS
    COMPONENT dec_7seg
        PORT (i_hexDigit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              o_segment_a, o_segment_b, o_segment_c, o_segment_d, o_segment_e,
              o_segment_f, o_segment_g : OUT STD_LOGIC);
    END COMPONENT;

    TYPE segTable IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- segments that are lit for each digit, written "abcdefg" ('1' = lit)
    CONSTANT LIT : segTable := (
        "1111110", "0110000", "1101101", "1111001",    -- 0 1 2 3
        "0110011", "1011011", "1011111", "1110000",    -- 4 5 6 7
        "1111111", "1111011", "1110111", "0011111",    -- 8 9 A b
        "1001110", "0111101", "1001111", "1000111");   -- C d E F

    CONSTANT DIGITS : STRING(1 TO 16) := "0123456789AbCdEF";

    SIGNAL tb_hex : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL tb_seg : STD_LOGIC_VECTOR(6 DOWNTO 0);   -- (6) = a ... (0) = g, active low
BEGIN
    uut : dec_7seg
        PORT MAP (
            i_hexDigit  => tb_hex,
            o_segment_a => tb_seg(6),
            o_segment_b => tb_seg(5),
            o_segment_c => tb_seg(4),
            o_segment_d => tb_seg(3),
            o_segment_e => tb_seg(2),
            o_segment_f => tb_seg(1),
            o_segment_g => tb_seg(0)
        );

    stimulus : PROCESS
    BEGIN
        FOR i IN 0 TO 15 LOOP
            tb_hex <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4));
            WAIT FOR 10 ns;
            IF tb_seg = (NOT LIT(i)) THEN
                REPORT "PASS: digit " & DIGITS(i + 1) SEVERITY NOTE;
            ELSE
                REPORT "FAIL: digit " & DIGITS(i + 1) SEVERITY ERROR;
            END IF;
        END LOOP;

        REPORT "End of test bench" SEVERITY NOTE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- shiftRegister_tb : test bench for the N-bit right-shift register (N = 8)
--
-- Checks, in order:
--   1. the register is 00 after reset
--   2. the eight bits of 1C, sent LSB first as a PS/2 keyboard does, end up
--      as 1C on the parallel output
--   3. shift = '0' holds the contents even if the serial input changes
--   4. one more shift moves everything one place to the right and puts the
--      new bit in the MSB (1C -> 8E)
--   5. eight shifts of '0' empty the register
--
-- Inputs change on falling clock edges and outputs are checked on a later
-- falling edge, so ticks(n) lets exactly n rising edges go by.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY shiftRegister_tb IS
END shiftRegister_tb;

ARCHITECTURE testbench OF shiftRegister_tb IS
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

    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT SCAN_CODE  : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"1C";   -- letter A

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_shift    : STD_LOGIC := '0';
    SIGNAL tb_d        : STD_LOGIC := '0';
    SIGNAL tb_q        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : shiftRegister
        GENERIC MAP (N => 8)
        PORT MAP (
            i_clock    => tb_clock,
            i_resetBar => tb_resetBar,
            i_shift    => tb_shift,
            i_d        => tb_d,
            o_q        => tb_q
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        -- compares the parallel output with the expected value
        PROCEDURE check (
            CONSTANT expected : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            CONSTANT message  : IN STRING
        ) IS
        BEGIN
            IF tb_q = expected THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- waits for n falling clock edges (n rising edges go by)
        PROCEDURE ticks (CONSTANT n : IN INTEGER) IS
        BEGIN
            FOR i IN 1 TO n LOOP
                WAIT UNTIL falling_edge(tb_clock);
            END LOOP;
        END PROCEDURE ticks;
    BEGIN
        -- 1. reset
        tb_resetBar <= '0';
        tb_shift    <= '0';
        tb_d        <= '0';
        WAIT FOR 12 ns;
        tb_resetBar <= '1';
        ticks(1);
        check(x"00", "register is 00 after reset");

        -- 2. shift in 1C, least significant bit first
        tb_shift <= '1';
        FOR i IN 0 TO 7 LOOP
            tb_d <= SCAN_CODE(i);
            ticks(1);
        END LOOP;
        check(x"1C", "8 bits sent LSB first give 1C on the output");

        -- 3. hold
        tb_shift <= '0';
        tb_d     <= '1';
        ticks(3);
        check(x"1C", "shift = 0: register holds 1C while the input is 1");

        -- 4. one more shift: new bit enters at the MSB
        tb_shift <= '1';
        ticks(1);
        check(x"8E", "one more shift of a 1: 1C becomes 8E");

        -- 5. flush with zeros
        tb_d <= '0';
        ticks(8);
        check(x"00", "8 shifts of 0 empty the register");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- counter4bit_tb : test bench for the 4-bit counter with set and enable
--
-- Checks, in order:
--   1. the counter is 0 after reset
--   2. enable = '1' counts up by one per clock (0 -> 5)
--   3. enable = '0' holds the count
--   4. set = '1' puts the counter back to 0, even with enable = '0'
--   5. the counter wraps from 15 to 0
--   6. set has priority over enable
--   7. the reset is asynchronous
--
-- Inputs change on falling clock edges and the count is checked on a later
-- falling edge, so ticks(n) lets exactly n rising edges go by.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY counter4bit_tb IS
END counter4bit_tb;

ARCHITECTURE testbench OF counter4bit_tb IS
    COMPONENT counter4bit
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_set      : IN  STD_LOGIC;
            i_enable   : IN  STD_LOGIC;
            o_count    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_set      : STD_LOGIC := '0';
    SIGNAL tb_enable   : STD_LOGIC := '0';
    SIGNAL tb_count    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : counter4bit
        PORT MAP (
            i_clock    => tb_clock,
            i_resetBar => tb_resetBar,
            i_set      => tb_set,
            i_enable   => tb_enable,
            o_count    => tb_count
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        -- compares the counter output with the expected value
        PROCEDURE check (
            CONSTANT expected : IN INTEGER;
            CONSTANT message  : IN STRING
        ) IS
        BEGIN
            IF TO_INTEGER(UNSIGNED(tb_count)) = expected THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- waits for n falling clock edges (n rising edges go by)
        PROCEDURE ticks (CONSTANT n : IN INTEGER) IS
        BEGIN
            FOR i IN 1 TO n LOOP
                WAIT UNTIL falling_edge(tb_clock);
            END LOOP;
        END PROCEDURE ticks;
    BEGIN
        -- 1. reset
        tb_resetBar <= '0';
        tb_set      <= '0';
        tb_enable   <= '0';
        WAIT FOR 12 ns;
        tb_resetBar <= '1';
        ticks(1);
        check(0, "counter is 0 after reset");

        -- 2. count up
        tb_enable <= '1';
        ticks(5);
        check(5, "enable = 1 for 5 clocks: counter is 5");

        -- 3. hold
        tb_enable <= '0';
        ticks(2);
        check(5, "enable = 0: counter holds 5");

        -- 4. set with enable low
        tb_set <= '1';
        ticks(1);
        check(0, "set = 1: counter back to 0 with enable = 0");
        tb_set <= '0';

        -- 5. count to 15 and wrap around
        tb_enable <= '1';
        ticks(11);
        check(11, "counter reaches 11, the length of a PS/2 frame");
        ticks(4);
        check(15, "counter reaches 15");
        ticks(1);
        check(0, "counter wraps from 15 to 0");

        -- 6. set and enable together: set wins
        ticks(3);
        check(3, "counter is 3 before the priority test");
        tb_set <= '1';
        ticks(1);
        check(0, "set = 1 and enable = 1: set has priority");
        tb_set <= '0';

        -- 7. asynchronous reset, applied between two clock edges
        ticks(2);
        check(2, "counter is 2 before the reset test");
        WAIT FOR 2 ns;
        tb_resetBar <= '0';
        WAIT FOR 1 ns;
        check(0, "asynchronous reset clears the counter between clock edges");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- fallEdgeDetector_tb : test bench for the falling-edge detector
--
-- Checks that o_fallEdge:
--   1. stays low when the input rises or does not change
--   2. goes high when the input falls, for exactly one clock period
--   3. does the same again on the next falling edge, even after a high pulse
--      that lasted only one clock period
--
-- In the keyboard controller the input comes from a flip-flop (the filtered
-- clock), so here it also changes just after a rising clock edge (1 ns later).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fallEdgeDetector_tb IS
END fallEdgeDetector_tb;

ARCHITECTURE testbench OF fallEdgeDetector_tb IS
    COMPONENT fallEdgeDetector
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_signal   : IN  STD_LOGIC;
            o_fallEdge : OUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_signal   : STD_LOGIC := '0';
    SIGNAL tb_fallEdge : STD_LOGIC;
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : fallEdgeDetector
        PORT MAP (
            i_clock    => tb_clock,
            i_resetBar => tb_resetBar,
            i_signal   => tb_signal,
            o_fallEdge => tb_fallEdge
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        PROCEDURE check (
            CONSTANT condition : IN BOOLEAN;
            CONSTANT message   : IN STRING
        ) IS
        BEGIN
            IF condition THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- moment at which a flip-flop output would change: just after a rising edge
        PROCEDURE afterRisingEdge IS
        BEGIN
            WAIT UNTIL rising_edge(tb_clock);
            WAIT FOR 1 ns;
        END PROCEDURE afterRisingEdge;

        -- moment at which the outputs are checked: middle of the clock period
        PROCEDURE toFallingEdge IS
        BEGIN
            WAIT UNTIL falling_edge(tb_clock);
        END PROCEDURE toFallingEdge;
    BEGIN
        -- reset, input low
        tb_resetBar <= '0';
        tb_signal   <= '0';
        WAIT FOR 12 ns;
        tb_resetBar <= '1';
        toFallingEdge;
        check(tb_fallEdge = '0', "no pulse after reset");

        -- 1. input rises and stays high: no pulse
        afterRisingEdge;
        tb_signal <= '1';
        toFallingEdge;
        check(tb_fallEdge = '0', "no pulse when the input rises");
        afterRisingEdge;
        afterRisingEdge;
        toFallingEdge;
        check(tb_fallEdge = '0', "no pulse while the input stays high");

        -- 2. input falls: one pulse, one clock period long
        afterRisingEdge;
        tb_signal <= '0';
        toFallingEdge;
        check(tb_fallEdge = '1', "pulse when the input falls");
        afterRisingEdge;
        toFallingEdge;
        check(tb_fallEdge = '0', "pulse is over after one clock period");
        afterRisingEdge;
        toFallingEdge;
        check(tb_fallEdge = '0', "no pulse while the input stays low");

        -- 3. high for a single clock period, then falls again
        afterRisingEdge;
        tb_signal <= '1';
        afterRisingEdge;
        tb_signal <= '0';
        toFallingEdge;
        check(tb_fallEdge = '1', "pulse on the second falling edge");
        afterRisingEdge;
        toFallingEdge;
        check(tb_fallEdge = '0', "second pulse is also one clock period long");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- digitalFilter_tb : test bench for the keyboard-clock digital filter
--
-- The filter output may only change after the input has been stable for
-- 8 samples (8 x 10 ns = 80 ns). Checks, in order:
--   1. a steady high input gives a high output
--   2. a 30 ns low glitch is rejected
--   3. a 70 ns low pulse (7 samples) is still rejected
--   4. an 80 ns low pulse (8 samples) goes through, and the output comes back
--      high afterwards
--   5. a steady low input gives a low output
--   6. a 30 ns high glitch during the low phase is rejected
--   7. the output follows the input back to high
--
-- The input changes on falling clock edges, so ticks(n) means the filter
-- takes exactly n samples. "Rejected" is checked with 'LAST_EVENT: the output
-- must not have moved at all during the glitch and the 120 ns after it.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY digitalFilter_tb IS
END digitalFilter_tb;

ARCHITECTURE testbench OF digitalFilter_tb IS
    COMPONENT digitalFilter
        PORT (
            i_clock         : IN  STD_LOGIC;
            i_resetBar      : IN  STD_LOGIC;
            i_keyboardClock : IN  STD_LOGIC;
            o_filteredClock : OUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_kbdClock : STD_LOGIC := '1';   -- PS/2 clock idles high
    SIGNAL tb_filtered : STD_LOGIC;
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : digitalFilter
        PORT MAP (
            i_clock         => tb_clock,
            i_resetBar      => tb_resetBar,
            i_keyboardClock => tb_kbdClock,
            o_filteredClock => tb_filtered
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        PROCEDURE check (
            CONSTANT condition : IN BOOLEAN;
            CONSTANT message   : IN STRING
        ) IS
        BEGIN
            IF condition THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- waits for n falling clock edges (the filter takes n samples)
        PROCEDURE ticks (CONSTANT n : IN INTEGER) IS
        BEGIN
            FOR i IN 1 TO n LOOP
                WAIT UNTIL falling_edge(tb_clock);
            END LOOP;
        END PROCEDURE ticks;
    BEGIN
        -- 1. reset, then a steady high input
        tb_resetBar <= '0';
        tb_kbdClock <= '1';
        WAIT FOR 12 ns;
        tb_resetBar <= '1';
        ticks(1);
        check(tb_filtered = '0', "output is 0 right after reset");
        ticks(20);
        check(tb_filtered = '1', "steady high input: output goes high");

        -- 2. 30 ns low glitch (3 samples)
        tb_kbdClock <= '0';
        ticks(3);
        tb_kbdClock <= '1';
        ticks(12);
        check(tb_filtered = '1' AND tb_filtered'LAST_EVENT > 15 * CLK_PERIOD,
              "30 ns low glitch is rejected");

        -- 3. 70 ns low pulse (7 samples): one sample short of the window
        tb_kbdClock <= '0';
        ticks(7);
        tb_kbdClock <= '1';
        ticks(12);
        check(tb_filtered = '1' AND tb_filtered'LAST_EVENT > 19 * CLK_PERIOD,
              "70 ns low pulse is rejected");

        -- 4. 80 ns low pulse (8 samples): fills the window, goes through
        tb_kbdClock <= '0';
        ticks(8);
        tb_kbdClock <= '1';
        ticks(2);
        check(tb_filtered = '0', "80 ns low pulse goes through");
        ticks(10);
        check(tb_filtered = '1', "output returns high after the 80 ns pulse");

        -- 5. steady low input (the low half of a keyboard clock period)
        ticks(5);
        tb_kbdClock <= '0';
        ticks(15);
        check(tb_filtered = '0', "steady low input: output goes low");

        -- 6. 30 ns high glitch (3 samples) during the low phase
        tb_kbdClock <= '1';
        ticks(3);
        tb_kbdClock <= '0';
        ticks(12);
        check(tb_filtered = '0' AND tb_filtered'LAST_EVENT > 15 * CLK_PERIOD,
              "30 ns high glitch is rejected");

        -- 7. back to high
        tb_kbdClock <= '1';
        ticks(15);
        check(tb_filtered = '1', "steady high input again: output goes high");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- fsmController_tb : test bench for the keyboard controller FSM
--
-- The test bench plays the role of the edge detector and of the counter: it
-- gives the FSM one-clock falling-edge pulses and sets the counter value by
-- hand, then checks the state (y1 y0) and the three Moore outputs after every
-- clock. It walks through every transition of the state diagram:
--
--   S0 (00) idle                 set_counter = 1
--   S1 (01) shift bit            enable = 1, shift = 1
--   S2 (11) wait for next bit    no output
--   S3 (10) skip parity / stop   enable = 1
--
--   S0 -> S0, S0 -> S1, S1 -> S2, S2 -> S2, S2 -> S1 (counter < 9),
--   S2 -> S3 (counter = 9 and 10), S3 -> S2, S2 -> S0 (counter = 11)
--
-- Inputs change on falling clock edges and the state is checked on the next
-- falling edge, so exactly one rising edge lies between the two.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fsmController_tb IS
END fsmController_tb;

ARCHITECTURE testbench OF fsmController_tb IS
    COMPONENT fsmController
        PORT (
            i_clock        : IN  STD_LOGIC;
            i_resetBar     : IN  STD_LOGIC;
            i_counter      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            i_falling_edge : IN  STD_LOGIC;
            o_y1, o_y0     : OUT STD_LOGIC;
            o_enable, o_set_counter, o_shift : OUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    -- state codes (y1 y0)
    CONSTANT S0 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    CONSTANT S1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
    CONSTANT S2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
    CONSTANT S3 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";

    SIGNAL tb_clock      : STD_LOGIC := '0';
    SIGNAL tb_resetBar   : STD_LOGIC := '0';
    SIGNAL tb_counter    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL tb_fallEdge   : STD_LOGIC := '0';
    SIGNAL tb_y1         : STD_LOGIC;
    SIGNAL tb_y0         : STD_LOGIC;
    SIGNAL tb_enable     : STD_LOGIC;
    SIGNAL tb_setCounter : STD_LOGIC;
    SIGNAL tb_shift      : STD_LOGIC;
    SIGNAL tb_done       : BOOLEAN := FALSE;
BEGIN
    uut : fsmController
        PORT MAP (
            i_clock        => tb_clock,
            i_resetBar     => tb_resetBar,
            i_counter      => tb_counter,
            i_falling_edge => tb_fallEdge,
            o_y1           => tb_y1,
            o_y0           => tb_y0,
            o_enable       => tb_enable,
            o_set_counter  => tb_setCounter,
            o_shift        => tb_shift
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        -- checks the present state and the three Moore outputs
        PROCEDURE expect (
            CONSTANT state      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            CONSTANT enable     : IN STD_LOGIC;
            CONSTANT setCounter : IN STD_LOGIC;
            CONSTANT shift      : IN STD_LOGIC;
            CONSTANT message    : IN STRING
        ) IS
        BEGIN
            IF (tb_y1 & tb_y0) = state AND tb_enable = enable AND
               tb_setCounter = setCounter AND tb_shift = shift THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE expect;

        -- waits for the next falling clock edge (one rising edge goes by)
        PROCEDURE tick IS
        BEGIN
            WAIT UNTIL falling_edge(tb_clock);
        END PROCEDURE tick;

        -- one-clock pulse on the falling-edge input, as the edge detector gives
        PROCEDURE fallingEdgePulse IS
        BEGIN
            tb_fallEdge <= '1';
            WAIT UNTIL falling_edge(tb_clock);
            tb_fallEdge <= '0';
        END PROCEDURE fallingEdgePulse;
    BEGIN
        -- reset: FSM starts idle
        tb_resetBar <= '0';
        tb_counter  <= "0000";
        tb_fallEdge <= '0';
        WAIT FOR 12 ns;
        tb_resetBar <= '1';
        tick;
        expect(S0, '0', '1', '0', "S0 after reset: set_counter = 1");
        tick;
        expect(S0, '0', '1', '0', "S0 -> S0: stays idle without a falling edge");

        -- start bit
        fallingEdgePulse;
        expect(S1, '1', '0', '1', "S0 -> S1 on the start bit: enable = 1 and shift = 1");
        tb_counter <= "0001";
        tick;
        expect(S2, '0', '0', '0', "S1 -> S2: all outputs 0");
        tick;
        expect(S2, '0', '0', '0', "S2 -> S2: waits while there is no falling edge");

        -- a data bit (counter < 9)
        fallingEdgePulse;
        expect(S1, '1', '0', '1', "S2 -> S1 on a data bit (counter = 1): shift it");
        tb_counter <= "0010";
        tick;
        expect(S2, '0', '0', '0', "S1 -> S2");

        -- last data bit: counter is 8 before it and 9 after it
        tb_counter <= "1000";
        fallingEdgePulse;
        expect(S1, '1', '0', '1', "S2 -> S1 on the last data bit (counter = 8)");
        tb_counter <= "1001";
        tick;
        expect(S2, '0', '0', '0', "S1 -> S2 with counter = 9");

        -- parity bit: counted but not shifted
        fallingEdgePulse;
        expect(S3, '1', '0', '0', "S2 -> S3 on the parity bit (counter = 9): enable = 1, shift = 0");
        tb_counter <= "1010";
        tick;
        expect(S2, '0', '0', '0', "S3 -> S2 with counter = 10");

        -- stop bit: counted but not shifted
        fallingEdgePulse;
        expect(S3, '1', '0', '0', "S2 -> S3 on the stop bit (counter = 10)");
        tb_counter <= "1011";
        tick;
        expect(S2, '0', '0', '0', "S3 -> S2 with counter = 11");

        -- frame complete: back to idle without any falling edge
        tick;
        expect(S0, '0', '1', '0', "S2 -> S0 when counter = 11: set_counter = 1");
        tb_counter <= "0000";
        tick;
        expect(S0, '0', '1', '0', "S0: idle again, ready for the next frame");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;

--------------------------------------------------------------------------------
-- sevenSegDisplay_tb : test bench for the multiplexed 7-segment display driver
--
-- DIV_MAX is set to 3 here (a refresh tick every 4 clocks instead of every
-- 12 500) so that a full scan of the eight positions takes only 320 ns.
--
-- Checks, with the byte 1C on the inputs and then with F0:
--   1. position 0: only AN0 is on and the segments show the right digit
--   2. position 1: only AN1 is on and the segments show the left digit
--   3. positions 2 to 7: every anode is off
--   4. the scan comes back to position 0
--   5. the decimal point stays off
--
-- Anodes and segments are active low. o_seg is (6) = CG ... (0) = CA, so the
-- expected patterns are C = 1000110, 1 = 1111001, 0 = 1000000, F = 0001110.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sevenSegDisplay_tb IS
END sevenSegDisplay_tb;

ARCHITECTURE testbench OF sevenSegDisplay_tb IS
    COMPONENT sevenSegDisplay
        GENERIC (DIV_MAX : INTEGER := 12499);
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_digitH   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            i_digitL   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            o_seg      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            o_dp       : OUT STD_LOGIC;
            o_an       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT TIMEOUT    : TIME := 2 us;    -- much longer than one full scan

    -- active-low segment patterns, (6) = g ... (0) = a
    CONSTANT SEG_0 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000000";
    CONSTANT SEG_1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111001";
    CONSTANT SEG_C : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000110";
    CONSTANT SEG_F : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0001110";

    -- active-low anode patterns
    CONSTANT AN_RIGHT : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111110";   -- AN0 on
    CONSTANT AN_LEFT  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111101";   -- AN1 on
    CONSTANT AN_OFF   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";

    SIGNAL tb_clock    : STD_LOGIC := '0';
    SIGNAL tb_resetBar : STD_LOGIC := '0';
    SIGNAL tb_digitH   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    SIGNAL tb_digitL   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
    SIGNAL tb_seg      : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL tb_dp       : STD_LOGIC;
    SIGNAL tb_an       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tb_done     : BOOLEAN := FALSE;
BEGIN
    uut : sevenSegDisplay
        GENERIC MAP (DIV_MAX => 3)
        PORT MAP (
            i_clock    => tb_clock,
            i_resetBar => tb_resetBar,
            i_digitH   => tb_digitH,
            i_digitL   => tb_digitL,
            o_seg      => tb_seg,
            o_dp       => tb_dp,
            o_an       => tb_an
        );

    clockGen : PROCESS
    BEGIN
        WHILE NOT tb_done LOOP
            tb_clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            tb_clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clockGen;

    stimulus : PROCESS
        PROCEDURE check (
            CONSTANT condition : IN BOOLEAN;
            CONSTANT message   : IN STRING
        ) IS
        BEGIN
            IF condition THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;

        -- waits until the anodes show the given pattern (or gives up after
        -- TIMEOUT), then lets the segment outputs settle
        PROCEDURE waitForAnodes (CONSTANT pattern : IN STD_LOGIC_VECTOR(7 DOWNTO 0)) IS
        BEGIN
            IF tb_an /= pattern THEN
                WAIT UNTIL tb_an = pattern FOR TIMEOUT;
            END IF;
            WAIT FOR 1 ns;
        END PROCEDURE waitForAnodes;
    BEGIN
        -- reset with 1C on the inputs
        tb_resetBar <= '0';
        tb_digitH   <= "0001";
        tb_digitL   <= "1100";
        WAIT FOR 12 ns;
        tb_resetBar <= '1';

        -- one full scan with 1C
        waitForAnodes(AN_RIGHT);
        check(tb_an = AN_RIGHT AND tb_seg = SEG_C, "position 0: AN0 on, segments show C");
        waitForAnodes(AN_LEFT);
        check(tb_an = AN_LEFT AND tb_seg = SEG_1, "position 1: AN1 on, segments show 1");
        waitForAnodes(AN_OFF);
        check(tb_an = AN_OFF, "positions 2 to 7: all anodes off");
        WAIT FOR 20 * CLK_PERIOD;
        check(tb_an = AN_OFF, "anodes still off in the middle of positions 2 to 7");
        waitForAnodes(AN_RIGHT);
        check(tb_an = AN_RIGHT AND tb_seg = SEG_C, "scan wraps around: back to AN0 showing C");

        -- change the byte to F0 and scan again
        tb_digitH <= "1111";
        tb_digitL <= "0000";
        WAIT FOR 1 ns;
        check(tb_an = AN_RIGHT AND tb_seg = SEG_0, "new byte F0: AN0 shows 0 straight away");
        waitForAnodes(AN_LEFT);
        check(tb_an = AN_LEFT AND tb_seg = SEG_F, "new byte F0: AN1 shows F");

        check(tb_dp = '1', "decimal point is off");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;