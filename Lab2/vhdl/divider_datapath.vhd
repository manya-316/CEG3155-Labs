entity divider_datapath is
    port (
        clk, reset : in bit;
        resetQ, loadA, loadB, loadCtr, initR: in bit;
        loadXs, shiftLA, shiftLQ, dec, loadT, loadR, loadNeg : in bit;
        a, b : in bit_vector(3 downto 0);
        Z, OK : out bit;
        remOut, qOut : out bit_vector(3 downto 0)
    );
end divider_datapath;


architecture struct of divider_datapath is
    component dff is
        port (
            clk, clr, pre, d: in bit;
            q: out bit
        );
    end component;

    component Reg4Bit is
        port (
            clk, reset : in bit;
            load : in bit;
            d : in bit_vector(3 downto 0);
            q : out bit_vector(3 downto 0)
        );
    end component;

    component DownCounter4Bit is
        port (
            clk, reset : in bit;
            load, dec : in bit;
            d : in bit_vector(3 downto 0);
            zero : out bit
        );
    end component;

    component ShiftRegister4Bit is
        port (
            clk, reset, shiftL, shiftR, load : in bit;
            d : in bit_vector(3 downto 0);
            q : out bit_vector(3 downto 0)
        );
    end component;

    component bitmux21 is
        port (
            d0, d1, sel: in bit;
            y: out bit
        );
    end component;

    component mux31_4bit is
        port (
            d0, d1, d2 : in bit_vector(3 downto 0);
            s0, s1 : in bit;
            x : out bit_vector(3 downto 0)
        );
    end component;

    component rippleaddsub4bit is
        port (
            a, b : in bit_vector(3 downto 0);
            sub : in bit;
            s : out bit_vector(3 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;

    component and2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;

    component xor2 is port (
            a, b : in bit;
            y : out bit
        );
    end component;

    component or2 is port (
            a, b : in bit;
            y : out bit
        );
    end component;
    
    component nor4 is
        port (
            a, b, c, d : in bit;
            y : out bit
        );
    end component;
    -- op registers
    signal opA_out, opB_out : bit_vector(3 downto 0);

    -- X
    signal Xs_inp : bit;
    signal Xs : bit; -- single bit reg, stores opA_out(3)

    -- quotient storage
    signal quotient_out : bit_vector(3 downto 0);
    signal quotient_neg : bit_vector(3 downto 0);
    signal quotient_shifted : bit_vector(3 downto 0);
    signal quotient_inp : bit_vector(3 downto 0);

    -- adder in/out
    signal r_prime : bit_vector(3 downto 0);
    signal T : bit_vector(3 downto 0);
    signal Ts, Zt, Zd : bit; -- idk what these are lol
    signal V : bit; -- this is overflow out

    -- OK signal
    signal in_OK : bit;
    signal or_inp1, or_inp2, or_int, and2_out : bit;

    -- counter
    signal in_Z : bit; -- counter zero flag

    -- remainder
    signal rem_input, rem_out : bit_vector(3 downto 0);
    signal signExtA : bit_vector(3 downto 0);

    -- helpers
    signal not_Xs, not_Ts : bit;
    signal loadNeg_or_shiftLQ, Xs_xnor_opB3 : bit;
    signal load_rem : bit;

begin
    -- Output assignments
    remOut <= rem_out;
    qOut   <= quotient_out;
    Z      <= in_Z;
    OK     <= in_OK;

    r_prime <= rem_out(2 downto 0) & opA_out(3);

    Ts_xor : xor2 port map (
        a => T(3), b => V,
        y => Ts
    );

    zero_gate : nor4 port map (
        a => T(3), b => T(2), c => T(1), d => T(0),
        y => Zt
    );

    zero_d_gate : nor4 port map (
        a => '0', b => opA_out(2), c => opA_out(1), d => opA_out(0),
        y => Zd
    );

    signExtA(3) <= opA_out(3);
    signExtA(2) <= opA_out(3);
    signExtA(1) <= opA_out(3);
    signExtA(0) <= opA_out(3);

    -- Concurrent helper assignments
    not_Xs             <= not Xs;
    not_Ts             <= not Ts;
    loadNeg_or_shiftLQ <= loadNeg or shiftLQ;
    Xs_xnor_opB3       <= rem_out(3) xnor opB_out(3);
    load_rem           <= initR or loadR or loadT;

    in_OK_and1 : and2 port map (
        a => not_Xs, b => not_Ts,
        y => or_inp1
    );

    in_OK_and2 : and2 port map (
        a => Zt, b => Zd,
        y => and2_out
    );

    in_OK_or_int : or2 port map (
        a => Ts, b => and2_out,
        y => or_int
    );

    in_OK_and3 : and2 port map (
        a => Xs, b => or_int,
        y => or_inp2
    );

    in_OK_topOR : or2 port map (
        a => or_inp1, b => or_inp2,
        y => in_OK
    );

    xs_mux : bitmux21 port map (
        d0  => Xs, d1 => opA_out(3),
        sel => loadXs,
        y   => Xs_inp
    );

    xs_reg : dff port map (
        clk => clk, clr => '0', pre => '0',
        d   => Xs_inp,
        q   => Xs
    );

    -- Two's complement of quotient_out 
    quotient_neg <= (quotient_out(3) xor (quotient_out(2) or quotient_out(1) or quotient_out(0))) &
                    (quotient_out(2) xor (quotient_out(1) or quotient_out(0))) &
                    (quotient_out(1) xor quotient_out(0)) &
                    quotient_out(0); 

    -- Shifted with serial input
    quotient_shifted <= quotient_out(2 downto 0) & in_OK;

    gen_q_inp : for i in 0 to 3 generate
        q_inp_mux : bitmux21 port map (
            d0  => quotient_shifted(i),
            d1  => quotient_neg(i),
            sel => loadNeg,
            y   => quotient_inp(i)
        );
    end generate gen_q_inp;

    quotient : Reg4Bit port map (
        clk   => clk, reset => resetQ,
        load  => loadNeg_or_shiftLQ, 
        d     => quotient_inp,
        q     => quotient_out
    );

    opA : ShiftRegister4Bit port map (
        clk    => clk, reset => reset, 
        shiftL => shiftLA, shiftR => '0',
        load   => loadA,
        d      => a,
        q      => opA_out
    );

    opB : Reg4Bit port map (
        clk   => clk, reset => reset,
        load  => loadB, d => b, q => opB_out
    );

    rem_mux : mux31_4bit port map (
        d0 => signExtA, d1 => r_prime, d2 => T,
        s0 => loadR, s1 => loadT,
        x  => rem_input
    );

    rem_reg : Reg4Bit port map (
        clk   => clk, reset => reset,
        load  => load_rem,
        d     => rem_input,
        q     => rem_out
    );

    addsub : rippleaddsub4bit port map (
        a   => r_prime, b => opB_out, 
        sub => Xs_xnor_opB3,
        s   => T, ovf => V
    );

    ctr : DownCounter4Bit port map (
        clk   => clk, reset => '0', load => loadCtr, 
        dec   => dec, 
        d     => "0011",
        zero  => in_Z
    );
end struct;