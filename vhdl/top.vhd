entity top is 
    generic (N_div : positive := 100_000_000);
    port (
        CLK100MHZ, SW_RESET, SW_LEFT, SW_RIGHT : in bit;
        LED : out bit_vector(7 downto 0)
    );
end top;

architecture basic of top is 
    component clk_div is 
        generic (N : positive := 100_000_000);
        port (
            clk, reset : in bit; 
            clk_out : out bit
        );
    end component;
    component controlpath is
        port (
            GClock, GReset, L, R, Tick : in bit;
            LoadL, LoadR, ShiftL, ShiftR : out bit;
            DSel1, DSel0, LoadD, ResetD : out bit
        );
    end component;
    component datapath is
        port (
            Clk, GReset, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : in bit;
            DisplayOut : out bit_vector(7 downto 0)
        );
    end component;

    signal tick : bit;
    signal LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : bit;

begin
    u_clk_div : clk_div generic map (N => N_div) port map (
        clk => CLK100MHZ,
        reset => SW_RESET,
        clk_out => tick
    );
    u_controlpath : controlpath port map (
        GClock => CLK100MHZ,
        GReset => SW_RESET,
        L => SW_LEFT,
        R => SW_RIGHT,
        Tick => tick,
        LoadL => LoadL,
        LoadR => LoadR,
        ShiftL => ShiftL,
        ShiftR => ShiftR,
        DSel1 => DSel1,
        DSel0 => DSel0,
        LoadD => LoadD,
        ResetD => ResetD
    );
    u_datapath : datapath port map (
        Clk => CLK100MHZ,
        GReset => SW_RESET,
        LoadL => LoadL,
        LoadR => LoadR,
        ShiftL => ShiftL,
        ShiftR => ShiftR,
        DSel1 => DSel1,
        DSel0 => DSel0,
        LoadD => LoadD,
        ResetD => ResetD,
        DisplayOut => LED
    );
end basic;
