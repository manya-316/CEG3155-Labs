entity tb_and2 is
end tb_and2;

architecture test_and2 of tb_and2 is
    component and2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    signal a_in, b_in, y_out : bit;
begin
    and_gate : and2 port map(
        a => a_in,
        b => b_in,
        y => y_out
    );
    stimulus : process is
    begin
        a_in <= '0'; b_in <= '0'; wait for 20 ns;
        a_in <= '0'; b_in <= '1'; wait for 20 ns;
        a_in <= '1'; b_in <= '0'; wait for 20 ns;
        a_in <= '1'; b_in <= '1'; wait for 20 ns;

    wait;
    end process stimulus;
end test_and2;

entity tb_or2 is
end tb_or2;

architecture test_or2 of tb_or2 is
    component or2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    signal a_in, b_in, y_out : bit;
begin
    or_gate : or2 port map(
        a => a_in,
        b => b_in,
        y => y_out
    );
    stimulus : process is
    begin
        a_in <= '0'; b_in <= '0'; wait for 20 ns;
        a_in <= '0'; b_in <= '1'; wait for 20 ns;
        a_in <= '1'; b_in <= '0'; wait for 20 ns;
        a_in <= '1'; b_in <= '1'; wait for 20 ns;

    wait;
    end process stimulus;
end test_or2;

entity tb_LRegister is
end tb_LRegister;

architecture test_LRegister of tb_LRegister is
    component LRegister is
        port (
            clk, reset, shiftL, load : in bit;
            d : in bit_vector(7 downto 0);
            q : out bit_vector(7 downto 0)  
        );
    end component;
    signal clock, reset_reg, LShift, load_reg : bit;
    signal d_inp, q_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    LReg : LRegister port map (
        clk => clock,
        reset => reset_reg,
        shiftL => LShift,
        load => load_reg,
        d => d_inp,
        q => q_out
    );

    stimulus : process is
    begin
        reset_reg <= '1'; wait for 20 ns;
        reset_reg <= '0';
        d_inp <= "00000001"; load_reg <= '1'; wait for 10 ns;
        load_reg <= '0';
        LShift <= '1'; wait for 90 ns;
        LShift <= '0'; wait for 30 ns;
        done <= true;
    

        wait;
    end process stimulus;
end test_LRegister;

entity tb_RRegister is
end tb_RRegister;

architecture test_RRegister of tb_RRegister is
    component RRegister is
        port (
            clk, reset, shiftR, load : in bit;
            d : in bit_vector(7 downto 0);
            q : out bit_vector(7 downto 0)  
        );
    end component;
    signal clock, reset_reg, RShift, load_reg : bit;
    signal d_inp, q_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    RReg : RRegister port map (
        clk => clock,
        reset => reset_reg,
        shiftR => RShift,
        load => load_reg,
        d => d_inp,
        q => q_out
    );

    stimulus : process is
    begin
        reset_reg <= '1'; wait for 20 ns;
        reset_reg <= '0';
        d_inp <= "10000000"; load_reg <= '1'; wait for 10 ns;
        load_reg <= '0';
        RShift <= '1'; wait for 90 ns;
        RShift <= '0'; wait for 30 ns;
        done <= true;
    

        wait;
    end process stimulus;
end test_RRegister;


entity tb_DisplayRegister is
end tb_DisplayRegister;

architecture test_DisplayRegister of tb_DisplayRegister is
    component DisplayRegister is
        port (
            clk, reset, loadD, resetD : in bit;
            d : in bit_vector(7 downto 0);
            q : out bit_vector(7 downto 0)
        );
    end component;
    signal clock, reset_reg, loadD, resetD : bit;
    signal d_inp, q_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    DisplayReg : DisplayRegister port map (
        clk => clock,
        reset => reset_reg,
        loadD => loadD,
        resetD => resetD,
        d => d_inp,
        q => q_out
    );

    stimulus : process is
    begin
        reset_reg <= '1'; wait for 20 ns;
        reset_reg <= '0';
        d_inp <= "10000000"; loadD <= '1'; wait for 10 ns; 
        loadD <= '0';
        d_inp <= "11111111"; wait for 30 ns;                  
        resetD <= '1'; wait for 10 ns;                        
        resetD <= '0'; wait for 20 ns;
        done <= true;

        wait;
    end process stimulus;
end test_DisplayRegister;

entity tb_not is
end tb_not;

architecture test_not of tb_not is
    component not_gate is
        port (
            a : in bit;
            y : out bit
        );
    end component;
    signal a_in, y_out : bit;
begin
    u_not : not_gate port map(
        a => a_in,
        y => y_out
    );
    stimulus : process is
    begin
        a_in <= '0'; wait for 20 ns;
        a_in <= '1'; wait for 20 ns;
        wait;
    end process stimulus;
end test_not;

entity tb_xor2 is
end tb_xor2;

architecture test_xor2 of tb_xor2 is
    component xor2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    signal a_in, b_in, y_out : bit;
