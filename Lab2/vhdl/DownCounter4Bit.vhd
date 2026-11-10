entity DownCounter4Bit is
    port (
        clk, reset : in bit;
        load, dec : in bit;
        d : in bit_vector(3 downto 0);
        zero : out bit
    );
end DownCounter4Bit;

architecture struct of DownCounter4Bit is
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
    component rippleadder4bit is
        port (
            a, b : in bit_vector(3 downto 0);
            cin : in bit;
            s : out bit_vector(3 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;
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
    signal count, minus1, after_dec, d_next : bit_vector(3 downto 0);
    signal or01, or23, any_one : bit;
begin
    sub1 : rippleadder4bit port map (a => count, b => "1111", cin => '0', s => minus1, cout => open, ovf => open);
    gen_bits : for i in 0 to 3 generate
        dec_mux : bitmux21 port map (d0 => count(i), d1 => minus1(i), sel => dec, y => after_dec(i));
        load_mux : bitmux21 port map (d0 => after_dec(i), d1 => d(i), sel => load, y => d_next(i));
        ff : dff port map (clk => clk, clr => reset, pre => '0', d => d_next(i), q => count(i));
    end generate gen_bits;

    o1: or2 port map (a => count(0), b => count(1), y => or01);
    o2: or2 port map (a => count(2), b => count(3), y => or23);
    o3: or2 port map (a => or01, b => or23, y => any_one);
    nz : xor2 port map (a => any_one, b => '1', y => zero);
end struct;