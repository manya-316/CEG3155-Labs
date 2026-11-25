--------------------------------------------------------------------------------
-- tb_all.vhd : every Lab 3 testbench in one file
--
-- Contains one testbench per design file, plus tb_all at the bottom, which
-- runs all of them at the same time.
--------------------------------------------------------------------------------
-- tb_enARdFF_2 : testbench for the enabled D flip-flop with async reset
-- Checks: (1) async reset clears Q without a clock edge
--         (2) Q loads D on a rising edge only when enable = 1
--         (3) Q holds when enable = 0
--         (4) Q_bar is always NOT Q
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_enARdFF_2 IS
END tb_enARdFF_2;

ARCHITECTURE sim OF tb_enARdFF_2 IS
    SIGNAL resetBar, d, en, clk, q, qBar : STD_LOGIC := '0';
    SIGNAL done : BOOLEAN := FALSE;
BEGIN
    uut : ENTITY work.enARdFF_2 PORT MAP (resetBar, d, en, clk, q, qBar);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    PROCESS
    BEGIN
        -- (1) Reset held low
        resetBar <= '0'; d <= '1'; en <= '1';
        WAIT FOR 22 ns;
        ASSERT q = '0' REPORT "FAIL: reset did not clear Q" SEVERITY error;

        -- (2) Release reset, D = 1, enable = 1 -> loads on next edge
        resetBar <= '1';
        WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT q = '1' REPORT "FAIL: did not load D = 1" SEVERITY error;

        -- (3) Enable = 0, D = 0 -> Q must hold 1
        en <= '0'; d <= '0';
        WAIT UNTIL rising_edge(clk); WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT q = '1' REPORT "FAIL: Q changed while disabled" SEVERITY error;

        -- Enable again -> loads 0
        en <= '1';
        WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT q = '0' REPORT "FAIL: did not load D = 0" SEVERITY error;

        -- (1b) Async reset between clock edges
        d <= '1';
        WAIT UNTIL rising_edge(clk); WAIT FOR 2 ns;
        resetBar <= '0'; WAIT FOR 1 ns;
        ASSERT q = '0' REPORT "FAIL: async reset not immediate" SEVERITY error;
        resetBar <= '1';

        -- (4) Q_bar
        ASSERT qBar = NOT q REPORT "FAIL: Q_bar is not NOT Q" SEVERITY error;

        REPORT "tb_enARdFF_2: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_counterN : testbench for the 4-bit counter
-- Checks: counts 0..15 and wraps to 0 when enabled, holds when disabled,
--         synchronous clear returns to 0, async reset clears immediately.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_counterN IS
END tb_counterN;

ARCHITECTURE sim OF tb_counterN IS
    SIGNAL clk, resetBar, en, clr : STD_LOGIC := '0';
    SIGNAL count : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL done : BOOLEAN := FALSE;
BEGIN
    uut : ENTITY work.counterN GENERIC MAP (N => 4)
        PORT MAP (clk, resetBar, en, clr, count);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    PROCESS
    BEGIN
        resetBar <= '0'; WAIT FOR 12 ns;
        ASSERT count = "0000" REPORT "FAIL: reset" SEVERITY error;
        resetBar <= '1';

        -- Count through every value and wrap
        en <= '1';
        FOR i IN 1 TO 16 LOOP
            WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
            ASSERT to_integer(unsigned(count)) = (i MOD 16)
                REPORT "FAIL: count wrong at step " & INTEGER'IMAGE(i) SEVERITY error;
        END LOOP;

        -- Count to 5, then disable and check it holds
        FOR i IN 1 TO 5 LOOP WAIT UNTIL rising_edge(clk); END LOOP;
        en <= '0';
        WAIT UNTIL rising_edge(clk); WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT count = "0101" REPORT "FAIL: did not hold at 5" SEVERITY error;

        -- Synchronous clear (works even with enable = 0)
        clr <= '1';
        WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT count = "0000" REPORT "FAIL: clear" SEVERITY error;
        clr <= '0';

        -- Clear has priority over enable
        en <= '1'; clr <= '1';
        WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
        ASSERT count = "0000" REPORT "FAIL: clear priority" SEVERITY error;
        clr <= '0';
        WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;

        -- Async reset mid-count
        resetBar <= '0'; WAIT FOR 1 ns;
        ASSERT count = "0000" REPORT "FAIL: async reset" SEVERITY error;

        REPORT "tb_counterN: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_comparatorN : exhaustive testbench for the 4-bit equality comparator
