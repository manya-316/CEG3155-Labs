--------------------------------------------------------------------------------
-- keyboardController_tb : test bench for the keyboard controller (simulation only)
--
-- Plays the PS/2 traffic of two key strokes and checks the byte shown on
-- BCD1/BCD2 after every frame:
--      press 'A'    -> 1C
--      release 'A'  -> F0 then 1C   (this frame has noise on the clock line)
--      press 'B'    -> 32
--      release 'B'  -> F0 then 32
--
-- It also puts short glitches (30 ns, shorter than the 80 ns filter window) on
-- the keyboard clock, both while the line is idle and inside a frame, to show
-- that the digital filter rejects them.
--
-- Keyboard clock: 80 us period (12.5 kHz). Total run is about 6 ms, so use
-- "run -all" in XSim. The clock stops by itself at the end of the test.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY keyboardController_tb IS
END keyboardController_tb;

ARCHITECTURE testbench OF keyboardController_tb IS
    COMPONENT keyboardController
        PORT (
            GClock        : IN  STD_LOGIC;
            GReset        : IN  STD_LOGIC;
            KeyboardClock : IN  STD_LOGIC;
            KeyboardInfo  : IN  STD_LOGIC;
            BCD1          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            BCD2          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            SEG           : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            DP            : OUT STD_LOGIC;
            AN            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT CLK_PERIOD : TIME := 10 ns;    -- 100 MHz global clock
    CONSTANT PS2_HALF   : TIME := 40 us;    -- half period of the keyboard clock
    CONSTANT GLITCH     : TIME := 30 ns;    -- shorter than the 80 ns filter window

    SIGNAL tb_clock   : STD_LOGIC := '0';
    SIGNAL tb_reset   : STD_LOGIC := '0';   -- active low, starts asserted
    SIGNAL tb_ps2Clk  : STD_LOGIC := '1';   -- PS/2 lines idle high
    SIGNAL tb_ps2Data : STD_LOGIC := '1';
    SIGNAL tb_bcd1    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL tb_bcd2    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL tb_seg     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL tb_dp      : STD_LOGIC;
    SIGNAL tb_an      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tb_done    : BOOLEAN := FALSE;
BEGIN
    uut : keyboardController
        PORT MAP (
            GClock        => tb_clock,
            GReset        => tb_reset,
            KeyboardClock => tb_ps2Clk,
            KeyboardInfo  => tb_ps2Data,
            BCD1          => tb_bcd1,
            BCD2          => tb_bcd2,
            SEG           => tb_seg,
            DP            => tb_dp,
            AN            => tb_an
        );

    -- 100 MHz global clock, stops when the test is finished
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
        -- Sends one 11-bit PS/2 frame: start, D0..D7, odd parity, stop.
        -- Data changes while the clock is high and is read on the falling edge.
        -- With noisy = TRUE a 30 ns glitch is added in each half of every bit.
        PROCEDURE sendByte (
            CONSTANT byte  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            CONSTANT noisy : IN BOOLEAN
        ) IS
            VARIABLE frame  : STD_LOGIC_VECTOR(10 DOWNTO 0);
            VARIABLE parity : STD_LOGIC;
        BEGIN
            -- odd parity: data bits + parity bit hold an odd number of 1s
            parity := '1';
            FOR i IN 0 TO 7 LOOP
                parity := parity XOR byte(i);
            END LOOP;

            -- frame(0) goes out first
            frame(0)          := '0';      -- start bit
            frame(8 DOWNTO 1) := byte;     -- D0 first, D7 last
            frame(9)          := parity;
            frame(10)         := '1';      -- stop bit

            FOR i IN 0 TO 10 LOOP
                tb_ps2Data <= frame(i);
                WAIT FOR PS2_HALF / 2;

                tb_ps2Clk <= '0';          -- falling edge: controller reads the bit
                IF noisy THEN
                    WAIT FOR PS2_HALF / 2;
                    tb_ps2Clk <= '1';      -- reflection during the low phase
                    WAIT FOR GLITCH;
                    tb_ps2Clk <= '0';
                    WAIT FOR PS2_HALF / 2 - GLITCH;
                ELSE
                    WAIT FOR PS2_HALF;
                END IF;

                tb_ps2Clk <= '1';
                IF noisy THEN
                    WAIT FOR PS2_HALF / 4;
                    tb_ps2Clk <= '0';      -- glitch during the high phase
                    WAIT FOR GLITCH;
                    tb_ps2Clk <= '1';
                    WAIT FOR PS2_HALF / 4 - GLITCH;
                ELSE
                    WAIT FOR PS2_HALF / 2;
                END IF;
            END LOOP;

            tb_ps2Data <= '1';             -- line back to idle
            WAIT FOR 4 * PS2_HALF;         -- gap before the next frame
        END PROCEDURE sendByte;

        -- Compares the displayed byte with the expected scan code
        PROCEDURE check (
            CONSTANT expected : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            CONSTANT message  : IN STRING
        ) IS
        BEGIN
            IF (tb_bcd1 & tb_bcd2) = expected THEN
                REPORT "PASS: " & message SEVERITY NOTE;
            ELSE
                REPORT "FAIL: " & message SEVERITY ERROR;
            END IF;
        END PROCEDURE check;
    BEGIN
        -- global reset
        tb_reset <= '0';
        WAIT FOR 200 ns;
        tb_reset <= '1';
        WAIT FOR 2 us;
        check(x"00", "display shows 00 after reset");

        -- glitch on the idle clock line: must not be taken as a start bit
        tb_ps2Clk <= '0';
        WAIT FOR GLITCH;
        tb_ps2Clk <= '1';
        WAIT FOR 10 us;

        -- press 'A': make code 1C
        sendByte(x"1C", FALSE);
        check(x"1C", "make code of A is 1C");

        -- release 'A': break code F0, 1C (second frame sent over a noisy clock)
        sendByte(x"F0", FALSE);
        check(x"F0", "first byte of the break code is F0");
        sendByte(x"1C", TRUE);
        check(x"1C", "last byte of the break code of A is 1C (noisy clock)");

        -- press and release 'B': 32, then F0, 32
        sendByte(x"32", FALSE);
        check(x"32", "make code of B is 32");
        sendByte(x"F0", FALSE);
        check(x"F0", "first byte of the break code is F0");
        sendByte(x"32", FALSE);
        check(x"32", "last byte of the break code of B is 32");

        REPORT "End of test bench" SEVERITY NOTE;
        tb_done <= TRUE;
        WAIT;
    END PROCESS stimulus;
END testbench;