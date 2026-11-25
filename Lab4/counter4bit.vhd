--------------------------------------------------------------------------------
-- counter4bit : 4-bit synchronous up counter with set (clear) and enable
--
-- Structural: four enARdFF_2 flip-flops and a half-adder incrementer chain.
--
--   i_set    = '1' : counter goes back to its initial value 0000 (synchronous)
--   i_enable = '1' : counter goes up by one
--   otherwise      : counter holds its value
--   i_set has priority over i_enable.
--
-- In the keyboard controller it counts the bits of a PS/2 frame: the FSM
-- holds i_set while idle and pulses i_enable once per received bit.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY counter4bit IS
    PORT (
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_set      : IN  STD_LOGIC;
        i_enable   : IN  STD_LOGIC;
        o_count    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END counter4bit;

ARCHITECTURE structural OF counter4bit IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_q     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_carry : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL int_sum   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_d     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL int_load  : STD_LOGIC;
BEGIN
    int_carry(0) <= '1';

    int_load <= i_enable OR i_set;

    bits : FOR i IN 0 TO 3 GENERATE

        int_sum(i)     <= int_q(i) XOR int_carry(i);
        int_carry(i+1) <= int_q(i) AND int_carry(i);

        int_d(i) <= int_sum(i) AND (NOT i_set);

        bitFF : enARdFF_2
            PORT MAP (
                i_resetBar => i_resetBar,
                i_d        => int_d(i),
                i_enable   => int_load,
                i_clock    => i_clock,
                o_q        => int_q(i),
                o_qBar     => OPEN
            );
    END GENERATE bits;

    o_count <= int_q;
END structural;