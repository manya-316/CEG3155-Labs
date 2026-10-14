entity divider_testbench is
end divider_testbench;

architecture test_divider of divider_testbench is
    component divider4bit is
        port (
            clk, reset : in bit;
            a, b : in bit_vector(3 downto 0);
            quotient : out bit_vector(3 downto 0);
            remainder : out bit_vector(3 downto 0);
            done : out bit
        );
    end component;
    signal clock, reset, done : bit;
    signal a, b, quotient, remainder : bit_vector(3 downto 0);
begin
    clock <= not clock after 5 ns; 

    div : divider4bit port map (
        clk => clock, reset => reset,
        a => a, b => b,
        quotient => quotient, remainder => remainder, done => done
    );

    stimulus : process is
        procedure run(ta, tb : bit_vector(3 downto 0);
                      eq, er : bit_vector(3 downto 0);
                      msg : string) is
        begin
            a <= ta; b <= tb;                 -- inputs first, so S0 loads them
            reset <= '1'; wait for 20 ns;
            reset <= '0';
            wait until done = '1';
            wait for 1 ns;
            assert quotient = eq and remainder = er
                report "FAILED: " & msg severity error;
            wait for 40 ns; 
        end procedure;
    begin
        --   A       B       Q       R
        run("0111", "0010", "0011", "0001", " 7 /  2 =  3 r  1");
        run("0111", "1110", "1101", "0001", " 7 / -2 = -3 r  1");
        run("1001", "0010", "1101", "1111", "-7 /  2 = -3 r -1");
        run("1001", "1110", "0011", "1111", "-7 / -2 =  3 r -1");
        run("1100", "0010", "1110", "0000", "-4 /  2 = -2 r  0");
        run("0110", "0011", "0010", "0000", " 6 /  3 =  2 r  0");
        run("1000", "0001", "1000", "0000", "-8 /  1 = -8 r  0");
        run("0010", "0101", "0000", "0010", " 2 /  5 =  0 r  2");
        run("0000", "1101", "0000", "0000", " 0 / -3 =  0 r  0");
        report "Divider testbench finished";
        wait;
    end process stimulus;
end test_divider;