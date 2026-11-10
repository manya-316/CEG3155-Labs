-- divider datapath for 4-bit divider
entity divider_datapath is
    port (
        clk, reset : in bit;
        initR, loadT, loadR : in bit;
        loadA, shiftLA : in bit;
        loadB : in bit;
        resetQ, shiftLQ, loadNeg : in bit;
        loadXs : in bit;
        loadCtr, dec : in bit;
        a, b : in bit_vector(3 downto 0);
        ok : out bit;
        ctr_zero : out bit;
        signs_differ : out bit;
        quotient : out bit_vector(3 downto 0);
        remainder : out bit_vector(3 downto 0)
    );
end divider_datapath;

architecture struct of divider_datapath is
    component ShiftRegister4Bit is
        port (
            clk, reset : in bit; 
            shiftL, shiftR, load : in bit;
            d : in bit_vector(3 downto 0); 
            q : out bit_vector(3 downto 0)
            );
    end component;
    component Reg4Bit is
        port (
            clk, reset : in bit; 
            load : in bit;
            d : in bit_vector(3 downto 0); 
            q : out bit_vector(3 downto 0)
            );
    end component;
    component rippleaddsub4bit is
        port (
            a, b : in bit_vector(3 downto 0); 
            sub : in bit;
            s : out bit_vector(3 downto 0); 
            cout : out bit; 
            ovf : out bit
            );
    end component;
    component DownCounter4Bit is
        port (
            clk, reset : in bit; 
            load, dec : in bit;
            d : in bit_vector(3 downto 0); 
            zero : out bit);
    end component;
    component dff is
        port (
            clk, clr, pre, d : in bit; 
            q : out bit
            );
    end component;
    component bitmux21 is
        port (
            d0, d1, sel : in bit; 
            y : out bit
            );
    end component;
    component and2 is 
        port (
            a, b : in bit; 
            y : out bit
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

    signal opa, opb, rem_q, quo_q : bit_vector(3 downto 0);
    signal r_shift, t, neg_q : bit_vector(3 downto 0);
    signal rem_mux1, rem_d, quo_shift, quo_d : bit_vector(3 downto 0);
    signal sext : bit_vector(3 downto 0);
    signal xs, xs_d, sub, xs_xor_b3, v : bit;
    signal ts, not_ts, t01, t23, t_any, zt, d01, d_any, zd, zt_zd, ok1, ok_int : bit;
    signal rem_load1, rem_load, quo_load, quo_reset : bit;
begin
    regB : Reg4Bit port map(clk => clk, reset => reset, load => loadB, d => b, q => opb);

    regA : ShiftRegister4Bit port map(clk => clk, reset => reset, shiftL => shiftLA,
        shiftR => '0', load => loadA, d => a, q => opa);

    xs_mux : bitmux21 port map(d0 => xs, d1 => a(3), sel => loadXs, y => xs_d);
    xs_ff  : dff port map(clk => clk, clr => reset, pre => '0', d => xs_d, q => xs);

    r_shift <= rem_q(2 downto 0) & opa(3);

    x1 : xor2 port map(a => xs, b => opb(3), y => xs_xor_b3);
    x2 : xor2 port map(a => xs_xor_b3, b => '1', y => sub);
    signs_differ <= xs_xor_b3;

    addsub1 : rippleaddsub4bit port map(a => r_shift, b => opb, sub => sub,
        s => t, cout => open, ovf => v);

    x3 : xor2 port map(a => t(3), b => v, y => ts);
    x4 : xor2 port map(a => ts, b => '1', y => not_ts);
    o1 : or2  port map(a => t(0), b => t(1), y => t01);
    o2 : or2  port map(a => t(2), b => t(3), y => t23);
    o3 : or2  port map(a => t01, b => t23, y => t_any);
    x5 : xor2 port map(a => t_any, b => '1', y => zt);
    o4 : or2  port map(a => opa(0), b => opa(1), y => d01);
    o5 : or2  port map(a => d01, b => opa(2), y => d_any);
    x6 : xor2 port map(a => d_any, b => '1', y => zd);
    a1 : and2 port map(a => zt, b => zd, y => zt_zd);
    o6 : or2  port map(a => ts, b => zt_zd, y => ok1);
    -- OK = Ts'  if Xs = 0,   OK = Ts + Zt.Zd  if Xs = 1
    ok_mux : bitmux21 port map(d0 => not_ts, d1 => ok1, sel => xs, y => ok_int);
    ok <= ok_int;

    sext <= a(3) & a(3) & a(3) & a(3);
    gen_rem : for i in 0 to 3 generate
        m1 : bitmux21 port map(d0 => r_shift(i), d1 => t(i), sel => loadT, y => rem_mux1(i));
        m2 : bitmux21 port map(d0 => rem_mux1(i), d1 => sext(i), sel => initR, y => rem_d(i));
    end generate gen_rem;
    o7 : or2 port map(a => initR, b => loadT, y => rem_load1);
    o8 : or2 port map(a => rem_load1, b => loadR, y => rem_load);
    regR : Reg4Bit port map(clk => clk, reset => reset, load => rem_load, d => rem_d, q => rem_q);

    addsub2 : rippleaddsub4bit port map(a => "0000", b => quo_q, sub => '1',
        s => neg_q, cout => open, ovf => open);
    quo_shift <= quo_q(2 downto 0) & ok_int;
    gen_quo : for i in 0 to 3 generate
        m3 : bitmux21 port map(d0 => quo_shift(i), d1 => neg_q(i), sel => loadNeg, y => quo_d(i));
    end generate gen_quo;
    o9  : or2 port map(a => shiftLQ, b => loadNeg, y => quo_load);
    o10 : or2 port map(a => reset, b => resetQ, y => quo_reset);
    regQ : Reg4Bit port map(clk => clk, reset => quo_reset, load => quo_load, d => quo_d, q => quo_q);

    ctr : DownCounter4Bit port map(clk => clk, reset => reset, load => loadCtr,
        dec => dec, d => "0011", zero => ctr_zero);

    quotient  <= quo_q;
    remainder <= rem_q;
end struct;