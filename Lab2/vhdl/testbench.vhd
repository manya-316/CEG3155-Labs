
entity tb_and2 is
end tb_and2;

architecture test_and2 of tb_and2 is
    component and2 is
        port (a, b : in bit; y : out bit);
    end component;
    signal a_in, b_in, y_out : bit;
begin
    u_and : and2 port map(a => a_in, b => b_in, y => y_out);
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
        port (a, b : in bit; y : out bit);
    end component;
    signal a_in, b_in, y_out : bit;
begin
    u_or : or2 port map(a => a_in, b => b_in, y => y_out);
    stimulus : process is
    begin
        a_in <= '0'; b_in <= '0'; wait for 20 ns;
        a_in <= '0'; b_in <= '1'; wait for 20 ns;
        a_in <= '1'; b_in <= '0'; wait for 20 ns;
        a_in <= '1'; b_in <= '1'; wait for 20 ns;
        wait;
    end process stimulus;
end test_or2;

entity tb_xor2 is
end tb_xor2;

architecture test_xor2 of tb_xor2 is
    component xor2 is
        port (a, b : in bit; y : out bit);
    end component;
    signal a_in, b_in, y_out : bit;
begin
    u_xor : xor2 port map(a => a_in, b => b_in, y => y_out);
    stimulus : process is
    begin
        a_in <= '0'; b_in <= '0'; wait for 20 ns;
        a_in <= '0'; b_in <= '1'; wait for 20 ns;
        a_in <= '1'; b_in <= '0'; wait for 20 ns;
        a_in <= '1'; b_in <= '1'; wait for 20 ns;
        wait;
    end process stimulus;
end test_xor2;


entity tb_dff is
end tb_dff;

architecture test_dff of tb_dff is
    component dff is
        port (clk, clr, pre, d : in bit; q : out bit);
    end component;
    signal clock, clr_in, pre_in, d_in, q_out : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_ff : dff port map(clk => clock, clr => clr_in, pre => pre_in, d => d_in, q => q_out);
    stimulus : process is
    begin
        clr_in <= '1'; wait for 20 ns;        -- held clear
        clr_in <= '0'; wait for 20 ns;
        d_in <= '1'; wait for 20 ns;          -- q follows on the next rising edge
        d_in <= '0'; wait for 20 ns;
        wait for 2 ns;
        pre_in <= '1'; wait for 6 ns;         -- q = 1 immediately (no edge)
        pre_in <= '0'; wait for 12 ns;
        d_in <= '1'; wait for 20 ns;
        clr_in <= '1'; wait for 6 ns;         -- q = 0 immediately (no edge)
        clr_in <= '0'; wait for 14 ns;
        done <= true;
        wait;
    end process stimulus;
end test_dff;

entity tb_bitmux21 is
end tb_bitmux21;

architecture test_bitmux21 of tb_bitmux21 is
    component bitmux21 is
        port (d0, d1, sel : in bit; y : out bit);
    end component;
    signal d0_in, d1_in, sel_in, y_out : bit;
begin
    u_mux : bitmux21 port map(d0 => d0_in, d1 => d1_in, sel => sel_in, y => y_out);
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
end test_bitmux21;

entity tb_rippleadder4bit is
end tb_rippleadder4bit;

architecture test_rippleadder4bit of tb_rippleadder4bit is
    component rippleadder4bit is
        port (a, b : in bit_vector(3 downto 0); cin : in bit;
              s : out bit_vector(3 downto 0); cout : out bit; ovf : out bit);
    end component;
    signal a_in, b_in, s_out : bit_vector(3 downto 0);
    signal cin_in, cout_out, ovf_out : bit;
