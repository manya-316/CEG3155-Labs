entity datapath is
    port (
        Clk, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : in bit;
        DisplayOut : out bit_vector(7 downto 0)
    );
end datapath;

architecture basic of datapath is
    component LRegister is
        port (
            clk : in bit;
            shiftL : in bit;
            load : in bit;
            d0, d1, d2, d3, d4, d5, d6, d7 : in bit;
            q0, q1, q2, q3, q4, q5, q6, q7 : out bit
        );
    end component;
    component RRegister is
        port (
            clk : in bit;
            shiftR : in bit;
            load : in bit;
            d0, d1, d2, d3, d4, d5, d6, d7 : in bit;
            q0, q1, q2, q3, q4, q5, q6, q7 : out bit
        );
    end component;
    component DisplayRegister is
        port (
            clk : in bit;
            reset : in bit;
            load : in bit;
            d0, d1, d2, d3, d4, d5, d6, d7 : in bit;
            q0, q1, q2, q3, q4, q5, q6, q7 : out bit
        );
    end component;
    component logicOR is
        port (
            a : in bit_vector(7 downto 0);
            b : in bit_vector(7 downto 0);
            y : out bit_vector(7 downto 0);
        );
    end component;
    component mux31 is
        port (
            d0, d1, d2 : in bit_vector(7 downto 0);
            s0, s1 : in bit;
            x : out bit_vector(7 downto 0);
        );
    end component;

    signal l_out  : bit_vector(7 downto 0);
    signal r_out  : bit_vector(7 downto 0);
    signal or_out : bit_vector(7 downto 0);
    signal mux_out : bit_vector(7 downto 0);
begin
    lReg : LRegister port map (
        clk => Clk,
        shiftL => ShiftL,
        load => LoadL,
        d0 => '0', d1 => '0', d2 => '0', d3 => '0', 
        d4 => '0', d5 => '0', d6 => '0', d7 => '1',
        q0 => l_out(0),
        q1 => l_out(1),
        q2 => l_out(2),
        q3 => l_out(3),
        q4 => l_out(4),
        q5 => l_out(5),
        q6 => l_out(6),
        q7 => l_out(7),
    );
    rReg : RRegister port map (
        clk => Clk,
        shiftR => ShiftR,
        load => LoadR,
        d0 => '1', d1 => '0', d2 => '0', d3 => '0', 
        d4 => '0', d5 => '0', d6 => '0', d7 => '0',
        q0 => r_out(0),
        q1 => r_out(1),
        q2 => r_out(2),
        q3 => r_out(3),
        q4 => r_out(4),
        q5 => r_out(5),
        q6 => r_out(6),
        q7 => r_out(7),
    );
    dReg : DisplayRegister port map (
        clk => Clk,
        reset => ResetD,
        load => LoadD,
        d0 => mux_out(0)
        d1 => mux_out(1)
        d2 => mux_out(2)
        d3 => mux_out(3)
        d4 => mux_out(4)
        d5 => mux_out(5)
        d6 => mux_out(6)
        d7 => mux_out(7)
        q0 => DisplayOut(0),
        q1 => DisplayOut(1),
        q2 => DisplayOut(2),
        q3 => DisplayOut(3),
        q4 => DisplayOut(4),
        q5 => DisplayOut(5),
        q6 => DisplayOut(6),
        q7 => DisplayOut(7),
    )
    
    regOR : logicOR port map (
        a => l_out,
        b => r_out,
        y => or_out
    );

    inp_mux : mux31 port map (
        d0 => l_out,
        d1 => or_out,
        d2 => r_out,
        s0 => DSel0,
        s1 => DSel1,
        x => mux_out
    );

end basic;