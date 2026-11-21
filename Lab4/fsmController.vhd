--------------------------------------------------------------------------------
-- fsmController : Keyboard Controller Moore FSM 
--
-- State assignment (Gray):  S0 = 00  Idle
--                           S1 = 01  Shift bit
--                           S2 = 11  Wait for falling edge
--                           S3 = 10  Skip input (for parity/stop bits)
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fsmController IS
    PORT (
        i_clock : IN std_logic;
        i_resetBar : IN std_logic;
        i_counter : IN std_logic_vector(3 downto 0);
        i_falling_edge : in std_logic;
        o_y1, o_y0 : out std_logic;
        o_enable, o_set_counter, o_shift : out std_logic
    );
END fsmController;

ARCHITECTURE structural OF fsmController IS
    COMPONENT enARdFF_2
        PORT (i_resetBar, i_d, i_enable, i_clock : IN STD_LOGIC;
              o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;
    component comparatorN_gte
        GENERIC (N : INTEGER := 4);
        PORT (
            i_a   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            i_b   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            o_gte : OUT STD_LOGIC
        );
    end component;

    SIGNAL y1, y0, y1b, y0b : STD_LOGIC;
    signal f, c9, c11 : std_logic;

    SIGNAL int_Y1, int_Y0   : STD_LOGIC;
BEGIN
    f <= i_falling_edge;

    u_comp9 : comparatorN_gte generic map (N => 4) port map(
        i_a => i_counter,
        i_b => "1001",
        o_gte => c9
    );
    u_comp11 : comparatorN_gte generic map (N => 4) port map(
        i_a => i_counter,
        i_b => "1011",
        o_gte => c11
    );
    
    int_Y1 <= (y1 xor y0) or ((y1 and y0 and (not c11)) and ((not f) or c9));
    int_Y0 <= (y1 xor y0) or (y1b and y0b and f) or ((y1 and y0 and (not c11)) and ((not f) or (not c9)));

    stateFF1 : enARdFF_2 PORT MAP (i_resetBar, int_Y1, '1', i_clock, y1, y1b);
    stateFF0 : enARdFF_2 PORT MAP (i_resetBar, int_Y0, '1', i_clock, y0, y0b);

    o_y1 <= y1;
    o_y0 <= y0;

    o_enable <= y1 xor y0;
    o_set_counter <= y1b and y0b;
    o_shift <= y1b and y0;
END structural;
