-- LRegister.vhd
-- This entity is an 8-bit register with left-shift functionality,
-- designed to be used for the left shifting component of this system.

entity LRegister is
    port (
        clk, reset, shiftL, load : in bit;
        d : in bit_vector(7 downto 0);
        q : out bit_vector(7 downto 0)  
    );
end LRegister;

architecture basic of LRegister is
    component dflipflop is
        port (
            clk, reset, set, d : in bit;
            q : out bit 
        );
    end component;

    component mux21_1bit is
        port (
            d0, d1 : in bit;
            sel : in bit;
            y : out bit 
        );
    end component;

    signal q_int, shift_in, after_shift, next_q : bit_vector(7 downto 0);
begin 
    shift_in(0) <= q_int(7);
    shift_in(7 downto 1) <= q_int(6 downto 0);

    gen_bits: for i in 0 to 7 generate
        u_shift: mux21_1bit port map (
            d0 => q_int(i), d1 => shift_in(i), sel => shiftL, y => after_shift(i)
        );
        u_load: mux21_1bit port map (
            d0 => after_shift(i), d1 => d(i), sel => load, y => next_q(i)
        );
        u_ff: dflipflop port map (
            clk => clk, reset => reset, set => '0', d => next_q(i), q => q_int(i)
        );
        end generate gen_bits;

        q <= q_int;
end basic;