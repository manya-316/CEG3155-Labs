entity clk_div is
    generic (N : positive := 100_000_000);
    port (
        clk, reset : in bit;
        clk_out : out bit
    );
end clk_div;

architecture basic of clk_div is
    component and2 is
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

    constant W : positive := 27;

    function to_bits(val : natural; width : positive) return bit_vector is
        variable v : bit_vector(width - 1 downto 0);
        variable r : natural := val;
    begin
        for i in 0 to width - 1 loop
            v(i) := '0';
        end loop;
        for i in 0 to width - 1 loop
            if (r mod 2) = 1 then
                v(i) := '1';
            end if;
            r := r / 2;
        end loop;
        return v;
    end function;

    constant K : bit_vector(W - 1 downto 0) := to_bits(N - 1, W);
    signal cnt, inc, nxt, diff, same : bit_vector(W - 1 downto 0);
    signal carry, eq : bit_vector(W downto 0);  
    signal tick_int, tick_n : bit;

begin
    carry(0) <= '1';
    eq(0) <= '1';
    gen_bits : for i in 0 to W - 1 generate
        u_sum : xor2 port map (
            a => cnt(i),
            b => carry(i),
            y => inc(i)
        );
        u_carry : and2 port map (
            a => cnt(i),
            b => carry(i),
            y => carry(i + 1)
        );
        u_diff : xor2 port map (
            a => cnt(i),
            b => K(i),
            y => diff(i)
        );
        u_same : not_gate port map (
            a => diff(i),
            y => same(i)
        );
        u_eq : and2 port map (
            a => eq(i),
            b => same(i),
            y => eq(i + 1)
        );
        u_clr : and2 port map (
            a => inc(i),
            b => tick_n,
            y => nxt(i)
        );
        u_ff : dflipflop port map (
            clk => clk,
            reset => reset,
            set => '0',
            d => nxt(i),
            q => cnt(i)
        );
    end generate gen_bits;
    tick_int <= eq(W);
    u_tn : not_gate port map (
        a => tick_int,
        y => tick_n
    );
end basic;
