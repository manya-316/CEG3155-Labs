entity DisplayRegister is
    port (
        clk, reset, loadD, resetD : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)
    );
end DisplayRegister;

architecture basic of DisplayRegister is
    component mux21_1bit is
        port (
            d0, d1 : in bit;
            sel : in bit;
            y : out bit
        );
    end component;
    component and2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    component not_gate is
        port (
            a : in bit;
            y : out bit
        );
    end component;
    component dflipflop is
        port (
            clk, reset, set, d : in bit;
            q : out bit
        );
    end component;

    signal q_int, next_q, after_load : bit_vector(7 downto 0);
    signal resetD_n : bit;
begin
    u_inv : not_gate port map (
        a => resetD,
        y => resetD_n
    );
    gen_bits : for i in 0 to 7 generate
        u_load : mux21_1bit port map (
            d0 => q_int(i),
            d1 => d(i),
            sel => loadD,
            y => after_load(i)
        );
        u_ff : dflipflop port map (
            clk => clk,
            reset => reset,
            set => '0',
            d => next_q(i),
            q => q_int(i)
        );
        u_clr: and2 port map (
            a => after_load(i),
            b => resetD_n,
            y => next_q(i)
        );
    end generate gen_bits;

    q <= q_int;
end basic;