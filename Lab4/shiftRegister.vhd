--------------------------------------------------------------------------------
-- shiftRegister : N-bit serial-in / parallel-out right-shift register
--
-- Structural: a chain of N enARdFF_2 flip-flops sharing the global clock.
-- On a rising clock edge with i_shift = '1', the serial input enters at the
-- MSB and every bit moves one position toward the LSB:
--
--      i_d -> [N-1] -> [N-2] -> ... -> [1] -> [0] -> (shifted out)
--
-- Used twice in the keyboard controller:
--   * digital filter    : i_shift = '1', samples the keyboard clock every 10 ns
--   * scan-code register: i_shift = o_shift of the FSM. PS/2 sends the LSB
--     first, so once D0..D7 are in, o_q(7 DOWNTO 0) reads as the scan code.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY shiftRegister IS
    GENERIC (N : INTEGER := 8);
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_shift    : IN  STD_LOGIC;
        i_d        : IN  STD_LOGIC;
        o_q        : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );
END shiftRegister;

ARCHITECTURE structural OF shiftRegister IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_q : STD_LOGIC_VECTOR(N DOWNTO 0);
BEGIN
    int_q(N) <= i_d;

    stages : FOR i IN N-1 DOWNTO 0 GENERATE
        stageFF : enARdFF_2
            PORT MAP (
                i_resetBar => i_resetBar,
                i_d        => int_q(i+1),
                i_enable   => i_shift,
                i_clock    => i_clock,
                o_q        => int_q(i),
                o_qBar     => OPEN
            );
    END GENERATE stages;

    o_q <= int_q(N-1 DOWNTO 0);
END structural;