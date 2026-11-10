--testbench for 4-bit multiplier
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
        procedure run(ta, tb : bit_vector(3 downto 0);
                      expected : bit_vector(7 downto 0);
                      msg : string) is
        begin
            a <= ta; b <= tb;                 -- inputs first, so S0 loads them
            reset <= '1'; wait for 20 ns;
            reset <= '0';
            wait until done = '1';
            wait for 1 ns;
            assert y = expected
                report "FAILED: " & msg severity error;
            wait for 40 ns;      
        end procedure;
    begin
        run("0010", "0100", "00001000", " 2 *  4 =   8");
        run("0101", "0011", "00001111", " 5 *  3 =  15");
        run("1101", "0011", "11110111", "-3 *  3 =  -9");
        run("1110", "1011", "00001010", "-2 * -5 =  10");
        run("0111", "0111", "00110001", " 7 *  7 =  49");
        run("1000", "1000", "01000000", "-8 * -8 =  64");
        run("1000", "0111", "11001000", "-8 *  7 = -56");
        run("0000", "1010", "00000000", " 0 * -6 =   0");
        report "Multiplier testbench finished";
        wait;
    end process stimulus;
end test_multiplier;