-- Tries all 256 (A, B) pairs; o_eq must be 1 exactly when A = B.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_comparatorN IS
END tb_comparatorN;

ARCHITECTURE sim OF tb_comparatorN IS
    SIGNAL a, b : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL eq   : STD_LOGIC;
BEGIN
    uut : ENTITY work.comparatorN GENERIC MAP (N => 4) PORT MAP (a, b, eq);

    PROCESS
    BEGIN
        FOR i IN 0 TO 15 LOOP
            FOR j IN 0 TO 15 LOOP
                a <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
                b <= STD_LOGIC_VECTOR(to_unsigned(j, 4));
                WAIT FOR 2 ns;
                IF i = j THEN
                    ASSERT eq = '1' REPORT "FAIL: equal values not detected" SEVERITY error;
                ELSE
                    ASSERT eq = '0' REPORT "FAIL: unequal values flagged equal" SEVERITY error;
                END IF;
            END LOOP;
        END LOOP;
        REPORT "tb_comparatorN: all 256 combinations passed";
        WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_mux2to1N : testbench for the 4-bit 2-to-1 multiplexer
-- sel = 0 must pass A, sel = 1 must pass B, for several value pairs.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_mux2to1N IS
END tb_mux2to1N;

ARCHITECTURE sim OF tb_mux2to1N IS
    SIGNAL a, b, y : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sel : STD_LOGIC;
    TYPE pairs IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
    CONSTANT AV : pairs := ("0011", "1111", "0000", "1010");
    CONSTANT BV : pairs := ("0010", "0000", "1111", "0101");
BEGIN
    uut : ENTITY work.mux2to1N GENERIC MAP (N => 4) PORT MAP (a, b, sel, y);

    PROCESS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            a <= AV(i); b <= BV(i);
            sel <= '0'; WAIT FOR 10 ns;
            ASSERT y = AV(i) REPORT "FAIL: sel = 0 did not pass A" SEVERITY error;
            sel <= '1'; WAIT FOR 10 ns;
            ASSERT y = BV(i) REPORT "FAIL: sel = 1 did not pass B" SEVERITY error;
        END LOOP;
        REPORT "tb_mux2to1N: all checks passed";
        WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_clk_div : testbench for the tick generator
-- G_COUNT shrunk to 5 so the waveform is readable.
-- Checks: tick is exactly one clock wide, one tick every 5 clocks,
--         reset holds the tick low.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_clk_div IS
END tb_clk_div;

ARCHITECTURE sim OF tb_clk_div IS
    SIGNAL clk, resetBar, tick : STD_LOGIC := '0';
    SIGNAL done : BOOLEAN := FALSE;
BEGIN
    uut : ENTITY work.clk_div GENERIC MAP (G_COUNT => 5) PORT MAP (clk, resetBar, tick);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    PROCESS
        VARIABLE highCount : INTEGER := 0;
    BEGIN
        resetBar <= '0'; WAIT FOR 30 ns;
        ASSERT tick = '0' REPORT "FAIL: tick high during reset" SEVERITY error;
        resetBar <= '1';

        -- Over 20 clocks there must be exactly 4 ticks, each one cycle wide
        FOR i IN 1 TO 20 LOOP
            WAIT UNTIL rising_edge(clk); WAIT FOR 1 ns;
            IF tick = '1' THEN highCount := highCount + 1; END IF;
        END LOOP;
        ASSERT highCount = 4
            REPORT "FAIL: expected 4 ticks in 20 clocks, got " & INTEGER'IMAGE(highCount)
            SEVERITY error;

        REPORT "tb_clk_div: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_debouncer : testbench for the synchronizer + debouncer
-- Sample tick every 4 clocks (stands in for the 100 Hz tick).
-- Checks: (1) a short glitch is ignored
--         (2) a bouncy press, then a steady hold, gives one clean '1'
--         (3) a bouncy release gives one clean '0'
--         (4) output never toggles more than once per press/release
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_debouncer IS
END tb_debouncer;

ARCHITECTURE sim OF tb_debouncer IS
    SIGNAL clk, resetBar, tick, raw, clean : STD_LOGIC := '0';
    SIGNAL done : BOOLEAN := FALSE;
    SIGNAL edges : INTEGER := 0;
