-- control path for 4-bit divider
entity divider_controlpath is
    port (
        clk, reset : in bit;
        ok, ctr_zero, signs_differ : in bit;   -- status from the datapath
        initR, loadA, loadB, resetQ, loadXs, loadCtr : out bit;
        shiftLA, shiftLQ, dec : out bit;
        loadT, loadR : out bit;
        loadNeg : out bit;
        done : out bit
    );
end divider_controlpath;

architecture struct of divider_controlpath is
    component dff is
        port (clk, clr, pre, d : in bit; q : out bit);
    end component;
    component and2 is port (a, b : in bit; y : out bit); end component;
    component or2  is port (a, b : in bit; y : out bit); end component;
    component xor2 is port (a, b : in bit; y : out bit); end component;

    signal s0, s1, s2, s3 : bit;
    signal d1, d2, d3 : bit;
    signal not_z, s1_notz, not_ok : bit;
begin
    inv_z : xor2 port map(a => ctr_zero, b => '1', y => not_z);
    g1 : and2 port map(a => s1, b => not_z, y => s1_notz);
    g2 : or2  port map(a => s0, b => s1_notz, y => d1);
    g3 : and2 port map(a => s1, b => ctr_zero, y => d2);
    g4 : or2  port map(a => s2, b => s3, y => d3);

    ff0 : dff port map(clk => clk, clr => '0',   pre => reset, d => '0', q => s0);
    ff1 : dff port map(clk => clk, clr => reset, pre => '0',   d => d1,  q => s1);
    ff2 : dff port map(clk => clk, clr => reset, pre => '0',   d => d2,  q => s2);
    ff3 : dff port map(clk => clk, clr => reset, pre => '0',   d => d3,  q => s3);

    initR   <= s0;
    loadA   <= s0;
    loadB   <= s0;
    resetQ  <= s0;
    loadXs  <= s0;
    loadCtr <= s0;

    shiftLA <= s1;
    shiftLQ <= s1;
    dec     <= s1;
    inv_ok : xor2 port map(a => ok, b => '1', y => not_ok);
    g5 : and2 port map(a => s1, b => ok, y => loadT);
    g6 : and2 port map(a => s1, b => not_ok, y => loadR);

    g7 : and2 port map(a => s2, b => signs_differ, y => loadNeg);

    done <= s3;
end struct;