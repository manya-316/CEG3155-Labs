entity datapath is
    port (
        Clk, GReset, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : in bit;
        DisplayOut : out bit_vector(7 downto 0)
    );
end datapath;

architecture basic of datapath is
    component LRegister is
        port (
        clk, reset, shiftL, load : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)  
    );
    end component;
    component RRegister is
        port (
        clk, reset, shiftR, load : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)  
    );
    end component;
    component DisplayRegister is
        port (
        clk, reset, loadD, resetD : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)
    );
    end component;
    component logicOR is
        port (
            a : in bit_vector(7 downto 0);
            b : in bit_vector(7 downto 0);
            y : out bit_vector(7 downto 0)
        );
    end component;
    component mux31 is
        port (
            d0, d1, d2 : in bit_vector(7 downto 0);
            s0, s1 : in bit;
            x : out bit_vector(7 downto 0)
        );
    end component;

    signal l_out  : bit_vector(7 downto 0);
    signal r_out  : bit_vector(7 downto 0);
    signal or_out : bit_vector(7 downto 0);
    signal mux_out : bit_vector(7 downto 0);
begin
    lReg : LRegister port map (
        clk => Clk,
        reset => GReset,
        shiftL => ShiftL,
        load => LoadL,
        d => "00000001",
        q => l_out
    );
    rReg : RRegister port map (
        clk => Clk,
        reset => GReset,
        shiftR => ShiftR,
        load => LoadR,
        d => "10000000",
        q => r_out
    );
    dReg : DisplayRegister port map (
        clk => Clk,
        reset => GReset,
        resetD => ResetD,
        loadD => LoadD,
        d => mux_out,
        q => DisplayOut
    );

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