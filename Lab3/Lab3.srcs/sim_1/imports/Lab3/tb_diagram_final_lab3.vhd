--------------------------------------------------------------------------------
-- tb_diagram_final_lab3 : testbench for the traffic light controller (XSim)
-- Time is scaled down: 1 "second" = 10 clock cycles = 100 ns, debouncer
-- samples every 2 cycles.  Settings: MSC_MAX = 3 s, SSC_MAX = 2 s,
-- MT = 3 s, ST = 2 s.
--
-- Scenarios:
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
        RESETBAR <= '0';
        WAIT FOR 5*CLK_PERIOD;
        RESETBAR <= '1';
        LOAD_FSM <= '1';

        WAIT FOR 10*ONE_SEC;
        ASSERT (MSTL = "001" AND SSTL = "100")
            REPORT "S1 FAIL: main should stay green with no car" SEVERITY error;
        REPORT "Scenario 1 done: MS stays green with no car";

        CAPTEUR <= '1'; WAIT FOR CLK_PERIOD; CAPTEUR <= '0';
        WAIT FOR 2*ONE_SEC;
        ASSERT (MSTL = "001")
            REPORT "S2 FAIL: a glitch got through the debouncer" SEVERITY error;
        REPORT "Scenario 2 done: glitch ignored";

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

        WAIT UNTIL SSTL = "010" FOR 5*ONE_SEC;
        ASSERT (MSTL = "100" AND SSTL = "010")
            REPORT "S4 FAIL: side street did not auto-yield" SEVERITY error;
        WAIT UNTIL MSTL = "001" FOR 5*ONE_SEC;
        ASSERT (MSTL = "001" AND SSTL = "100")
            REPORT "S4 FAIL: did not return to MS green" SEVERITY error;
        REPORT "Scenario 4 done: SS yielded with car still present";

        t_start := NOW;
        WAIT UNTIL MSTL = "010" FOR 6*ONE_SEC;
        ASSERT (MSTL = "010")
            REPORT "S5 FAIL: main never went yellow" SEVERITY error;
        ASSERT (NOW - t_start >= 2*ONE_SEC)
            REPORT "S5 FAIL: main left green before MSC expired" SEVERITY error;
        REPORT "Scenario 5 done: MS waited its green time";
        CAPTEUR <= '0';

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