begin
    u_xor : xor2 port map(
        a => a_in,
        b => b_in,
        y => y_out
    );
    stimulus : process is
    begin
        a_in <= '0'; b_in <= '0'; wait for 20 ns;
        a_in <= '0'; b_in <= '1'; wait for 20 ns;
        a_in <= '1'; b_in <= '0'; wait for 20 ns;
        a_in <= '1'; b_in <= '1'; wait for 20 ns;
        wait;
    end process stimulus;
end test_xor2;

entity tb_logicOR is
end tb_logicOR;

architecture test_logicOR of tb_logicOR is
    component logicOR is
        port (
            a : in bit_vector(7 downto 0);
            b : in bit_vector(7 downto 0);
            y : out bit_vector(7 downto 0)
        );
    end component;
    signal a_in, b_in, y_out : bit_vector(7 downto 0);
begin
    u_logicOR : logicOR port map(
        a => a_in,
        b => b_in,
        y => y_out
    );
    stimulus : process is
    begin
        a_in <= "00000001"; b_in <= "10000000"; wait for 20 ns;   
        a_in <= "00001000"; b_in <= "00010000"; wait for 20 ns;   
        a_in <= "00010000"; b_in <= "00010000"; wait for 20 ns;   
        a_in <= "00000000"; b_in <= "00000000"; wait for 20 ns;   
        wait;
    end process stimulus;
end test_logicOR;

entity tb_mux21_1bit is
end tb_mux21_1bit;

architecture test_mux21_1bit of tb_mux21_1bit is
    component mux21_1bit is
        port (
            d0, d1 : in bit;
            sel : in bit;
            y : out bit
        );
    end component;
    signal d0_in, d1_in, sel_in, y_out : bit;
begin
    u_mux21_1bit : mux21_1bit port map(
        d0 => d0_in,
        d1 => d1_in,
        sel => sel_in,
        y => y_out
    );
    stimulus : process is
    begin
        d0_in <= '0'; d1_in <= '0'; sel_in <= '0'; wait for 20 ns;
        d0_in <= '0'; d1_in <= '1'; sel_in <= '0'; wait for 20 ns;
        d0_in <= '1'; d1_in <= '0'; sel_in <= '0'; wait for 20 ns;
        d0_in <= '1'; d1_in <= '1'; sel_in <= '0'; wait for 20 ns;
        d0_in <= '0'; d1_in <= '0'; sel_in <= '1'; wait for 20 ns;
        d0_in <= '0'; d1_in <= '1'; sel_in <= '1'; wait for 20 ns;
        d0_in <= '1'; d1_in <= '0'; sel_in <= '1'; wait for 20 ns;
        d0_in <= '1'; d1_in <= '1'; sel_in <= '1'; wait for 20 ns;
        wait;
    end process stimulus;
end test_mux21_1bit;

entity tb_mux21 is
end tb_mux21;

architecture test_mux21 of tb_mux21 is
    component mux21 is
        port (
            d0, d1 : in bit_vector(7 downto 0);
            sel : in bit;
            y : out bit_vector(7 downto 0)
        );
    end component;
    signal d0_in, d1_in, y_out : bit_vector(7 downto 0);
    signal sel_in : bit;
begin
    u_mux21 : mux21 port map(
        d0 => d0_in,
        d1 => d1_in,
        sel => sel_in,
        y => y_out
    );
    stimulus : process is
    begin
        d0_in <= "10100101"; d1_in <= "01011010";
        sel_in <= '0'; wait for 20 ns;
        sel_in <= '1'; wait for 20 ns;
        d1_in <= "11110000"; wait for 20 ns;
        sel_in <= '0'; wait for 20 ns;
        wait;
    end process stimulus;
end test_mux21;

entity tb_mux31 is
end tb_mux31;

architecture test_mux31 of tb_mux31 is
    component mux31 is
        port (
            d0, d1, d2 : in bit_vector(7 downto 0);
            s0, s1 : in bit;
            x : out bit_vector(7 downto 0)
        );
    end component;
    signal d0_in, d1_in, d2_in, y_out : bit_vector(7 downto 0);
    signal s0_in, s1_in : bit;
begin
    u_mux31 : mux31 port map(
        d0 => d0_in,
        d1 => d1_in,
        d2 => d2_in,
        s0 => s0_in,
        s1 => s1_in,
        x => y_out
    );
    stimulus : process is
    begin
        d0_in <= "00000001"; d1_in <= "10000001"; d2_in <= "10000000";
        s1_in <= '0'; s0_in <= '0'; wait for 20 ns; 
        s1_in <= '0'; s0_in <= '1'; wait for 20 ns;  
        s1_in <= '1'; s0_in <= '0'; wait for 20 ns;  
        s1_in <= '1'; s0_in <= '1'; wait for 20 ns;  
        wait;
    end process stimulus;
end test_mux31;

entity tb_dflipflop is
end tb_dflipflop;

