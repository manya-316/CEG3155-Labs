LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY questionIIb IS
    PORT (i_clock  : IN  STD_LOGIC;
          i_resetb : IN  STD_LOGIC;
          i_r      : IN  STD_LOGIC_VECTOR(1 TO 3);
          o_g      : OUT STD_LOGIC_VECTOR(1 TO 3));
END questionIIb;

ARCHITECTURE Behavior OF questionIIb IS
    TYPE stateType IS (Idle, gnt1, gnt2, gnt3);
    SIGNAL int_state : stateType;
BEGIN
    PROCESS (i_resetb, i_clock)
    BEGIN
        IF (i_resetb = '0') THEN
            int_state <= Idle;
        ELSIF (i_clock'EVENT AND i_clock = '1') THEN
            CASE int_state IS
                WHEN Idle =>
                    IF i_r(1) = '1' THEN
                        int_state <= gnt1;
                    ELSIF i_r(2) = '1' THEN
                        int_state <= gnt2;
                    ELSIF i_r(3) = '1' THEN
                        int_state <= gnt3;
                    ELSE
                        int_state <= Idle;
                    END IF;
                WHEN gnt1 =>
                    IF i_r(1) = '1' THEN
                        int_state <= gnt1;
                    ELSIF i_r(2) = '1' THEN
                        int_state <= gnt2;
                    ELSIF i_r(3) = '1' THEN
                        int_state <= gnt3;
                    ELSE
                        int_state <= Idle;
                    END IF;
                WHEN gnt2 =>
                    IF i_r(2) = '1' THEN
                        int_state <= gnt2;
                    ELSIF i_r(3) = '1' THEN
                        int_state <= gnt3;
                    ELSE
                        int_state <= Idle;
                    END IF;
                WHEN gnt3 =>
                    IF i_r(3) = '1' THEN
                        int_state <= gnt3;
                    ELSE
                        int_state <= Idle;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    o_g(1) <= '1' WHEN int_state = gnt1 ELSE '0';
    o_g(2) <= '1' WHEN int_state = gnt2 ELSE '0';
    o_g(3) <= '1' WHEN int_state = gnt3 ELSE '0';
END Behavior;