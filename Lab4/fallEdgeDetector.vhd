--------------------------------------------------------------------------------
-- fallEdgeDetector : falling-edge detector (produces the FSM input fall_edge)
--
-- Structural: one enARdFF_2 remembers the value i_signal had on the previous
-- global clock edge. A falling edge is "was '1', is now '0'":
--
--      o_fallEdge = previous AND (NOT current)
--
-- o_fallEdge is high for exactly one 10 ns clock period per falling edge of
-- the filtered keyboard clock, so the FSM sees one pulse per PS/2 bit.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fallEdgeDetector IS
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_signal   : IN  STD_LOGIC;
        o_fallEdge : OUT STD_LOGIC
    );
END fallEdgeDetector;

ARCHITECTURE structural OF fallEdgeDetector IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_previous : STD_LOGIC;
BEGIN
    previousFF : enARdFF_2
        PORT MAP (
            i_resetBar => i_resetBar,
            i_d        => i_signal,
            i_enable   => '1',
            i_clock    => i_clock,
            o_q        => int_previous,
            o_qBar     => OPEN
        );

    o_fallEdge <= int_previous AND (NOT i_signal);
END structural;