architecture test_dflipflop of tb_dflipflop is
    component dflipflop is
        port (
            clk, reset, set, d : in bit;
            q : out bit
        );
    end component;
    signal clock, reset_in, set_in, d_in, q_out : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_ff : dflipflop port map(
        clk => clock,
        reset => reset_in,
        set => set_in,
        d => d_in,
        q => q_out
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0'; wait for 20 ns;
        d_in <= '1'; wait for 20 ns;
        d_in <= '0'; wait for 20 ns;
        set_in <= '1'; wait for 20 ns;
        set_in <= '0'; wait for 20 ns;
        done <= true;

        wait;
    end process stimulus;
end test_dflipflop;

entity tb_clk_div is
end tb_clk_div;

architecture test_clk_div of tb_clk_div is
    component clk_div is
        generic (N : positive := 100_000_000);
        port (
            clk, reset : in bit;
            clk_out : out bit
        );
    
    end component;
    signal clock, reset_in, tick_out : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_clk_div : clk_div generic map (N => 5) port map( 
        clk => clock,
        reset => reset_in,
        clk_out => tick_out
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0'; wait for 500 ns;
        done <= true;

        wait;
    end process stimulus;
end test_clk_div;

entity tb_controlpath is
end tb_controlpath;

architecture test_controlpath of tb_controlpath is
    component controlpath is
        port (
            GClock, GReset, L, R, Tick : in bit;
            LoadL, LoadR, ShiftL, ShiftR : out bit;
            DSel1, DSel0, LoadD, ResetD : out bit
        );
    end component;
    signal clock, reset_in, L_in, R_in, tick_in : bit;
    signal LoadL, LoadR, ShiftL, ShiftR : bit;
    signal DSel1, DSel0, LoadD, ResetD : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    tick_generator : process is
    begin
        wait for 20 ns;   
        while not done loop
            wait for 30 ns; tick_in <= '1';
            wait for 10 ns; tick_in <= '0';
        end loop;
        wait;
    end process tick_generator;
    u_controlpath : controlpath port map(
        GClock => clock,
        GReset => reset_in,
        L => L_in,
        R => R_in,
        Tick => tick_in,
        LoadL => LoadL,
        LoadR => LoadR,
        ShiftL => ShiftL,
        ShiftR => ShiftR,
        DSel1 => DSel1,
        DSel0 => DSel0,
        LoadD => LoadD,
        ResetD => ResetD
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        L_in <= '1'; R_in <= '0'; wait for 120 ns;
        L_in <= '0'; R_in <= '1'; wait for 120 ns;
        L_in <= '1'; R_in <= '1'; wait for 120 ns;
        L_in <= '0'; R_in <= '0'; wait for 120 ns;
        done <= true;

        wait;
    end process stimulus;
end test_controlpath;

entity tb_datapath is
end tb_datapath;

architecture test_datapath of tb_datapath is
    component datapath is
        port (
            Clk, GReset, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : in bit;
            DisplayOut : out bit_vector(7 downto 0)
        );
    end component;
    signal clock, reset_in, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : bit;
    signal DisplayOut : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_datapath : datapath port map(
        Clk => clock,
        GReset => reset_in,
        LoadL => LoadL,
        LoadR => LoadR,
        ShiftL => ShiftL,
        ShiftR => ShiftR,
        DSel1 => DSel1,
        DSel0 => DSel0,
        LoadD => LoadD,
        ResetD => ResetD,
        DisplayOut => DisplayOut
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        LoadL <= '1'; LoadR <= '1'; LoadD <= '1'; wait for 10 ns; 
        LoadL <= '0'; LoadR <= '0'; LoadD <= '0'; 
        LoadD <= '1'; ShiftL <= '1'; wait for 20 ns;
        LoadD <= '0'; ShiftL <= '0'; 
        DSel1 <= '1'; LoadD <= '1'; ShiftR <= '1'; wait for 20 ns;
        DSel1 <= '0'; LoadD <= '0'; ShiftR <= '0';
        DSel0 <= '1'; LoadD <= '1'; ShiftL <= '1'; ShiftR <= '1'; wait for 20 ns;
        DSel0 <= '0'; LoadD <= '0'; ShiftL <= '0'; ShiftR <= '0';
        ResetD <= '1'; wait for 10 ns; 
        ResetD <= '0';
        wait for 20 ns;
        done <= true;

        wait;
    end process stimulus;
end test_datapath;

entity tb_top is
end tb_top;

architecture test_top of tb_top is
    component top is 
        generic (N_div : positive := 100_000_000);
        port (
            CLK100MHZ, SW_RESET, SW_LEFT, SW_RIGHT : in bit;
            LED : out bit_vector(7 downto 0)
        );
    end component;
    signal clock, reset_in, left_in, right_in : bit;
    signal LED_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_top : top generic map (N_div => 4) port map(
        CLK100MHZ => clock,
        SW_RESET => reset_in,
        SW_LEFT => left_in,
        SW_RIGHT => right_in,
        LED => LED_out
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        left_in <= '1'; right_in <= '0'; wait for 400 ns;
        left_in <= '0'; right_in <= '1'; wait for 400 ns;
        left_in <= '1'; right_in <= '1'; wait for 400 ns;
        left_in <= '0'; right_in <= '0'; wait for 400 ns;
        left_in <= '1'; right_in <= '0'; wait for 400 ns;
        done <= true;

        wait;
    end process stimulus;
end test_top;