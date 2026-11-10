--------------------------------------------------------------------------------
-- diagram_final_lab3 : TOP LEVEL - Traffic Light Controller (Nexys A7-100T)
-- Structural netlist that wires together the blocks:
--   clk_div (x2)  -> 1 Hz tick for counters/timers, 100 Hz tick for debouncer
--   debouncer     -> clean car sensor (SSCS) from BTNU
--   counterN (x4) -> MS green counter, SS green counter, MT timer, ST timer
--   mux2to1N (x2) + comparatorN -> shared "green time expired" comparator
--   comparatorN (x2) -> yellow timers expired (fixed MT / ST constants)
--   fsmController -> state machine and light outputs
--   binToBCD + displayController -> bonus count display
--
-- Board mapping (Table 10):
--   CLOCK = 100 MHz (E3), RESETBAR = CPU RESETN (active low),
--   LOAD_FSM = SW0, MSC_MAX = SW4..SW1, SSC_MAX = SW8..SW5, CAPTEUR = BTNU,
--   MSTL -> LD16 (G,B,R), SSTL -> LD17 (G,B,R), SEG/AN -> 7-segment display.
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY diagram_final_lab3 IS
    GENERIC (
        G_ONE_SECOND : POSITIVE := 100_000_000;   -- 1 Hz tick
        G_SAMPLE     : POSITIVE := 1_000_000;     -- 100 Hz debouncer tick
        G_MT         : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";  -- MS yellow = 3 s
        G_ST         : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010"   -- SS yellow = 2 s
    );
    PORT (
        CLOCK    : IN  STD_LOGIC;
        RESETBAR : IN  STD_LOGIC;
        LOAD_FSM : IN  STD_LOGIC;
        MSC_MAX  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        SSC_MAX  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        CAPTEUR  : IN  STD_LOGIC;
        MSTL     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SSTL     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SEG      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        AN       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END diagram_final_lab3;

ARCHITECTURE structural OF diagram_final_lab3 IS

    COMPONENT clk_div
        GENERIC (G_COUNT : POSITIVE := 100_000_000);
        PORT (i_clock, i_resetBar : IN STD_LOGIC; o_tick : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT debouncer
        PORT (i_clock, i_resetBar, i_sampleTick, i_raw : IN STD_LOGIC;
              o_clean : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT counterN
        GENERIC (N : INTEGER := 4);
        PORT (i_clock, i_resetBar, i_enable, i_clear : IN STD_LOGIC;
              o_count : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT comparatorN
        GENERIC (N : INTEGER := 4);
        PORT (i_a, i_b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
              o_eq : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT mux2to1N
        GENERIC (N : INTEGER := 4);
        PORT (i_a, i_b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
              i_sel : IN STD_LOGIC;
              o_y : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT fsmController
        PORT (i_clock, i_resetBar, i_enable, i_greenDone, i_sscs,
              i_mtDone, i_stDone : IN STD_LOGIC;
              o_MSTL, o_SSTL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
              o_y1, o_y0, o_s0, o_s1, o_s2, o_s3 : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT binToBCD
        PORT (i_bin : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              o_tens, o_ones : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
    END COMPONENT;

    COMPONENT displayController
        PORT (i_clock, i_resetBar : IN STD_LOGIC;
              i_left, i_right : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              o_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
              o_an  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;

    SIGNAL int_tick1Hz, int_tick100Hz, int_runTick, int_sscs : STD_LOGIC;

    SIGNAL int_y1, int_y0, int_s0, int_s1, int_s2, int_s3 : STD_LOGIC;

    SIGNAL int_msCount, int_ssCount, int_mtCount, int_stCount : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_msEn, int_ssEn, int_mtEn, int_stEn             : STD_LOGIC;
    SIGNAL int_msClr, int_ssClr, int_mtClr, int_stClr         : STD_LOGIC;

    SIGNAL int_curCount, int_curMax : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_greenDone, int_mtDone, int_stDone : STD_LOGIC;

    SIGNAL int_bcd1, int_bcd2 : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    div1Hz : clk_div GENERIC MAP (G_COUNT => G_ONE_SECOND)
                     PORT MAP (CLOCK, RESETBAR, int_tick1Hz);
    div100Hz : clk_div GENERIC MAP (G_COUNT => G_SAMPLE)
                       PORT MAP (CLOCK, RESETBAR, int_tick100Hz);

    int_runTick <= int_tick1Hz AND LOAD_FSM;

    carSensor : debouncer PORT MAP (CLOCK, RESETBAR, int_tick100Hz, CAPTEUR, int_sscs);

    controller : fsmController
        PORT MAP (i_clock     => CLOCK,
                  i_resetBar  => RESETBAR,
                  i_enable    => LOAD_FSM,
                  i_greenDone => int_greenDone,
                  i_sscs      => int_sscs,
                  i_mtDone    => int_mtDone,
                  i_stDone    => int_stDone,
                  o_MSTL      => MSTL,
                  o_SSTL      => SSTL,
                  o_y1 => int_y1, o_y0 => int_y0,
                  o_s0 => int_s0, o_s1 => int_s1, o_s2 => int_s2, o_s3 => int_s3);

    int_msEn  <= int_runTick AND int_s0 AND (NOT int_greenDone);
    int_msClr <= NOT int_s0;
    int_ssEn  <= int_runTick AND int_s2 AND (NOT int_greenDone);
    int_ssClr <= NOT int_s2;
    int_mtEn  <= int_runTick AND int_s1 AND (NOT int_mtDone);
    int_mtClr <= NOT int_s1;
    int_stEn  <= int_runTick AND int_s3 AND (NOT int_stDone);
    int_stClr <= NOT int_s3;

    msCounter : counterN GENERIC MAP (4) PORT MAP (CLOCK, RESETBAR, int_msEn, int_msClr, int_msCount);
    ssCounter : counterN GENERIC MAP (4) PORT MAP (CLOCK, RESETBAR, int_ssEn, int_ssClr, int_ssCount);
    mtTimer   : counterN GENERIC MAP (4) PORT MAP (CLOCK, RESETBAR, int_mtEn, int_mtClr, int_mtCount);
    stTimer   : counterN GENERIC MAP (4) PORT MAP (CLOCK, RESETBAR, int_stEn, int_stClr, int_stCount);

    countMux : mux2to1N GENERIC MAP (4) PORT MAP (int_msCount, int_ssCount, int_y1, int_curCount);
    maxMux   : mux2to1N GENERIC MAP (4) PORT MAP (MSC_MAX, SSC_MAX, int_y1, int_curMax);
    greenCmp : comparatorN GENERIC MAP (4) PORT MAP (int_curCount, int_curMax, int_greenDone);

    mtCmp : comparatorN GENERIC MAP (4) PORT MAP (int_mtCount, G_MT, int_mtDone);
    stCmp : comparatorN GENERIC MAP (4) PORT MAP (int_stCount, G_ST, int_stDone);

    bcdConv : binToBCD PORT MAP (int_curCount, int_bcd1, int_bcd2);
    display : displayController PORT MAP (CLOCK, RESETBAR, int_bcd1, int_bcd2, SEG, AN);

END structural;
