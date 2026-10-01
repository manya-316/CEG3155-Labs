-- controlpath.vhd
-- This is the control path of the system. 
-- It manages the state of the system and generates control signals,
-- which the datapath uses to route data and update state.

entity controlpath is
    port (
        GClock, GReset, L, R, Tick : in bit;
        LoadL, LoadR, ShiftL, ShiftR : out bit;
        DSel1, DSel0, LoadD, ResetD : out bit
    );
end controlpath;

architecture basic of controlpath is 
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
    component or2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    component mux21_1bit is
        port (
            d0, d1 : in bit;
            sel : in bit;
            y : out bit
        );
    end component;
    signal L_n, R_n, d0, d1, d2, d3, d4, e0, e1, e2, e3, e4, s0, s1, s2, s3, s4 : bit;
    signal s1_or_s2, s1_or_s3, s0_or_s1, s2_or_s3, any_load : bit;

begin
    u_notL : not_gate port map (
        a => L,
        y => L_n
    );
    u_notR : not_gate port map (
        a => R,
        y => R_n
    );
    d0 <= '0';
    u_d1 : and2 port map (
        a => L,
        b => R,
        y => d1
    );
    u_d2 : and2 port map (
        a => L,
        b => R_n,
        y => d2
    );
    u_d3 : and2 port map (
        a => L_n,
        b => R,
        y => d3
    );
    u_d4 : and2 port map (
        a => L_n,
        b => R_n,
        y => d4
    );
    u_e0: mux21_1bit port map (
        d0 => s0,
        d1 => d0,
        sel => Tick,
        y => e0
    );
    u_e1: mux21_1bit port map (
        d0 => s1,
        d1 => d1,
        sel => Tick,
        y => e1
    );
    u_e2: mux21_1bit port map (
        d0 => s2,
        d1 => d2,
        sel => Tick,
        y => e2
    );
    u_e3: mux21_1bit port map (
        d0 => s3,
        d1 => d3,
        sel => Tick,
        y => e3
    );
    u_e4: mux21_1bit port map (
        d0 => s4,
        d1 => d4,
        sel => Tick,
        y => e4
    );
    u_s0 : dflipflop port map (
        clk => GClock,
        reset => '0',
        set => GReset,
        d => e0,
        q => s0
    );
    u_s1 : dflipflop port map (
        clk => GClock,
        reset => GReset,
        set => '0',
        d => e1,
        q => s1
    );
    u_s2 : dflipflop port map (
        clk => GClock,
        reset => GReset,
        set => '0',
        d => e2,
        q => s2
    );
    u_s3 : dflipflop port map (
        clk => GClock,
        reset => GReset,
        set => '0',
        d => e3,
        q => s3
    );
    u_s4 : dflipflop port map (
        clk => GClock,
        reset => GReset,
        set => '0',
        d => e4,
        q => s4
    );
    u_loadL : and2 port map (
        a => s0,
        b => Tick,
        y => LoadL
    );
    u_loadR : and2 port map (
        a => s0,
        b => Tick,
        y => LoadR
    );
    u_or12 : or2 port map (
        a => s1,
        b => s2,
        y => s1_or_s2
    );
    u_shL : and2 port map (
        a => s1_or_s2,
        b => Tick,
        y => ShiftL
    );
    u_or13 : or2 port map (
        a => s1,
        b => s3,
        y => s1_or_s3
    );
    u_shR : and2 port map (
        a => s1_or_s3,
        b => Tick,
        y => ShiftR
    );
    Dsel0 <= s1;
    Dsel1 <= s3;
    u_or01: or2 port map (
        a => s0,
        b => s1,
        y => s0_or_s1
    );
    u_or23 : or2 port map (
        a => s2,
        b => s3,
        y => s2_or_s3
    );
    u_or0123 : or2 port map (
        a => s0_or_s1,
        b => s2_or_s3,
        y => any_load
    );
    u_loadD : and2 port map (
        a => any_load,
        b => Tick,
        y => LoadD
    );
    u_resetD : and2 port map (
        a => s4,
        b => Tick,
        y => ResetD
    );
end basic;






