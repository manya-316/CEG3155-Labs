-- ShiftRegister4Bit.vhd
-- 4-bit register with load, shift left and shift right (0 shifted in),
-- and asynchronous reset. Priority: load, then shiftR, then shiftL, else hold.

entity ShiftRegister4Bit is
    port (
        clk, reset, shiftL, shiftR, load : in bit;
        d : in bit_vector(3 downto 0);
        q : out bit_vector(3 downto 0)
    );
end ShiftRegister4Bit;

architecture basic of ShiftRegister4Bit is
    component dff is
        port (clk, clr, pre, d : in bit; q : out bit);
    end component;
    component bitmux21 is
        port (d0, d1, sel : in bit; y : out bit);
    end component;

    signal q_int, shift_L_int, shift_R_int : bit_vector(3 downto 0);
    signal after_L, after_R, next_q : bit_vector(3 downto 0);
begin
    shift_L_int(0) <= '0';
    shift_L_int(3 downto 1) <= q_int(2 downto 0);

    shift_R_int(3) <= '0';
    shift_R_int(2 downto 0) <= q_int(3 downto 1);

    gen_bits: for i in 0 to 3 generate
        u_left  : bitmux21 port map(d0 => q_int(i),   d1 => shift_L_int(i), sel => shiftL, y => after_L(i));
        u_right : bitmux21 port map(d0 => after_L(i), d1 => shift_R_int(i), sel => shiftR, y => after_R(i));
        u_load  : bitmux21 port map(d0 => after_R(i), d1 => d(i),           sel => load,   y => next_q(i));
        u_ff    : dff port map(clk => clk, clr => reset, pre => '0', d => next_q(i), q => q_int(i));
    end generate gen_bits;

    q <= q_int;
end basic;