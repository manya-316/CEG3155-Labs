-- DownCounter4Bit.vhd
-- 4-bit down-counter with synchronous load, decrement,
-- asynchronous reset, and zero flag.

entity DownCounter4Bit is
    port (
        clk, reset : in bit;
        load, dec : in bit;
        d : in bit_vector(3 downto 0);
        q : out bit_vector(3 downto 0);
        zero : out bit
    );
end DownCounter4Bit;

architecture struct of DownCounter4Bit is

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

    signal q_int : bit_vector(3 downto 0);
    signal dec_val : bit_vector(3 downto 0);
    signal count_mux : bit_vector(3 downto 0);
    signal next_q : bit_vector(3 downto 0);
    signal borrow : bit_vector(4 downto 0);

begin

    borrow(0) <= '1';

    gen_sub: for i in 0 to 3 generate
        dec_val(i) <= q_int(i) xor borrow(i);
        borrow(i + 1) <= (not q_int(i)) and borrow(i);
    end generate gen_sub;

    gen_bits: for i in 0 to 3 generate
        u_dec: mux21_1bit port map (
            d0 => q_int(i),
            d1 => dec_val(i),
            sel => dec,
            y => count_mux(i)
        );
        u_load: mux21_1bit port map (
            d0 => count_mux(i),
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

    zero <= not (q_int(3) or q_int(2) or q_int(1) or q_int(0));

end struct;