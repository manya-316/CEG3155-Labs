entity multiplier_datapath is
    port (
        clk, reset : in bit;
        shiftLA, loadA : in bit;
        shiftRB, loadB : in bit;
        dec, loadCtr : in bit;
        sub : in bit;
        loadP, resetP : in bit;
        a, b : in bit_vector(3 downto 0);
        b_lsb : out bit;
        ctr_zero : out bit;
        y : out bit_vector(7 downto 0)
    );
end multiplier_datapath;

architecture struct of multiplier_datapath is

    component ShiftRegister8Bit is
        port (
            clk, reset   : in bit;
            shiftL, shiftR, load : in bit;
            d : in bit_vector(7 downto 0);
            q : out bit_vector(7 downto 0)
        );
    end component;

    component ShiftRegister4Bit is
        port (
            clk, reset : in bit;
            shiftL, shiftR, load : in bit;
            d : in bit_vector(3 downto 0);
            q : out bit_vector(3 downto 0)
        );
    end component;

    component Reg8Bit is
        port (
            clk, reset : in bit;
            load : in bit;
            d : in bit_vector(7 downto 0);
            q : out bit_vector(7 downto 0)
        );
    end component;

    component rippleaddsub8bit is
        port (
            a, b : in bit_vector(7 downto 0);
            sub : in bit;
            s : out bit_vector(7 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;

    component DownCounter4Bit is
        port (
            clk, reset : in bit;
            load, dec  : in bit;
            d : in bit_vector(3 downto 0);
            zero : out bit
        );
    end component;

    component or2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;

    signal extA : bit_vector(7 downto 0);
    signal regA_out : bit_vector(7 downto 0);
    signal regB_out : bit_vector(3 downto 0);
    signal sum_result : bit_vector(7 downto 0);
    signal prod_reg : bit_vector(7 downto 0);
    signal p_reset : bit;

begin

    extA <= a(3) & a(3) & a(3) & a(3) & a;

    regA : ShiftRegister8Bit
        port map (
            clk => clk,
            reset => reset,
            shiftL => shiftLA,
            shiftR => '0',
            load  => loadA,
            d => extA,
            q => regA_out
        );

    regB : ShiftRegister4Bit
        port map (
            clk => clk,
            reset  => reset,
            shiftL => '0',
            shiftR => shiftRB,
            load  => loadB,
            d => b,
            q => regB_out
        );

    b_lsb <= regB_out(0);

    alu : rippleaddsub8bit
        port map (
            a => prod_reg,
            b => regA_out,
            sub => sub,
            s => sum_result,
            cout => open
        );

    regP : Reg8Bit
        port map (
            clk => clk,
            reset => resetP,
            load => loadP,
            d => sum_result,
            q => prod_reg
        );

    ctr : DownCounter4Bit
        port map (
            clk => clk,
            reset => reset,
            load => loadCtr,
            dec => dec,
            d => "0011",
            zero => ctr_zero
        );

    y <= prod_reg;

end struct;