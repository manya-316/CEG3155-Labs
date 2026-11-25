--------------------------------------------------------------------------------
-- fsmController : Keyboard Controller Moore FSM
--
-- Decides, for each bit of an 11-bit PS/2 frame, whether to shift it into the
-- scan-code register (start bit and D0..D7) or to skip it (parity and stop).
--
-- Inputs : i_falling_edge  one-clock pulse per falling edge of the filtered
--                          keyboard clock (from fallEdgeDetector)
--          i_counter       number of bits received so far (from counter4bit)
-- Outputs: o_set_counter   put the counter back to 0       (state S0)
--          o_enable        add one to the counter          (states S1 and S3)
--          o_shift         shift KeyboardInfo in           (state S1)
--          o_y1, o_y0      present state, for simulation and debugging
--
-- State assignment (Gray):  S0 = 00  Idle
--                           S1 = 01  Shift bit
--                           S2 = 11  Wait for falling edge
--                           S3 = 10  Skip input (for parity/stop bits)
--
-- Transitions (F = falling edge, C9 = counter >= 9, C11 = counter >= 11):
--   S0 -> S1  when F              start bit arrives
--   S1 -> S2  always
--   S2 -> S1  when F and not C9   start or data bit: shift it
--   S2 -> S3  when F and C9       parity or stop bit: skip it
--   S2 -> S0  when C11            all 11 bits received
--   S3 -> S2  always
--
-- Next-state equations (from the transition table):
--   Y1 = (y1 xor y0) + y1.y0.C11'.(F' + C9)
--   Y0 = (y1 xor y0) + y1'.y0'.F + y1.y0.C11'.(F' + C9')
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fsmController IS
    PORT (
        i_clock        : IN  STD_LOGIC;
        i_resetBar     : IN  STD_LOGIC;
        i_counter      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_falling_edge : IN  STD_LOGIC;
        o_y1, o_y0     : OUT STD_LOGIC;
        o_enable, o_set_counter, o_shift : OUT STD_LOGIC
    );
END fsmController;

ARCHITECTURE structural OF fsmController IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT comparatorN_gte
        GENERIC (N : INTEGER := 4);
        PORT (
            i_a   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            i_b   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            o_gte : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL y1, y0, y1b, y0b : STD_LOGIC;   -- present state and its complement
    SIGNAL f, c9, c11       : STD_LOGIC;   -- FSM inputs F, C9 and C11
    SIGNAL int_Y1, int_Y0   : STD_LOGIC;   -- next state
BEGIN
    f <= i_falling_edge;

    -- C9: the start bit and the 8 data bits have all been shifted in
    u_comp9 : comparatorN_gte
        GENERIC MAP (N => 4)
        PORT MAP (
            i_a   => i_counter,
            i_b   => "1001",
            o_gte => c9
        );

    -- C11: all 11 bits of the frame have been received
    u_comp11 : comparatorN_gte
        GENERIC MAP (N => 4)
        PORT MAP (
            i_a   => i_counter,
            i_b   => "1011",
            o_gte => c11
        );

    -- next-state logic
    int_Y1 <= (y1 XOR y0) OR ((y1 AND y0 AND (NOT c11)) AND ((NOT f) OR c9));
    int_Y0 <= (y1 XOR y0) OR (y1b AND y0b AND f) OR ((y1 AND y0 AND (NOT c11)) AND ((NOT f) OR (NOT c9)));

    -- state register
    stateFF1 : enARdFF_2
        PORT MAP (
            i_resetBar => i_resetBar,
            i_d        => int_Y1,
            i_enable   => '1',
            i_clock    => i_clock,
            o_q        => y1,
            o_qBar     => y1b
        );

    stateFF0 : enARdFF_2
        PORT MAP (
            i_resetBar => i_resetBar,
            i_d        => int_Y0,
            i_enable   => '1',
            i_clock    => i_clock,
            o_q        => y0,
            o_qBar     => y0b
        );

    o_y1 <= y1;
    o_y0 <= y0;

    -- Moore outputs: they depend on the present state only
    o_enable      <= y1 XOR y0;
    o_set_counter <= y1b AND y0b;
    o_shift       <= y1b AND y0;
END structural;