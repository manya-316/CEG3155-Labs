entity multiplier_testbench is
end multiplier_testbench;

architecture test_multiplier of multiplier_testbench is
    component shiftaddmul4bit is
        port (
            clk, reset : in bit;
            a, b : in bit_vector(3 downto 0);
            y : out bit_vector(7 downto 0);
            done : out bit
        );
    end component;
    signal clock, reset, done : bit;
    signal a, b : bit_vector(3 downto 0);
    signal y : bit_vector(7 downto 0);
begin
    clock <= not clock after 5 ns;

    mult : shiftaddmul4bit port map (
        clk => clock, reset => reset,
        a => a, b => b, y => y, done => done
    );

    stimulus : process is
    begin
        reset <= '1'; wait for 20 ns;
        reset <= '0'; wait for 20 ns;

        -- 2 * 4 = 8 (y should be 00001000)
        a <= "0010";
        b <= "0100"; wait until done = '1';

        -- reset mult
        a <= "0000";
        b <= "0000";
        reset <= '1'; wait for 20ns;

        -- 5 * 3 = 15 (y should be 00001111)
        a <= "0101";
        b <= "0011"; wait until done = '1';

        -- reset mult
        a <= "0000";
        b <= "0000";
        reset <= '1'; wait for 20ns;

        -- -3 * 3 = -9 (y should be 11110111)
        a <= "1101";
        b <= "0011"; wait until done = '1';

        -- reset mult
        a <= "0000";
        b <= "0000";
        reset <= '1'; wait for 20ns;

        -- -2 * -5 = 10 (y should be 00001010)
        a <= "1110";
        b <= "1011"; wait until done = '1';

        wait;
    end process stimulus;
end test_multiplier;