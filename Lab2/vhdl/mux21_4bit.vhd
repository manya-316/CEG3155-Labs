-- mux21.vhd
-- this entity is an 8-bit 2-to-1 multiplexer,
-- where the output is either d0 or d1, depending on 'sel'

entity mux21_4bit is
    port (
        d0, d1 : in bit_vector(3 downto 0);
        sel : in bit;
        y : out bit_vector(3 downto 0)
    );
end mux21_4bit;

architecture basic of mux21_4bit is
    component mux21_1bit is
        port (
            d0, d1 : in  bit;
            sel : in  bit;
            y : out bit
        );
    end component;
begin
    gen_mux4: for i in 0 to 3 generate
        u_bit: mux21_1bit port map (
            d0  => d0(i),
            d1  => d1(i),
            sel => sel,
            y   => y(i)
        );
    end generate gen_mux4;
end architecture basic;