entity datapath is
    port (
        Clk, LoadL, LoadR, ShiftL, ShiftR, DSel1, DSel0, LoadD, ResetD : in bit;
        DisplayOut : out bit_vector(7 downto 0);
    );
end datapath;