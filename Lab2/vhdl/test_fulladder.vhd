entity test_fullrippleadder8bit is
end test_fullrippleadder8bit;

architecture test of test_fullrippleadder8bit is
    component rippleaddsub8bit is
        port (
            a, b : in bit_vector(7 downto 0);
            sub : in bit;
            s : out bit_vector(7 downto 0);
            cout : out bit
        );
    end component;

    signal a, b : bit_vector(7 downto 0);
    signal sub : bit;
    signal s : bit_vector(7 downto 0);
    signal cout : bit;
begin
    adder : rippleaddsub8bit port map(
        a => a,
        b => b,
        sub => sub,
        s => s,
        cout => cout
    );

    stimulus : process is
    begin

        a <= "00000000"; b <= "00000000"; sub <= '0'; wait for 100 ns;
        a <= "00000001"; b <= "00000001"; sub <= '0'; wait for 100 ns;
        a <= "00000010"; b <= "00000001"; sub <= '0'; wait for 100 ns;
        a <= "00001011"; b <= "00000001"; sub <= '0'; wait for 100 ns;
        a <= "11111111"; b <= "11111111"; sub <= '0'; wait for 100 ns;

        a <= "00000000"; b <= "00000000"; sub <= '1'; wait for 100 ns;
        a <= "00000001"; b <= "00000001"; sub <= '1'; wait for 100 ns;
        a <= "00000010"; b <= "00000001"; sub <= '1'; wait for 100 ns;
        a <= "00001011"; b <= "00000001"; sub <= '1'; wait for 100 ns;
        a <= "11111111"; b <= "11111111"; sub <= '1'; wait for 100 ns;

    wait;
    end process stimulus;
end test;

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