begin
    u_add : rippleadder4bit port map(a => a_in, b => b_in, cin => cin_in,
        s => s_out, cout => cout_out, ovf => ovf_out);
    stimulus : process is
    begin
        a_in <= "0011"; b_in <= "0010"; cin_in <= '0'; wait for 20 ns;  --  3 +  2 = 5
        a_in <= "0011"; b_in <= "0010"; cin_in <= '1'; wait for 20 ns;  --  3 +  2 + 1 = 6
        a_in <= "0111"; b_in <= "0001"; cin_in <= '0'; wait for 20 ns;  --  7 +  1, overflow
        a_in <= "1111"; b_in <= "0001"; cin_in <= '0'; wait for 20 ns;  -- -1 +  1 = 0, carry
        a_in <= "1100"; b_in <= "1011"; cin_in <= '0'; wait for 20 ns;  -- -4 + -5, overflow
        a_in <= "1110"; b_in <= "1101"; cin_in <= '0'; wait for 20 ns;  -- -2 + -3 = -5
        wait;
    end process stimulus;
end test_rippleadder4bit;

entity tb_rippleaddsub8bit is
end tb_rippleaddsub8bit;

architecture test_rippleaddsub8bit of tb_rippleaddsub8bit is
    component rippleaddsub8bit is
        port (a, b : in bit_vector(7 downto 0); sub : in bit;
              s : out bit_vector(7 downto 0); cout : out bit; ovf : out bit);
    end component;
    signal a_in, b_in, s_out : bit_vector(7 downto 0);
    signal sub_in, cout_out, ovf_out : bit;
begin
    u_addsub : rippleaddsub8bit port map(a => a_in, b => b_in, sub => sub_in,
        s => s_out, cout => cout_out, ovf => ovf_out);
    stimulus : process is
    begin
        a_in <= "00000011"; b_in <= "00000110"; sub_in <= '0'; wait for 20 ns;  --   3 +   6 =   9
        a_in <= "00001001"; b_in <= "00011000"; sub_in <= '1'; wait for 20 ns;  --   9 -  24 = -15
        a_in <= "11110001"; b_in <= "00001111"; sub_in <= '0'; wait for 20 ns;  -- -15 +  15 =   0
        a_in <= "00110001"; b_in <= "00010001"; sub_in <= '1'; wait for 20 ns;  --  49 -  17 =  32
        a_in <= "10000000"; b_in <= "11000000"; sub_in <= '0'; wait for 20 ns;  -- -128 + -64, overflow
        a_in <= "01111111"; b_in <= "11111111"; sub_in <= '1'; wait for 20 ns;  --  127 -  -1, overflow
        wait;
    end process stimulus;
end test_rippleaddsub8bit;

entity tb_Reg4Bit is
end tb_Reg4Bit;

