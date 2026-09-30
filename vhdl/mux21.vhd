entity mux21 is
    port (
        d0, d1 : in bit_vector(7 downto 0);
        sel : in bit;
        y : out bit_vector(7 downto 0)
    );
end mux21;

architecture basic of mux21 is
    component mux21_1bit is
        port (
            d0, d1 : in  bit;
            sel : in  bit;
            y : out bit
        );
    end component;
begin
    gen_mux8: for i in 0 to 7 generate
        u_bit: mux21_1bit port map (
            d0  => d0(i),
            d1  => d1(i),
            sel => sel,
            y   => y(i)
        );
    end generate gen_mux8;
end architecture basic;