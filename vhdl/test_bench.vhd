entity test_bench is
end test_bench;

architecture test_and2 of test_bench is
    component and2 is
        port (
            a, b : in bit;
            y : out bit;
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
        a_in <= 0; b_in <= 0; wait for 20ns;
        a_in <= 0; b_in <= 1; wait for 20ns;
        a_in <= 1; b_in <= 0; wait for 20ns;
        a_in <= 1; b_in <= 1; wait for 20ns;

    wait;
    end process stimulus;
end test_and2;

architecture test_or2 of test_bench is
    component or2 is
        port (
            a, b : in bit;
            y : out bit;
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
        a_in <= 0; b_in <= 0; wait for 20ns;
        a_in <= 0; b_in <= 1; wait for 20ns;
        a_in <= 1; b_in <= 0; wait for 20ns;
        a_in <= 1; b_in <= 1; wait for 20ns;

    wait;
    end process stimulus;
end test_or2;

architecture test_LRegister of test_bench is
    component LRegister is
        port (
            clk : in bit;
            shiftL : in bit;
            load : in bit;
            d0, d1, d2, d3, d4, d5, d6, d7 : in bit;
            q0, q1, q2, q3, q4, q5, q6, q7 : out bit
        );
    end component;
    signal LShift, clock, load_reg : bit;
    signal d_inp : bit_vector(7 downto 0);
begin
    LReg : LRegister port map(
        clk => clock,
        shiftL => LShift,
        load => load_reg,
        d1 => d_inp(1),
        d0 => d_inp(0),
        d2 => d_inp(2),
        d3 => d_inp(3),
        d4 => d_inp(4),
        d5 => d_inp(5),
        d6 => d_inp(6),
        d7 => d_inp(7)
    );

    stimulus : process is
    begin
    

    wait;
    end process stimulus;
end test_LRegister;