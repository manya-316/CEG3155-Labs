--------------------------------------------------------------------------------
-- sevenSegDisplay : multiplexed 7-segment display driver for the Nexys A7-100T
--
-- Shows two hexadecimal digits on the two right-most displays of the board:
--      AN1 = i_digitH (left digit),  AN0 = i_digitL (right digit)
-- The other six displays stay off.
--
-- The eight displays share the segment lines, so only one anode is driven at
-- a time and the driver cycles through the eight positions:
--   1. Refresh divider: gives a one-clock-wide tick every DIV_MAX+1 clocks.
--      With DIV_MAX = 12499: 100 MHz / 12 500 = 8 kHz scan rate, about 1 kHz
--      per digit. It is a clock ENABLE, every flip-flop still uses the global
--      clock. (Behavioural, as permitted for clock dividers.)
--   2. Position counter: counter4bit enabled by the tick, bits 2..0 give the
--      position 0..7 being scanned.
--   3. 2-to-1 multiplexer picks the nibble for the current position and one
--      dec_7seg (course core) converts it to segments.
--   4. Anode decoder: AN0 is on at position 0, AN1 at position 1.
--
-- Segments and anodes are active low on the Nexys A7. dec_7seg already
-- inverts its outputs, so they connect straight to the board pins.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sevenSegDisplay IS
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
END sevenSegDisplay;

ARCHITECTURE structural OF sevenSegDisplay IS
    COMPONENT counter4bit
        PORT (
            i_clock    : IN  STD_LOGIC;
            i_resetBar : IN  STD_LOGIC;
            i_set      : IN  STD_LOGIC;
            i_enable   : IN  STD_LOGIC;
            o_count    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT dec_7seg
        PORT (i_hexDigit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              o_segment_a, o_segment_b, o_segment_c, o_segment_d, o_segment_e,
              o_segment_f, o_segment_g : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_divCount : INTEGER RANGE 0 TO DIV_MAX;
    SIGNAL int_tick     : STD_LOGIC;
    SIGNAL int_position : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_hex      : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    -- 1. refresh divider (clock-enable generator)
    refreshDivider : PROCESS (i_resetBar, i_clock)
    BEGIN
        IF (i_resetBar = '0') THEN
            int_divCount <= 0;
            int_tick     <= '0';
        ELSIF rising_edge(i_clock) THEN
            IF (int_divCount = DIV_MAX) THEN
                int_divCount <= 0;
                int_tick     <= '1';
            ELSE
                int_divCount <= int_divCount + 1;
                int_tick     <= '0';
            END IF;
        END IF;
    END PROCESS refreshDivider;

    -- 2. position counter, advances once per tick and wraps around on its own
    positionCounter : counter4bit
        PORT MAP (
            i_clock    => i_clock,
            i_resetBar => i_resetBar,
            i_set      => '0',
            i_enable   => int_tick,
            o_count    => int_position
        );

    -- 3. 2-to-1 multiplexer: even positions take the right digit, odd the left
    muxBits : FOR i IN 0 TO 3 GENERATE
        int_hex(i) <= (i_digitL(i) AND (NOT int_position(0))) OR
                      (i_digitH(i) AND int_position(0));
    END GENERATE muxBits;

    hexDecoder : dec_7seg
        PORT MAP (
            i_hexDigit  => int_hex,
            o_segment_a => o_seg(0),
            o_segment_b => o_seg(1),
            o_segment_c => o_seg(2),
            o_segment_d => o_seg(3),
            o_segment_e => o_seg(4),
            o_segment_f => o_seg(5),
            o_segment_g => o_seg(6)
        );

    -- 4. anode decoder (active low): on only at position 000 and 001
    o_an(0) <= int_position(2) OR int_position(1) OR int_position(0);
    o_an(1) <= int_position(2) OR int_position(1) OR (NOT int_position(0));
    o_an(7 DOWNTO 2) <= "111111";

    -- decimal point not used
    o_dp <= '1';
END structural;