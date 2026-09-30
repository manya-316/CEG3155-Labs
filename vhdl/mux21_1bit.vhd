entity mux21_1bit is
    port (
        d0, d1 : in bit;
        sel : in bit;
        y : out bit
    );
end mux21_1bit;

architecture basic of mux21_1bit is
    component and2
        port (a, b : in bit; y : out bit);
    end component;
    component or2
        port (a, b : in bit; y : out bit);
    end component;
    component not_gate
        port (a : in bit; y : out bit);
    end component;

    signal sel_n, term0, term1 : bit;
begin
    u_inv : not_gate port map (a => sel, y => sel_n);
    u_and0: and2 port map (a => d0, b => sel_n, y => term0);
    u_and1: and2 port map (a => d1, b => sel,   y => term1);
    u_or  : or2  port map (a => term0, b => term1, y => y);
end basic;