BEGIN
    uut : ENTITY work.debouncer PORT MAP (clk, resetBar, tick, raw, clean);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    -- Sample tick: one clock wide, every 4 clocks
    tickGen : PROCESS
    BEGIN
        WHILE NOT done LOOP
            WAIT UNTIL rising_edge(clk); tick <= '0';
            WAIT UNTIL rising_edge(clk);
            WAIT UNTIL rising_edge(clk);
            WAIT UNTIL rising_edge(clk); tick <= '1';
        END LOOP;
        WAIT;
    END PROCESS;

    -- Count output changes
    edgeCount : PROCESS (clean)
    BEGIN
        IF resetBar = '1' THEN edges <= edges + 1; END IF;
    END PROCESS;

    stim : PROCESS
    BEGIN
        resetBar <= '0'; WAIT FOR 25 ns; resetBar <= '1';
        WAIT FOR 100 ns;

        -- (1) 10 ns glitch
        raw <= '1'; WAIT FOR 10 ns; raw <= '0';
        WAIT FOR 300 ns;
        ASSERT clean = '0' REPORT "FAIL: glitch passed through" SEVERITY error;
        REPORT "Glitch ignored";

        -- (2) Bouncy press then hold
        raw <= '1'; WAIT FOR 15 ns; raw <= '0'; WAIT FOR 20 ns;
        raw <= '1'; WAIT FOR 10 ns; raw <= '0'; WAIT FOR 15 ns;
        raw <= '1';
        WAIT FOR 400 ns;
        ASSERT clean = '1' REPORT "FAIL: held press not detected" SEVERITY error;
        REPORT "Press detected";

        -- (3) Bouncy release
        raw <= '0'; WAIT FOR 15 ns; raw <= '1'; WAIT FOR 10 ns;
        raw <= '0';
        WAIT FOR 400 ns;
        ASSERT clean = '0' REPORT "FAIL: release not detected" SEVERITY error;
        REPORT "Release detected";

        -- (4) Exactly one rise and one fall
        ASSERT edges = 2
            REPORT "FAIL: output changed " & INTEGER'IMAGE(edges) & " times, expected 2"
            SEVERITY error;

        REPORT "tb_debouncer: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_fsmController : testbench for the traffic light FSM on its own
-- The done flags are driven directly so each transition can be tested.
-- Checks every row of the state table:
--   S0 stays without (car AND green done); leaves with both
--   S1 stays until MT done;  S2 stays until SSC done;  S3 stays until ST done
--   Correct MSTL / SSTL in each state;  enable = 0 freezes the state.
-- Lights: "001" green, "010" yellow, "100" red.  State shown as y1 y0.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_fsmController IS
END tb_fsmController;

ARCHITECTURE sim OF tb_fsmController IS
    SIGNAL clk, resetBar, en, greenDone, sscs, mtDone, stDone : STD_LOGIC := '0';
    SIGNAL MSTL, SSTL : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL y1, y0, s0, s1, s2, s3 : STD_LOGIC;
    SIGNAL done : BOOLEAN := FALSE;

    PROCEDURE tick (SIGNAL c : IN STD_LOGIC) IS
    BEGIN
        WAIT UNTIL rising_edge(c); WAIT FOR 1 ns;
    END PROCEDURE;
