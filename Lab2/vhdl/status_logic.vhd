-- ALU status logic for add/subtract, multiply, divide
entity status_logic is
    port (
        opsel : in bit_vector(1 downto 0);
        addsub_cout, addsub_ovf : in bit;
        a, b : in bit_vector(3 downto 0);
        muxout : in bit_vector(7 downto 0);
        carry_out, zero_out, overflow_out : out bit
    );
end status_logic;

architecture struct of status_logic is
    component and2 is port (a, b : in bit; y : out bit); end component;
    component or2  is port (a, b : in bit; y : out bit); end component;
    component xor2 is port (a, b : in bit; y : out bit); end component;
    component bitmux21 is
        port (
            d0, d1, sel : in bit; 
            y : out bit);
    end component;

    signal not_sel1 : bit;
    signal b01, b23, b_any, b_zero : bit;  -- B = 0000
    signal na2, na1, na0, a32, a10, a_min : bit; -- A = 1000
    signal bb01, bb23, b_all : bit; -- B = 1111
    signal min_by_neg1, div_ovf, mul_div_ovf : bit;
    signal z01, z23, z45, z67, z0123, z4567, z_any : bit;
begin
    --CarryOut: only for add/subtracT
    inv_s1 : xor2 port map(a => opsel(1), b => '1', y => not_sel1);
    c_and  : and2 port map(a => addsub_cout, b => not_sel1, y => carry_out);

    --divide overflow: B = 0000 
    bo1 : or2  port map(a => b(0), b => b(1), y => b01);
    bo2 : or2  port map(a => b(2), b => b(3), y => b23);
    bo3 : or2  port map(a => b01, b => b23, y => b_any);
    bz  : xor2 port map(a => b_any, b => '1', y => b_zero);

    --divide overflow: A = 1000 and B = 1111
    ia2 : xor2 port map(a => a(2), b => '1', y => na2);
    ia1 : xor2 port map(a => a(1), b => '1', y => na1);
    ia0 : xor2 port map(a => a(0), b => '1', y => na0);
    am1 : and2 port map(a => a(3), b => na2, y => a32);
    am2 : and2 port map(a => na1, b => na0, y => a10);
    am3 : and2 port map(a => a32, b => a10, y => a_min);
    ba1 : and2 port map(a => b(0), b => b(1), y => bb01);
    ba2 : and2 port map(a => b(2), b => b(3), y => bb23);
    ba3 : and2 port map(a => bb01, b => bb23, y => b_all);
    mn  : and2 port map(a => a_min, b => b_all, y => min_by_neg1);
    dov : or2  port map(a => b_zero, b => min_by_neg1, y => div_ovf);

    -- OverflowOut: pick by operation
    m1 : bitmux21 port map(d0 => '0', d1 => div_ovf, sel => opsel(0), y => mul_div_ovf);
    m2 : bitmux21 port map(d0 => addsub_ovf, d1 => mul_div_ovf, sel => opsel(1), y => overflow_out);

    --ZeroOut = NOR of all 8 MuxOut bits
    zo1 : or2  port map(a => muxout(0), b => muxout(1), y => z01);
    zo2 : or2  port map(a => muxout(2), b => muxout(3), y => z23);
    zo3 : or2  port map(a => muxout(4), b => muxout(5), y => z45);
    zo4 : or2  port map(a => muxout(6), b => muxout(7), y => z67);
    zo5 : or2  port map(a => z01, b => z23, y => z0123);
    zo6 : or2  port map(a => z45, b => z67, y => z4567);
    zo7 : or2  port map(a => z0123, b => z4567, y => z_any);
    zn  : xor2 port map(a => z_any, b => '1', y => zero_out);
end struct;