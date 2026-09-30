entity test_fulladder is
end test_fulladder;

architecture test of test_fulladder is
    component rippleaddsub8bit is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    signal a_in, b_in, y_out : bit;
begin
    stimulus : process is
    begin

    wait;
    end process stimulus;
end test;