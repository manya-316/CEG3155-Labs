-- mux31.vhd
-- this entity is an 8-bit 3-to-1 multiplexer,
-- where the output is either d0, d1 or d2, depending on s0 and s1.
-- to have 3 inputs, it combines two mux21s

entity mux31 is
    port (
        d0, d1, d2 : in bit_vector(7 downto 0);
        s0, s1 : in bit;
        x : out bit_vector(7 downto 0)
    );
end mux31;

architecture basic of mux31 is
    component mux21 is
        port (
            d0, d1 : in bit_vector(7 downto 0);
            sel : in bit;
            y : out bit_vector(7 downto 0)
        );
    end component;

    signal stage0 : bit_vector(7 downto 0);
begin
    stage0_mux : mux21 port map (
        d0  => d0,
        d1  => d1,
        sel => s0,
        y   => stage0
    );
    stage1_mux : mux21 port map (
        d0 => stage0,
        d1 => d2,
        sel => s1,
        y => x
    );
end basic;