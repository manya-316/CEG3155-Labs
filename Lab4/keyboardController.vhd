--------------------------------------------------------------------------------
-- keyboardController : PS/2 keyboard controller, structural top level (Lab 4)
--
-- Reads the 11-bit PS/2 frames sent by the keyboard and shows the last
-- scan-code byte in hexadecimal (Figure 12 of the lab handout).
--
--   KeyboardClock  -> digitalFilter -> fallEdgeDetector -> fsmController
--   KeyboardInfo   -> shiftRegister (8 bits) -> bit-bucket flip-flop
--   fsmController <-> counter4bit (counts the 11 bits of a frame)
--   scan code      -> BCD1 / BCD2 (LEDs) and sevenSegDisplay (two hex digits)
--
-- One frame as seen by the FSM (one falling edge of the filtered clock per bit):
--   edge 1      start bit : shifted in, counter 0 -> 1
--   edges 2..9  D0..D7    : shifted in, counter -> 9. The 9th shift pushes the
--                           start bit out of the register into the bit bucket,
--                           which leaves D7..D0 in the scan-code register.
--   edge 10     parity    : skipped, counter -> 10
--   edge 11     stop      : skipped, counter -> 11, then the FSM goes back to
--                           idle and sets the counter back to 0.
--
-- Every flip-flop in the design is clocked by GClock and reset by GReset.
-- GReset comes from CPU_RESETN, which is already active low (pressed = '0'),
-- so it drives the active-low reset of the flip-flops directly.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY keyboardController IS
    PORT (
        GClock        : IN  STD_LOGIC;                      -- 100 MHz global clock
        GReset        : IN  STD_LOGIC;                      -- global reset (CPU_RESETN, active low)
        KeyboardClock : IN  STD_LOGIC;                      -- PS/2 clock
        KeyboardInfo  : IN  STD_LOGIC;                      -- PS/2 data
        BCD1          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   -- left hex digit of the scan code
        BCD2          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   -- right hex digit of the scan code
        SEG           : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);   -- 7-segment cathodes CA..CG
        DP            : OUT STD_LOGIC;                      -- decimal point
        AN            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)    -- 7-segment anodes
    );
END keyboardController;

ARCHITECTURE structural OF keyboardController IS
    COMPONENT digitalFilter
        PORT (
            i_clock         : IN  STD_LOGIC;
            i_resetBar      : IN  STD_LOGIC;
            i_keyboardClock : IN  STD_LOGIC;
            o_filteredClock : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT fallEdgeDetector
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_signal   : IN  STD_LOGIC;
            o_fallEdge : OUT STD_LOGIC
        );
    END COMPONENT;

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

    COMPONENT counter4bit
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_set      : IN  STD_LOGIC;
            i_enable   : IN  STD_LOGIC;
            o_count    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

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

    SIGNAL int_resetBar      : STD_LOGIC;
    SIGNAL int_filteredClock : STD_LOGIC;                      -- filtered keyboard clock
    SIGNAL int_fallEdge      : STD_LOGIC;                      -- one pulse per PS/2 bit
    SIGNAL int_count         : STD_LOGIC_VECTOR(3 DOWNTO 0);   -- bits received in this frame
    SIGNAL int_enable        : STD_LOGIC;                      -- FSM: count one more bit
    SIGNAL int_setCounter    : STD_LOGIC;                      -- FSM: counter back to 0
    SIGNAL int_shift         : STD_LOGIC;                      -- FSM: shift KeyboardInfo in
    SIGNAL int_scanCode      : STD_LOGIC_VECTOR(7 DOWNTO 0);   -- last scan-code byte
    SIGNAL int_startBit      : STD_LOGIC;                      -- bit-bucket contents
BEGIN
    -- CPU_RESETN is active low, same polarity as the flip-flop resets
    int_resetBar <= GReset;

    -- Digital filter: cleans up the keyboard clock
    clockFilter : digitalFilter
        PORT MAP (
            i_clock         => GClock,
            i_resetBar      => int_resetBar,
            i_keyboardClock => KeyboardClock,
            o_filteredClock => int_filteredClock
        );

    -- KeyboardInfo is valid on the falling edge of the keyboard clock
    edgeDetector : fallEdgeDetector
        PORT MAP (
            i_clock    => GClock,
            i_resetBar => int_resetBar,
            i_signal   => int_filteredClock,
            o_fallEdge => int_fallEdge
        );

    -- FSM controller (Moore): decides when to shift, count and restart
    controller : fsmController
        PORT MAP (
            i_clock        => GClock,
            i_resetBar     => int_resetBar,
            i_counter      => int_count,
            i_falling_edge => int_fallEdge,
            o_y1           => OPEN,
            o_y0           => OPEN,
            o_enable       => int_enable,
            o_set_counter  => int_setCounter,
            o_shift        => int_shift
        );

    -- 4-bit counter: number of bits received in the current frame
    bitCounter : counter4bit
        PORT MAP (
            i_clock    => GClock,
            i_resetBar => int_resetBar,
            i_set      => int_setCounter,
            i_enable   => int_enable,
            o_count    => int_count
        );

    -- Shift register: collects the scan code, LSB first
    scanCodeRegister : shiftRegister
        GENERIC MAP (N => 8)
        PORT MAP (
            i_clock    => GClock,
            i_resetBar => int_resetBar,
            i_shift    => int_shift,
            i_d        => KeyboardInfo,
            o_q        => int_scanCode
        );

    -- D flip-flop used as a bit bucket: catches the bit leaving the shift
    -- register, so it ends each frame holding the start bit
    bitBucket : enARdFF_2
        PORT MAP (
            i_resetBar => int_resetBar,
            i_d        => int_scanCode(0),
            i_enable   => int_shift,
            i_clock    => GClock,
            o_q        => int_startBit,
            o_qBar     => OPEN
        );

    -- Two hex digits on the 7-segment displays
    display : sevenSegDisplay
        PORT MAP (
            i_clock    => GClock,
            i_resetBar => int_resetBar,
            i_digitH   => int_scanCode(7 DOWNTO 4),
            i_digitL   => int_scanCode(3 DOWNTO 0),
            o_seg      => SEG,
            o_dp       => DP,
            o_an       => AN
        );

    -- Same two digits in binary on the LEDs
    BCD1 <= int_scanCode(7 DOWNTO 4);
    BCD2 <= int_scanCode(3 DOWNTO 0);
END structural;