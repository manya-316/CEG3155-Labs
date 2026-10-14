--8-bit register with load enable and asynchronous reset. Each bit is a D flip-flop whose input comes from a 2-to-1 mux
entity Reg8bit is
    port (
        clk, reset : in bit;
        load : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)
    );
end Reg8bit;

architecture struct of Reg8bit is
    component dff is 
        port (
            clk, clr, pre, d: in bit;
            q: out bit
        );
    end component;
    component bitmux21 is
        port (
            d0, d1, sel: in bit;
            y: out bit
        );
    end component;
    signal q_int : bit_vector(7 downto 0);
    signal d_next : bit_vector(7 downto 0);
begin
    gen_bits : for i in 0 to 7 generate
        mux : bitmux21 port map (d0 => q_int(i), d1 => d(i), sel => load, y => d_next(i));
        ff : dff port map (clk => clk, clr => reset, pre => '0', d => d_next(i), q => q_int(i));
    end generate gen_bits;
    q <= q_int;
end struct;
