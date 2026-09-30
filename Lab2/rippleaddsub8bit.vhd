entity rippleaddsub8bit is
    port (
        a, b : in bit_vector(7 downto 0);
        sub : in bit;
        s : out bit_vector(7 downto 0);
        cout : out bit
    );
end rippleaddsub8bit;

architecture basic of rippleaddsub8bit is
    component rippleadder8bit is
        port (
            a, b : in bit_vector(7 downto 0);
            cin : in bit;
            s : out bit_vector(7 downto 0);
            cout : out bit
        );
    end component;
    component xor2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;

    signal b_xor_sub : bit_vector(7 downto 0);
begin

    b_xor_gen : for i in 0 to 7 generate
        xor_inst : xor2 port map(
            a => b(i),
            b => sub,
            y => b_xor_sub(i)
        );
    end generate b_xor_gen;

    adder : rippleadder8bit port map(
        a => a,
        b => b_xor_sub,
        cin => sub,
        s => s,
        cout => cout
    );

end basic;