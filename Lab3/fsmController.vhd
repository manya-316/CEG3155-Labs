--------------------------------------------------------------------------------
-- fsmController : traffic light Moore FSM (from the pre-lab)
--
-- State assignment (Gray):  S0 = 00  MS green,  SS red
--                           S1 = 01  MS yellow, SS red
--                           S2 = 11  MS red,    SS green
--                           S3 = 10  MS red,    SS yellow
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fsmController IS
    PORT (
        i_clock     : IN  STD_LOGIC;
        i_resetBar  : IN  STD_LOGIC;
        i_enable    : IN  STD_LOGIC;
        i_greenDone : IN  STD_LOGIC;
        i_sscs      : IN  STD_LOGIC;
        i_mtDone    : IN  STD_LOGIC;
        i_stDone    : IN  STD_LOGIC;
        o_MSTL      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        o_SSTL      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        o_y1        : OUT STD_LOGIC;
        o_y0        : OUT STD_LOGIC;
        o_s0, o_s1, o_s2, o_s3 : OUT STD_LOGIC
    );
END fsmController;

ARCHITECTURE structural OF fsmController IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL y1, y0, y1b, y0b : STD_LOGIC;
    SIGNAL T0, T1, T2, T3   : STD_LOGIC;

    SIGNAL int_Y1, int_Y0   : STD_LOGIC;
BEGIN
    T0 <= i_sscs AND i_greenDone;
    T1 <= i_mtDone;
    T2 <= i_greenDone;
    T3 <= i_stDone;

    int_Y1 <= (y1b AND y0 AND T1) OR (y1 AND y0) OR (y1 AND y0b AND (NOT T3));
    int_Y0 <= (y1b AND y0b AND T0) OR (y1b AND y0) OR (y1 AND y0 AND (NOT T2));

    stateFF1 : enARdFF_2 PORT MAP (i_resetBar, int_Y1, i_enable, i_clock, y1, y1b);
    stateFF0 : enARdFF_2 PORT MAP (i_resetBar, int_Y0, i_enable, i_clock, y0, y0b);

    o_MSTL(2) <= y1;
    o_MSTL(1) <= y1b AND y0;
    o_MSTL(0) <= y1b AND y0b;

    o_SSTL(2) <= y1b;
    o_SSTL(1) <= y1 AND y0b;
    o_SSTL(0) <= y1 AND y0;

    o_s0 <= y1b AND y0b;
    o_s1 <= y1b AND y0;
    o_s2 <= y1  AND y0;
    o_s3 <= y1  AND y0b;

    o_y1 <= y1;
    o_y0 <= y0;
END structural;
