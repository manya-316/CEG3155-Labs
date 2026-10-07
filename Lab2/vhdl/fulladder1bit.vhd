entity fulladder1bit is
    port (
        a, b, cin : in bit;
        s, cout : out bit
    );
end fulladder1bit;

architecture basic of fulladder1bit is
    component or2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    component xor2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    component and2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;

    signal inter_xor : bit;
    signal inter_and1, inter_and2, inter_and3 : bit;
    signal inter_or : bit;
begin

    -- XOR gates for sum output
    u_xor1 : xor2 port map(a => a, b => b, y => inter_xor);
    u_xor2 : xor2 port map(a => inter_xor, b => cin, y => s);

    -- AND gates for carry output
    u_and1 : and2 port map(a => a,b => b,y => inter_and1);
    u_and2 : and2 port map(a => b, b => cin, y => inter_and2);
    u_and3 : and2 port map(a => a, b => cin, y => inter_and3);

    -- OR gates for carry output
    u_or1 : or2 port map(a => inter_and1, b => inter_and2, y => inter_or);
    u_or2 : or2 port map(a => inter_or, b => inter_and3, y => cout);

end basic;