entity rippleadder8bit is
    port (
        a, b : in bit_vector(7 downto 0);
        cin : in bit;
        s : out bit_vector(7 downto 0);
        cout : out bit
    );
end rippleadder8bit;

architecture basic of rippleadder8bit is

    component fulladder1bit is
        port (
            a, b, cin : in bit;
            s, cout : out bit
        );
    end component;
    signal c_chain : bit_vector(8 downto 0);
begin

    c_chain(0) <= cin;
    cout       <= c_chain(8);

    gen_adders : for i in 0 to 7 generate
        fa_inst : fulladder1bit port map (
            a    => a(i),
            b    => b(i),
            cin  => c_chain(i),
            s    => s(i),
            cout => c_chain(i + 1)
        );
    end generate gen_adders;

end basic;