BEGIN
    uut : ENTITY work.fsmController
        PORT MAP (clk, resetBar, en, greenDone, sscs, mtDone, stDone,
                  MSTL, SSTL, y1, y0, s0, s1, s2, s3);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    PROCESS
    BEGIN
        resetBar <= '0'; WAIT FOR 12 ns; resetBar <= '1'; en <= '1';
        ASSERT y1 = '0' AND y0 = '0' AND MSTL = "001" AND SSTL = "100"
            REPORT "FAIL: reset state is not S0" SEVERITY error;

        -- S0: green done but no car -> stay
        greenDone <= '1'; sscs <= '0'; tick(clk); tick(clk);
        ASSERT s0 = '1' REPORT "FAIL: left S0 without a car" SEVERITY error;
        -- S0: car but green not done -> stay
        greenDone <= '0'; sscs <= '1'; tick(clk);
        ASSERT s0 = '1' REPORT "FAIL: left S0 before green done" SEVERITY error;
        -- S0: both -> S1
        greenDone <= '1'; tick(clk);
        greenDone <= '0'; sscs <= '0';
        ASSERT s1 = '1' AND MSTL = "010" AND SSTL = "100"
            REPORT "FAIL: S0 -> S1" SEVERITY error;
        REPORT "S0 -> S1 ok";

        -- S1: stay until MT done
        tick(clk);
        ASSERT s1 = '1' REPORT "FAIL: left S1 early" SEVERITY error;
        mtDone <= '1'; tick(clk); mtDone <= '0';
        ASSERT s2 = '1' AND MSTL = "100" AND SSTL = "001"
            REPORT "FAIL: S1 -> S2" SEVERITY error;
        REPORT "S1 -> S2 ok";

        -- S2: car present does not matter, stay until SSC done
        sscs <= '1'; tick(clk);
        ASSERT s2 = '1' REPORT "FAIL: left S2 early" SEVERITY error;
        greenDone <= '1'; tick(clk); greenDone <= '0';
        ASSERT s3 = '1' AND MSTL = "100" AND SSTL = "010"
            REPORT "FAIL: S2 -> S3" SEVERITY error;
        REPORT "S2 -> S3 ok";

        -- S3: stay until ST done
        tick(clk);
        ASSERT s3 = '1' REPORT "FAIL: left S3 early" SEVERITY error;
        stDone <= '1'; tick(clk); stDone <= '0'; sscs <= '0';
        ASSERT s0 = '1' AND MSTL = "001" AND SSTL = "100"
            REPORT "FAIL: S3 -> S0" SEVERITY error;
        REPORT "S3 -> S0 ok";

        -- Enable = 0 freezes the state
        en <= '0'; greenDone <= '1'; sscs <= '1'; tick(clk); tick(clk);
        ASSERT s0 = '1' REPORT "FAIL: moved while disabled" SEVERITY error;
        en <= '1'; tick(clk);
        ASSERT s1 = '1' REPORT "FAIL: did not resume after enable" SEVERITY error;
        REPORT "Enable (LOAD_FSM) ok";

        -- Async reset from S1
        resetBar <= '0'; WAIT FOR 2 ns;
        ASSERT s0 = '1' REPORT "FAIL: reset did not return to S0" SEVERITY error;
        REPORT "Reset ok";

        REPORT "tb_fsmController: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_binToBCD : exhaustive testbench for the binary to BCD converter
-- For every input 0..15, checks tens*10 + ones = input and ones <= 9.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_binToBCD IS
END tb_binToBCD;

ARCHITECTURE sim OF tb_binToBCD IS
    SIGNAL bin, tens, ones : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    uut : ENTITY work.binToBCD PORT MAP (bin, tens, ones);

    PROCESS
    BEGIN
        FOR i IN 0 TO 15 LOOP
            bin <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
            WAIT FOR 10 ns;
            ASSERT to_integer(unsigned(tens)) * 10 + to_integer(unsigned(ones)) = i
                REPORT "FAIL: wrong BCD for " & INTEGER'IMAGE(i) SEVERITY error;
            ASSERT to_integer(unsigned(ones)) <= 9
                REPORT "FAIL: ones digit above 9 for " & INTEGER'IMAGE(i) SEVERITY error;
        END LOOP;
        REPORT "tb_binToBCD: all 16 values passed";
        WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_dec_7seg : testbench for the course-provided seven-segment decoder
-- Checks digits 0..9 against the standard active-low patterns (g f e d c b a).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_dec_7seg IS
END tb_dec_7seg;

ARCHITECTURE sim OF tb_dec_7seg IS
    SIGNAL digit : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL seg   : STD_LOGIC_VECTOR(6 DOWNTO 0);   -- seg(0) = a ... seg(6) = g
    TYPE table IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    CONSTANT EXPECTED : table := (
        "1000000", "1111001", "0100100", "0110000", "0011001",
        "0010010", "0000010", "1111000", "0000000", "0010000");
BEGIN
    uut : ENTITY work.dec_7seg
        PORT MAP (digit, seg(0), seg(1), seg(2), seg(3), seg(4), seg(5), seg(6));

    PROCESS
    BEGIN
        FOR i IN 0 TO 9 LOOP
            digit <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
            WAIT FOR 10 ns;
            ASSERT seg = EXPECTED(i)
                REPORT "FAIL: wrong segments for digit " & INTEGER'IMAGE(i) SEVERITY error;
        END LOOP;
        REPORT "tb_dec_7seg: digits 0 to 9 passed";
        WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_displayController : testbench for the multiplexed display driver
-- Shows "12" (left = 1, right = 2).  The refresh select is bit 16 of the
-- counter, so each digit is lit for 65 536 clocks (about 655 us at 100 MHz).
-- Checks: only AN0 or AN1 is low at any time, AN2..AN7 always high,
--         SEG matches the digit for whichever anode is on.
-- Run for about 1.4 ms.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_displayController IS
END tb_displayController;

