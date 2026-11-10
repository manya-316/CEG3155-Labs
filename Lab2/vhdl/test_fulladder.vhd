-- Testbench for the 1-bit full adder: all 8 input combinations.
entity test_fulladder is
end test_fulladder;

architecture test of test_fulladder is
    component fulladder1bit is
        port (
            a, b, cin : in bit;
            s, cout : out bit
        );
    end component;

    signal a, b, cin : bit;
    signal sum, cout : bit;
begin
    adder : fulladder1bit port map(
        a => a,
        b => b,
        cin => cin,
        s => sum,
        cout => cout
    );

    stimulus : process is
    begin
        a <= '0'; b <= '0'; cin <= '0'; wait for 100 ns;
        a <= '0'; b <= '1'; cin <= '0'; wait for 100 ns;
        a <= '1'; b <= '0'; cin <= '0'; wait for 100 ns;
        a <= '1'; b <= '1'; cin <= '0'; wait for 100 ns;

        a <= '0'; b <= '0'; cin <= '1'; wait for 100 ns;
        a <= '0'; b <= '1'; cin <= '1'; wait for 100 ns;
        a <= '1'; b <= '0'; cin <= '1'; wait for 100 ns;
        a <= '1'; b <= '1'; cin <= '1'; wait for 100 ns;

        wait;
    end process stimulus;
end test;