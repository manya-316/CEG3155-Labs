--------------------------------------------------------------------------------
-- displayController : time-multiplexed driver for two seven-segment digits
-- The Nexys A7 digits share one active-low cathode bus, so only one digit is
-- lit at a time.  A free-running 17-bit refresh counter on the 100 MHz clock
-- uses bit 16 to alternate between digit 0 (right) and digit 1 (left), about
-- 1.3 ms per full scan, which looks steady to the eye.
--   AN(0) -> right digit (BCD2, ones),  AN(1) -> left digit (BCD1, tens)
--   AN(7 downto 2) held high (off).  Anodes are active low.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY displayController IS
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_left     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);   -- BCD1
        i_right    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);   -- BCD2
        o_seg      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        o_an       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END displayController;

ARCHITECTURE structural OF displayController IS
    COMPONENT counterN
        GENERIC (N : INTEGER := 4);
        PORT (i_clock, i_resetBar, i_enable, i_clear : IN STD_LOGIC;
              o_count : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
    END COMPONENT;
    COMPONENT sevenSegDecoder
        PORT (i_bcd : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              o_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
    END COMPONENT;
    COMPONENT mux2to1N
        GENERIC (N : INTEGER := 4);
        PORT (i_a, i_b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
              i_sel : IN STD_LOGIC;
              o_y : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
    END COMPONENT;

    SIGNAL int_refresh : STD_LOGIC_VECTOR(16 DOWNTO 0);
    SIGNAL int_sel     : STD_LOGIC;
    SIGNAL int_segLeft, int_segRight : STD_LOGIC_VECTOR(6 DOWNTO 0);
BEGIN
    refreshCounter : counterN
        GENERIC MAP (N => 17)
        PORT MAP (i_clock, i_resetBar, '1', '0', int_refresh);

    int_sel <= int_refresh(16);

    decLeft  : sevenSegDecoder PORT MAP (i_left,  int_segLeft);
    decRight : sevenSegDecoder PORT MAP (i_right, int_segRight);

    -- sel = 0 -> right digit segments, sel = 1 -> left digit segments
    segMux : mux2to1N
        GENERIC MAP (N => 7)
        PORT MAP (int_segRight, int_segLeft, int_sel, o_seg);

    o_an(0)          <= int_sel;        -- on (low) when sel = 0
    o_an(1)          <= NOT int_sel;    -- on (low) when sel = 1
    o_an(7 DOWNTO 2) <= "111111";
END structural;
