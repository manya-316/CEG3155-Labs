entity multiplier_controlpath is 
    port (
        clk, reset : in bit;
        b_lsb : in bit;
        ctr_zero : in bit;
        shiftLA, loadA : out bit;
        shiftRB, loadB : out bit;
        dec, loadCtr : out bit;
        sub : out bit;
        loadP, resetP : out bit;
        done : out bit
    );
end multiplier_controlpath;

architecture struct of multiplier_controlpath is
    component dff is 
        port (
            clk, clr, pre, d: in bit;
            q: out bit
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
    signal s0, s1, s2 : bit;
    signal d1, d2  : bit;
    signal not_z, s1_notz, s1_z : bit;
    signal s1_b : bit;
begin
    inv_z : xor2 port map (a => ctr_zero, b => '1', y => not_z);
    g1 : and2 port map (a => s1, b => not_z, y => s1_notz);
    g2 : or2 port map (a => s0, b => s1_notz, y => d1);
    g3 : and2 port map (a => s1, b => ctr_zero, y => s1_z);
    g4 : or2 port map (a => s1_z, b => s2 , y => d2);

    ff0 : dff port map (clk => clk, clr => '0', pre => reset , d => '0', q => s0);
    ff1 : dff port map (clk => clk, clr => reset , pre => '0' , d => d1, q => s1);
    ff2 : dff port map (clk => clk, clr => reset , pre => '0', d => d2, q => s2);

    resetP <= s0;
    loadA <= s0;
    loadB <= s0;
    loadCtr <= s0;

    shiftLA <= s1;
    shiftRB <= s1;
    dec <= s1;

    g5: and2 port map (a => s1, b => b_lsb, y => s1_b);
    loadP <= s1_b;
    g6: and2 port map (a => s1_b, b => ctr_zero, y => sub);
    done <= s2;
end struct;
    