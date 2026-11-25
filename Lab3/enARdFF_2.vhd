--------------------------------------------------------------------------------
-- enARdFF_2 : D flip-flop with enable and asynchronous active-low reset
-- Atomic building block for every register, counter and the FSM state bits.
-- All flip-flops in the design run on the 100 MHz clock; slower behaviour is
-- obtained with the enable input (clock-enable style, per Section 5.5).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY enARdFF_2 IS
    PORT (
        i_resetBar : IN  STD_LOGIC;
        i_d        : IN  STD_LOGIC;
        i_enable   : IN  STD_LOGIC;
        i_clock    : IN  STD_LOGIC;
        o_q        : OUT STD_LOGIC;
        o_qBar     : OUT STD_LOGIC
    );
END enARdFF_2;

ARCHITECTURE rtl OF enARdFF_2 IS
    SIGNAL int_q : STD_LOGIC;
BEGIN
    oneBitRegister : PROCESS (i_resetBar, i_clock)
    BEGIN
        IF (i_resetBar = '0') THEN
            int_q <= '0';
        ELSIF rising_edge(i_clock) THEN
            IF (i_enable = '1') THEN
                int_q <= i_d;
            END IF;
        END IF;
    END PROCESS oneBitRegister;

    o_q    <= int_q;
    o_qBar <= NOT int_q;
END rtl;