architecture test_Reg4Bit of tb_Reg4Bit is
    component Reg4Bit is
        port (clk, reset : in bit; load : in bit;
              d : in bit_vector(3 downto 0); q : out bit_vector(3 downto 0));
    end component;
    signal clock, reset_in, load_in : bit;
    signal d_inp, q_out : bit_vector(3 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_reg : Reg4Bit port map(clk => clock, reset => reset_in, load => load_in, d => d_inp, q => q_out);
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        d_inp <= "1011"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        d_inp <= "0110"; wait for 30 ns;
        load_in <= '1'; wait for 10 ns;
        load_in <= '0'; wait for 10 ns;
        reset_in <= '1'; wait for 10 ns;
        reset_in <= '0'; wait for 20 ns;
        done <= true;
        wait;
    end process stimulus;
end test_Reg4Bit;

entity tb_Reg8Bit is
end tb_Reg8Bit;

architecture test_Reg8Bit of tb_Reg8Bit is
    component Reg8Bit is
        port (clk, reset : in bit; load : in bit;
              d : in bit_vector(7 downto 0); q : out bit_vector(7 downto 0));
    end component;
    signal clock, reset_in, load_in : bit;
    signal d_inp, q_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_reg : Reg8Bit port map(clk => clock, reset => reset_in, load => load_in, d => d_inp, q => q_out);
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        d_inp <= "11110001"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        d_inp <= "00110001"; wait for 30 ns;
        load_in <= '1'; wait for 10 ns;
        load_in <= '0'; wait for 10 ns;
        reset_in <= '1'; wait for 10 ns;
        reset_in <= '0'; wait for 20 ns;
        done <= true;
        wait;
    end process stimulus;
end test_Reg8Bit;

entity tb_ShiftRegister4Bit is
end tb_ShiftRegister4Bit;

architecture test_ShiftRegister4Bit of tb_ShiftRegister4Bit is
    component ShiftRegister4Bit is
        port (clk, reset, shiftL, shiftR, load : in bit;
              d : in bit_vector(3 downto 0); q : out bit_vector(3 downto 0));
    end component;
    signal clock, reset_in, shiftL_in, shiftR_in, load_in : bit;
    signal d_inp, q_out : bit_vector(3 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_sr : ShiftRegister4Bit port map(clk => clock, reset => reset_in, shiftL => shiftL_in,
        shiftR => shiftR_in, load => load_in, d => d_inp, q => q_out);
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        d_inp <= "1011"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        shiftL_in <= '1'; wait for 20 ns; 
        shiftL_in <= '0';
        d_inp <= "1101"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        shiftR_in <= '1'; wait for 30 ns;
        shiftR_in <= '0'; wait for 20 ns;
        done <= true;
        wait;
    end process stimulus;
end test_ShiftRegister4Bit;

entity tb_ShiftRegister8Bit is
end tb_ShiftRegister8Bit;

architecture test_ShiftRegister8Bit of tb_ShiftRegister8Bit is
    component ShiftRegister8Bit is
        port (clk, reset, shiftL, shiftR, load : in bit;
              d : in bit_vector(7 downto 0); q : out bit_vector(7 downto 0));
    end component;
    signal clock, reset_in, shiftL_in, shiftR_in, load_in : bit;
    signal d_inp, q_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_sr : ShiftRegister8Bit port map(clk => clock, reset => reset_in, shiftL => shiftL_in,
        shiftR => shiftR_in, load => load_in, d => d_inp, q => q_out);
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        d_inp <= "11111011"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        shiftL_in <= '1'; wait for 30 ns;
        shiftL_in <= '0';
        shiftR_in <= '1'; wait for 20 ns;
        shiftR_in <= '0'; wait for 20 ns;
        done <= true;
        wait;
    end process stimulus;
end test_ShiftRegister8Bit;

entity tb_DownCounter4Bit is
end tb_DownCounter4Bit;

architecture test_DownCounter4Bit of tb_DownCounter4Bit is
    component DownCounter4Bit is
        port (clk, reset : in bit; load, dec : in bit;
              d : in bit_vector(3 downto 0); zero : out bit);
    end component;
    signal clock, reset_in, load_in, dec_in, zero_out : bit;
    signal d_inp : bit_vector(3 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_ctr : DownCounter4Bit port map(clk => clock, reset => reset_in, load => load_in,
        dec => dec_in, d => d_inp, zero => zero_out);
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        d_inp <= "0011"; load_in <= '1'; wait for 10 ns;
        load_in <= '0';
        dec_in <= '1'; wait for 30 ns;
        dec_in <= '0'; wait for 20 ns; 
        load_in <= '1'; wait for 10 ns;
        load_in <= '0'; wait for 10 ns;
        done <= true;
        wait;
    end process stimulus;
end test_DownCounter4Bit;

entity tb_multiplier_datapath is
end tb_multiplier_datapath;

architecture test_multiplier_datapath of tb_multiplier_datapath is
    component multiplier_datapath is
        port (
            clk, reset : in bit;
            shiftLA, loadA : in bit;
            shiftRB, loadB : in bit;
            dec, loadCtr : in bit;
            sub : in bit;
            loadP, resetP : in bit;
            a, b : in bit_vector(3 downto 0);
            b_lsb : out bit;
            ctr_zero : out bit;
            y : out bit_vector(7 downto 0)
        );
    end component;
    signal clock, reset_in : bit;
    signal shiftLA, loadA, shiftRB, loadB, dec, loadCtr, sub, loadP, resetP : bit;
    signal a_in, b_in : bit_vector(3 downto 0);
    signal b_lsb, ctr_zero : bit;
    signal y_out : bit_vector(7 downto 0);
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_dp : multiplier_datapath port map(
        clk => clock, reset => reset_in,
        shiftLA => shiftLA, loadA => loadA, shiftRB => shiftRB, loadB => loadB,
        dec => dec, loadCtr => loadCtr, sub => sub, loadP => loadP, resetP => resetP,
        a => a_in, b => b_in, b_lsb => b_lsb, ctr_zero => ctr_zero, y => y_out
    );
    stimulus : process is
    begin
        a_in <= "0011"; b_in <= "1011";
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        resetP <= '1'; loadA <= '1'; loadB <= '1'; loadCtr <= '1'; wait for 10 ns;
        resetP <= '0'; loadA <= '0'; loadB <= '0'; loadCtr <= '0';
        shiftLA <= '1'; shiftRB <= '1'; dec <= '1'; loadP <= '1'; wait for 10 ns;
        wait for 10 ns;
        loadP <= '0'; wait for 10 ns;
        loadP <= '1'; sub <= '1'; wait for 10 ns;
        shiftLA <= '0'; shiftRB <= '0'; dec <= '0'; loadP <= '0'; sub <= '0';
        wait for 30 ns;
        done <= true;
        wait;
    end process stimulus;
end test_multiplier_datapath;

entity tb_multiplier_controlpath is
end tb_multiplier_controlpath;

architecture test_multiplier_controlpath of tb_multiplier_controlpath is
    component multiplier_controlpath is
        port (
            clk, reset : in bit;
            b_lsb, ctr_zero : in bit;
            resetP, loadA, loadB, loadCtr : out bit;
            shiftLA, shiftRB, dec : out bit;
            loadP, sub : out bit;
            done : out bit
        );
    end component;
    signal clock, reset_in, b_lsb, ctr_zero : bit;
    signal resetP, loadA, loadB, loadCtr, shiftLA, shiftRB, dec, loadP, sub, done_out : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_cp : multiplier_controlpath port map(
        clk => clock, reset => reset_in, b_lsb => b_lsb, ctr_zero => ctr_zero,
        resetP => resetP, loadA => loadA, loadB => loadB, loadCtr => loadCtr,
        shiftLA => shiftLA, shiftRB => shiftRB, dec => dec,
        loadP => loadP, sub => sub, done => done_out
    );
    stimulus : process is
    begin
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0'; wait for 10 ns;
        b_lsb <= '1'; ctr_zero <= '0'; wait for 10 ns;
        b_lsb <= '1'; ctr_zero <= '0'; wait for 10 ns;
        b_lsb <= '0'; ctr_zero <= '0'; wait for 10 ns;
        b_lsb <= '1'; ctr_zero <= '1'; wait for 10 ns;
        b_lsb <= '0'; ctr_zero <= '0'; wait for 30 ns;
        done <= true;
        wait;
    end process stimulus;
end test_multiplier_controlpath;

entity tb_divider_datapath is
end tb_divider_datapath;

architecture test_divider_datapath of tb_divider_datapath is
    component divider_datapath is
        port (
            clk, reset : in bit;
            initR, loadT, loadR : in bit;
            loadA, shiftLA : in bit;
            loadB : in bit;
            resetQ, shiftLQ, loadNeg : in bit;
            loadXs : in bit;
            loadCtr, dec : in bit;
            a, b : in bit_vector(3 downto 0);
            ok : out bit;
            ctr_zero : out bit;
            signs_differ : out bit;
            quotient : out bit_vector(3 downto 0);
            remainder : out bit_vector(3 downto 0)
        );
    end component;
    signal clock, reset_in : bit;
    signal initR, loadT, loadR, loadA, shiftLA, loadB, resetQ, shiftLQ, loadNeg, loadXs, loadCtr, dec : bit;
    signal a_in, b_in, q_out, r_out : bit_vector(3 downto 0);
    signal ok, ctr_zero, signs_differ : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_dp : divider_datapath port map(
        clk => clock, reset => reset_in,
        initR => initR, loadT => loadT, loadR => loadR,
        loadA => loadA, shiftLA => shiftLA, loadB => loadB,
        resetQ => resetQ, shiftLQ => shiftLQ, loadNeg => loadNeg,
        loadXs => loadXs, loadCtr => loadCtr, dec => dec,
        a => a_in, b => b_in, ok => ok, ctr_zero => ctr_zero,
        signs_differ => signs_differ, quotient => q_out, remainder => r_out
    );
    stimulus : process is
    begin
        a_in <= "0111"; b_in <= "1110";
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0';
        initR <= '1'; loadA <= '1'; loadB <= '1'; resetQ <= '1'; loadXs <= '1'; loadCtr <= '1';
        wait for 10 ns;
        initR <= '0'; loadA <= '0'; loadB <= '0'; resetQ <= '0'; loadXs <= '0'; loadCtr <= '0';
        shiftLA <= '1'; shiftLQ <= '1'; dec <= '1'; loadR <= '1'; wait for 20 ns;
        loadR <= '0'; loadT <= '1'; wait for 20 ns;
        shiftLA <= '0'; shiftLQ <= '0'; dec <= '0'; loadT <= '0';
        loadNeg <= '1'; wait for 10 ns;
        loadNeg <= '0'; wait for 30 ns;
        done <= true;
        wait;
    end process stimulus;
end test_divider_datapath;

entity tb_divider_controlpath is
end tb_divider_controlpath;

architecture test_divider_controlpath of tb_divider_controlpath is
    component divider_controlpath is
        port (
            clk, reset : in bit;
            ok, ctr_zero, signs_differ : in bit;
            initR, loadA, loadB, resetQ, loadXs, loadCtr : out bit;
            shiftLA, shiftLQ, dec : out bit;
            loadT, loadR : out bit;
            loadNeg : out bit;
            done : out bit
        );
    end component;
    signal clock, reset_in, ok, ctr_zero, signs_differ : bit;
    signal initR, loadA, loadB, resetQ, loadXs, loadCtr, shiftLA, shiftLQ, dec : bit;
    signal loadT, loadR, loadNeg, done_out : bit;
    signal done : boolean := false;
begin
    clock <= not clock after 5 ns when not done else clock;
    u_cp : divider_controlpath port map(
        clk => clock, reset => reset_in, ok => ok, ctr_zero => ctr_zero,
        signs_differ => signs_differ,
        initR => initR, loadA => loadA, loadB => loadB, resetQ => resetQ,
        loadXs => loadXs, loadCtr => loadCtr, shiftLA => shiftLA, shiftLQ => shiftLQ,
        dec => dec, loadT => loadT, loadR => loadR, loadNeg => loadNeg, done => done_out
    );
    stimulus : process is
    begin
        signs_differ <= '1';
        reset_in <= '1'; wait for 20 ns;
        reset_in <= '0'; wait for 10 ns;
        ok <= '0'; ctr_zero <= '0'; wait for 10 ns;
        ok <= '0'; ctr_zero <= '0'; wait for 10 ns;
        ok <= '1'; ctr_zero <= '0'; wait for 10 ns;
        ok <= '1'; ctr_zero <= '1'; wait for 10 ns;
        ok <= '0'; ctr_zero <= '0'; wait for 10 ns;
        wait for 30 ns;
        done <= true;
        wait;
    end process stimulus;
end test_divider_controlpath;

entity tb_mux41_8bit is
end tb_mux41_8bit;

architecture test_mux41_8bit of tb_mux41_8bit is
    component mux41_8bit is
        port (d0, d1, d2, d3 : in bit_vector(7 downto 0);
              sel : in bit_vector(1 downto 0); y : out bit_vector(7 downto 0));
    end component;
    signal d0_in, d1_in, d2_in, d3_in, y_out : bit_vector(7 downto 0);
    signal sel_in : bit_vector(1 downto 0);
begin
    u_mux : mux41_8bit port map(d0 => d0_in, d1 => d1_in, d2 => d2_in, d3 => d3_in,
        sel => sel_in, y => y_out);
    stimulus : process is
    begin
        d0_in <= "00000101"; d1_in <= "00001100"; d2_in <= "11110001"; d3_in <= "00011101";
        sel_in <= "00"; wait for 20 ns;
        sel_in <= "01"; wait for 20 ns;
        sel_in <= "10"; wait for 20 ns;
        sel_in <= "11"; wait for 20 ns;
        wait;
    end process stimulus;
end test_mux41_8bit;

entity tb_status_logic is
end tb_status_logic;

architecture test_status_logic of tb_status_logic is
    component status_logic is
        port (opsel : in bit_vector(1 downto 0);
              addsub_cout, addsub_ovf : in bit;
              a, b : in bit_vector(3 downto 0);
              muxout : in bit_vector(7 downto 0);
              carry_out, zero_out, overflow_out : out bit);
    end component;
    signal opsel_in : bit_vector(1 downto 0);
    signal cout_in, ovf_in, carry_out, zero_out, overflow_out : bit;
    signal a_in, b_in : bit_vector(3 downto 0);
    signal mux_in : bit_vector(7 downto 0);
begin
    u_status : status_logic port map(opsel => opsel_in, addsub_cout => cout_in,
        addsub_ovf => ovf_in, a => a_in, b => b_in, muxout => mux_in,
        carry_out => carry_out, zero_out => zero_out, overflow_out => overflow_out);
    stimulus : process is
    begin
        opsel_in <= "00"; a_in <= "0111"; b_in <= "0001"; cout_in <= '0'; ovf_in <= '1';
        mux_in <= "00001000"; wait for 20 ns;
        opsel_in <= "01"; a_in <= "0011"; b_in <= "0011"; cout_in <= '1'; ovf_in <= '0';
        mux_in <= "00000000"; wait for 20 ns;
        opsel_in <= "10"; a_in <= "0011"; b_in <= "1011"; cout_in <= '1'; ovf_in <= '1';
        mux_in <= "11110001"; wait for 20 ns;
        opsel_in <= "11"; a_in <= "0111"; b_in <= "1110"; cout_in <= '0'; ovf_in <= '0';
        mux_in <= "00011101"; wait for 20 ns;
        opsel_in <= "11"; a_in <= "0101"; b_in <= "0000"; mux_in <= "00000000"; wait for 20 ns;
        opsel_in <= "11"; a_in <= "1000"; b_in <= "1111"; mux_in <= "00001000"; wait for 20 ns;
        wait;
    end process stimulus;
end test_status_logic;

entity tb_display_controller is
end tb_display_controller;

architecture test_display_controller of tb_display_controller is
    component display_controller is
        port (clk100 : in bit;
              d0, d1, d2, d3, d4, d5, d6, d7 : in bit_vector(3 downto 0);
              blank : in bit_vector(7 downto 0);
              seg : out bit_vector(6 downto 0);
              an : out bit_vector(7 downto 0));
    end component;
    signal clock : bit;
    signal seg_out : bit_vector(6 downto 0);
    signal an_out : bit_vector(7 downto 0);
begin
    clock <= not clock after 5 ns; 
    u_disp : display_controller port map(clk100 => clock,
        d0 => "0001", d1 => "1111", d2 => "0000", d3 => "0000",
        d4 => "0010", d5 => "0000", d6 => "1011", d7 => "0011",
        blank => "00101100", seg => seg_out, an => an_out);
end test_display_controller;