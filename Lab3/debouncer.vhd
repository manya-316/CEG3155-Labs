--------------------------------------------------------------------------------
-- debouncer for the car sensor
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY debouncer IS
    PORT (
        i_clock      : IN  STD_LOGIC;
        i_resetBar   : IN  STD_LOGIC;
        i_sampleTick : IN  STD_LOGIC;   -- 100 Hz enable pulse
        i_raw        : IN  STD_LOGIC;   -- noisy push-button
        o_clean      : OUT STD_LOGIC
    );
END debouncer;

ARCHITECTURE structural OF debouncer IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL int_sync1, int_sync2 : STD_LOGIC;
    SIGNAL int_s0, int_s1, int_s2 : STD_LOGIC;
    SIGNAL int_allHigh, int_allLow, int_outEnable : STD_LOGIC;
BEGIN
    -- Two-flip-flop synchronizer (always enabled)
    sync1 : enARdFF_2 PORT MAP (i_resetBar, i_raw,     '1', i_clock, int_sync1, OPEN);
    sync2 : enARdFF_2 PORT MAP (i_resetBar, int_sync1, '1', i_clock, int_sync2, OPEN);

    -- Sample shift register (enabled by the 100 Hz tick)
    samp0 : enARdFF_2 PORT MAP (i_resetBar, int_sync2, i_sampleTick, i_clock, int_s0, OPEN);
    samp1 : enARdFF_2 PORT MAP (i_resetBar, int_s0,    i_sampleTick, i_clock, int_s1, OPEN);
    samp2 : enARdFF_2 PORT MAP (i_resetBar, int_s1,    i_sampleTick, i_clock, int_s2, OPEN);

    -- Stable detection
    int_allHigh   <= int_s0 AND int_s1 AND int_s2;
    int_allLow    <= NOT (int_s0 OR int_s1 OR int_s2);
    int_outEnable <= int_allHigh OR int_allLow;

    -- Output register only updates when the input has been stable
    outFF : enARdFF_2 PORT MAP (i_resetBar, int_allHigh, int_outEnable, i_clock, o_clean, OPEN);
END structural;
