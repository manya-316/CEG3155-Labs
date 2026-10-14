-- Pre-lab testbench: adds and subtracts signed 4-bit pairs.
entity test_rippleaddsub4bit is
end test_rippleaddsub4bit;

architecture test of test_rippleaddsub4bit is
    component rippleaddsub4bit is
        port (
            a, b : in bit_vector(3 downto 0);
            sub : in bit;
            s : out bit_vector(3 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;

    signal a, b : bit_vector(3 downto 0);
    signal sub : bit;
    signal s : bit_vector(3 downto 0);
    signal cout, ovf : bit;
begin
    uut : rippleaddsub4bit port map(
        a => a, b => b, sub => sub, s => s, cout => cout, ovf => ovf
    );

    stimulus : process is
        procedure check(ta, tb : bit_vector(3 downto 0); tsub : bit;
                        es : bit_vector(3 downto 0); ec, ev : bit;
                        msg : string) is
        begin
            a <= ta; b <= tb; sub <= tsub;
            wait for 100 ns;
            assert s = es and cout = ec and ovf = ev
                report "FAILED: " & msg severity error;
        end procedure;
    begin
        check("0000", "0000", '0', "0000", '0', '0', " 0 +  0 =  0");
        check("0011", "0010", '0', "0101", '0', '0', " 3 +  2 =  5");
        check("0101", "1101", '0', "0010", '1', '0', " 5 + -3 =  2");
        check("1100", "1110", '0', "1010", '1', '0', "-4 + -2 = -6");
        check("0111", "0001", '0', "1000", '0', '1', " 7 +  1 overflow");
        check("1100", "1011", '0', "0111", '1', '1', "-4 + -5 overflow");

        check("0101", "0011", '1', "0010", '1', '0', " 5 -  3 =  2");
        check("0010", "0110", '1', "1100", '0', '0', " 2 -  6 = -4");
        check("1101", "1110", '1', "1111", '0', '0', "-3 - -2 = -1");
        check("0000", "0000", '1', "0000", '1', '0', " 0 -  0 =  0");
        check("1000", "0001", '1', "0111", '1', '1', "-8 -  1 overflow");
        check("0111", "1111", '1', "1000", '0', '1', " 7 - -1 overflow");

        report "Testbench finished";
        wait;
    end process stimulus;
end test;