ARCHITECTURE sim OF tb_displayController IS
    SIGNAL clk, resetBar : STD_LOGIC := '0';
    SIGNAL seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL an  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL done : BOOLEAN := FALSE;
    CONSTANT SEG_1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111001";
    CONSTANT SEG_2 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100100";
BEGIN
    uut : ENTITY work.displayController
        PORT MAP (clk, resetBar, "0001", "0010", seg, an);

    clk <= NOT clk AFTER 5 ns WHEN NOT done ELSE '0';

    PROCESS
    BEGIN
        resetBar <= '0'; WAIT FOR 20 ns; resetBar <= '1';

        -- Right digit phase
        WAIT FOR 300 us;
        ASSERT an = "11111110" REPORT "FAIL: AN0 not selected first" SEVERITY error;
        ASSERT seg = SEG_2 REPORT "FAIL: right digit should show 2" SEVERITY error;
        REPORT "Right digit shows 2";

        -- Left digit phase
        WAIT FOR 500 us;
        ASSERT an = "11111101" REPORT "FAIL: AN1 not selected" SEVERITY error;
        ASSERT seg = SEG_1 REPORT "FAIL: left digit should show 1" SEVERITY error;
        REPORT "Left digit shows 1";

        -- Back to right digit
        WAIT FOR 600 us;
        ASSERT an = "11111110" REPORT "FAIL: did not alternate back" SEVERITY error;
        REPORT "tb_displayController: all checks passed";
        done <= TRUE; WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_diagram_final_lab3 : testbench for the traffic light controller (XSim)
-- Time is scaled down: 1 "second" = 10 clock cycles = 100 ns, debouncer
-- samples every 2 cycles.  Settings: MSC_MAX = 3 s, SSC_MAX = 2 s,
-- MT = 3 s, ST = 2 s.
--
-- Scenarios (Section 5.5 / Section 6):
--   1. Main street green with no car: stays green indefinitely
--   2. Debouncer integrity: a 1-cycle glitch on the button is ignored
--   3. Car arrives AFTER the MSC time: main goes yellow almost immediately
--   4. Side street yields automatically after SSC, even with the car held
--   5. Car arrives BEFORE the MSC time: main waits out its green first
--   6. Global reset mid-cycle returns to S0 (MS green)
-- Light encoding: "001" = green, "010" = yellow, "100" = red
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_diagram_final_lab3 IS
END tb_diagram_final_lab3;

ARCHITECTURE sim OF tb_diagram_final_lab3 IS
    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT ONE_SEC    : TIME := 100 ns;   -- 10 cycles

    SIGNAL CLOCK    : STD_LOGIC := '0';
    SIGNAL RESETBAR : STD_LOGIC := '0';
    SIGNAL LOAD_FSM : STD_LOGIC := '0';
    SIGNAL MSC_MAX  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    SIGNAL SSC_MAX  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    SIGNAL CAPTEUR  : STD_LOGIC := '0';
    SIGNAL MSTL, SSTL : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SEG : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL AN  : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL simDone : BOOLEAN := FALSE;
