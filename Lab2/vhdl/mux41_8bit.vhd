-- Multiplexer 4-to-1, 8-bit wide
entity mux41_8bit is
    port (
        d0, d1, d2, d3 : in bit_vector(7 downto 0);
        sel : in bit_vector(1 downto 0);
        y : out bit_vector(7 downto 0)
    );
end mux41_8bit;

architecture struct of mux41_8bit is
    component bitmux21 is
        port (
            d0, d1, sel : in bit; 
            y : out bit
            );
    end component;
    signal low_pair, high_pair : bit_vector(7 downto 0);
begin
    gen_bits : for i in 0 to 7 generate
        m_low  : bitmux21 port map(d0 => d0(i), d1 => d1(i), sel => sel(0), y => low_pair(i));
        m_high : bitmux21 port map(d0 => d2(i), d1 => d3(i), sel => sel(0), y => high_pair(i));
        m_out  : bitmux21 port map(d0 => low_pair(i), d1 => high_pair(i), sel => sel(1), y => y(i));
    end generate gen_bits;
end struct;