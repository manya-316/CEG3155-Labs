entity bitmux21 is
    port (
        d0, d1, sel: in bit;
        y: out bit
    );
end bitmux21;

architecture struct of bitmux21 is
    component and2 is
        port (
            a, b: in bit;
            y: out bit
        );
    end component;

    component or2 is
        port (
            a, b: in bit;
            y: out bit
        );
    end component;

    component xor2 is
        port (
            a, b: in bit;
            y: out bit
        );
    end component;
    signal nsel, t0, t1: bit;
begin
    inv : xor2 port map (a => sel, b => '1', y => nsel);
    and0 : and2 port map (a => d0, b => nsel, y => t0);
    and1 : and2 port map (a => d1, b => sel, y => t1);
    orr : or2 port map (a => t0, b => t1, y => y);
end struct;