BEGIN
    uut : ENTITY work.diagram_final_lab3
        GENERIC MAP (G_ONE_SECOND => 10, G_SAMPLE => 2,
                     G_MT => "0011", G_ST => "0010")
        PORT MAP (CLOCK, RESETBAR, LOAD_FSM, MSC_MAX, SSC_MAX, CAPTEUR,
                  MSTL, SSTL, SEG, AN);

    clockGen : PROCESS
    BEGIN
        WHILE NOT simDone LOOP
            CLOCK <= '0'; WAIT FOR CLK_PERIOD/2;
            CLOCK <= '1'; WAIT FOR CLK_PERIOD/2;
        END LOOP;
        WAIT;
    END PROCESS;

    stimulus : PROCESS
        VARIABLE t_start : TIME;
    BEGIN
        -- Reset and enable
        RESETBAR <= '0';
        WAIT FOR 5*CLK_PERIOD;
        RESETBAR <= '1';
        LOAD_FSM <= '1';

        ------------------------------------------------------------ Scenario 1
        WAIT FOR 10*ONE_SEC;
        ASSERT (MSTL = "001" AND SSTL = "100")
            REPORT "S1 FAIL: main should stay green with no car" SEVERITY error;
        REPORT "Scenario 1 done: MS stays green with no car";

        ------------------------------------------------------------ Scenario 2
        CAPTEUR <= '1'; WAIT FOR CLK_PERIOD; CAPTEUR <= '0';   -- 10 ns glitch
        WAIT FOR 2*ONE_SEC;
        ASSERT (MSTL = "001")
            REPORT "S2 FAIL: a glitch got through the debouncer" SEVERITY error;
        REPORT "Scenario 2 done: glitch ignored";

        ------------------------------------------------------------ Scenario 3
        -- Bouncy press after MSC has already expired, then held
        CAPTEUR <= '1'; WAIT FOR 15 ns; CAPTEUR <= '0'; WAIT FOR 10 ns;
        CAPTEUR <= '1'; WAIT FOR 10 ns; CAPTEUR <= '0'; WAIT FOR 15 ns;
        CAPTEUR <= '1';
        WAIT UNTIL MSTL = "010" FOR 2*ONE_SEC;
        ASSERT (MSTL = "010" AND SSTL = "100")
            REPORT "S3 FAIL: main did not go yellow after car arrived" SEVERITY error;
        REPORT "Scenario 3: MS yellow";

        WAIT UNTIL SSTL = "001" FOR 6*ONE_SEC;
        ASSERT (MSTL = "100" AND SSTL = "001")
            REPORT "S3 FAIL: side street did not turn green" SEVERITY error;
        REPORT "Scenario 3 done: SS green";

        ------------------------------------------------------------ Scenario 4
        -- Car still held: side street must still yield after SSC
        WAIT UNTIL SSTL = "010" FOR 5*ONE_SEC;
        ASSERT (MSTL = "100" AND SSTL = "010")
            REPORT "S4 FAIL: side street did not auto-yield" SEVERITY error;
        WAIT UNTIL MSTL = "001" FOR 5*ONE_SEC;
        ASSERT (MSTL = "001" AND SSTL = "100")
            REPORT "S4 FAIL: did not return to MS green" SEVERITY error;
        REPORT "Scenario 4 done: SS yielded with car still present";

        ------------------------------------------------------------ Scenario 5
        -- Car is already waiting as MS green starts: must wait about MSC (3 s)
        t_start := NOW;
        WAIT UNTIL MSTL = "010" FOR 6*ONE_SEC;
        ASSERT (MSTL = "010")
            REPORT "S5 FAIL: main never went yellow" SEVERITY error;
        ASSERT (NOW - t_start >= 2*ONE_SEC)
            REPORT "S5 FAIL: main left green before MSC expired" SEVERITY error;
        REPORT "Scenario 5 done: MS waited its green time";
        CAPTEUR <= '0';

        ------------------------------------------------------------ Scenario 6
        WAIT UNTIL SSTL = "001" FOR 6*ONE_SEC;
        RESETBAR <= '0';
        WAIT FOR 3*CLK_PERIOD;
        ASSERT (MSTL = "001" AND SSTL = "100")
            REPORT "S6 FAIL: reset did not return to MS green" SEVERITY error;
        RESETBAR <= '1';
        WAIT FOR 3*ONE_SEC;
        ASSERT (MSTL = "001")
            REPORT "S6 FAIL: did not stay green after reset" SEVERITY error;
        REPORT "Scenario 6 done: reset works";

        REPORT "*** Simulation complete ***";
        simDone <= TRUE;
        WAIT;
    END PROCESS;
END sim;


--------------------------------------------------------------------------------
-- tb_all : runs every testbench above in a single simulation
-- Run for 1.5 ms (the display testbench is the longest).
--------------------------------------------------------------------------------
ENTITY tb_all IS
END tb_all;

ARCHITECTURE sim OF tb_all IS
BEGIN
    t_ff      : ENTITY work.tb_enARdFF_2;
    t_counter : ENTITY work.tb_counterN;
    t_compare : ENTITY work.tb_comparatorN;
    t_mux     : ENTITY work.tb_mux2to1N;
    t_clkdiv  : ENTITY work.tb_clk_div;
    t_debounce: ENTITY work.tb_debouncer;
    t_fsm     : ENTITY work.tb_fsmController;
    t_bcd     : ENTITY work.tb_binToBCD;
    t_7seg    : ENTITY work.tb_dec_7seg;
    t_display : ENTITY work.tb_displayController;
    t_top     : ENTITY work.tb_diagram_final_lab3;
END sim;