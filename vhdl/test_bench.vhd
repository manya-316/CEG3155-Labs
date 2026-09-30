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
