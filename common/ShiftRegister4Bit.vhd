-- ShiftRegister4Bit.vhd
-- This entity is an 4-bit register with left and right shift functionality,
-- as well as reset.

entity ShiftRegister4Bit is
    port (
        clk, reset, shiftL, shiftR, load : in bit;
        d : in bit_vector(3 downto 0);
        q : out bit_vector(3 downto 0)  
    );
end ShiftRegister4Bit;

architecture basic of ShiftRegister4Bit is
    component dflipflop is
        port (
            clk, reset, set, d : in bit;
            q : out bit 
        );
    end component;

    component mux31_1bit is
        port (
            d0, d1, d2 : in bit;
            sel : in bit;
            y : out bit 
        );
    end component;

    signal q_int, shift_L_int, shift_R_int, after_shift, next_q : bit_vector(3 downto 0);
begin 
    shift_L_int(0) <= q_int(3);
    shift_L_int(3 downto 1) <= q_int(2 downto 0);

    shift_R_int(3) <= q_int(0);
    shift_R_int(2 downto 0) <= q_int(3 downto 1);

    gen_bits: for i in 0 to 3 generate
        u_shift: mux31_1bit port map (
            d0 => q_int(i),
            d1 => shift_L_int(i),
            d2 => shift_R_int(i),
            s0 => shiftL,
            s1 => shiftR,
            y => after_shift(i)
        );
        u_load: mux21_1bit port map (
            d0 => after_shift(i),
            d1 => d(i),
            sel => load,
            y => next_q(i)
        );
        u_ff: dflipflop port map (
            clk => clk,
            reset => reset,
            set => '0',
            d => next_q(i),
            q => q_int(i)
        );
    end generate gen_bits;

    q <= q_int;
end basic;