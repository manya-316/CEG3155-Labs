-- Signed 4x4 multiplier: datapath + control path.
entity shiftaddmul4bit is
    port (
        clk, reset : in bit;
        a, b : in bit_vector(3 downto 0);
        y : out bit_vector(7 downto 0);
        done : out bit
    );
end shiftaddmul4bit;

architecture struct of shiftaddmul4bit is
    component multiplier_datapath is
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
    end component;
    component multiplier_controlpath is
        port (
            clk, reset : in bit;
            b_lsb, ctr_zero : in bit;
            resetP, loadA, loadB, loadCtr : out bit;
            shiftLA, shiftRB, dec : out bit;
            loadP, sub : out bit;
            done : out bit
        );
    end component;

    signal shiftLA, loadA, shiftRB, loadB, dec, loadCtr : bit;
    signal sub, loadP, resetP : bit;
    signal b_lsb, ctr_zero : bit;
begin
    dp : multiplier_datapath port map(
        clk => clk, reset => reset,
        shiftLA => shiftLA, loadA => loadA,
        shiftRB => shiftRB, loadB => loadB,
        dec => dec, loadCtr => loadCtr,
        sub => sub, loadP => loadP, resetP => resetP,
        a => a, b => b,
        b_lsb => b_lsb, ctr_zero => ctr_zero,
        y => y
    );

    cp : multiplier_controlpath port map(
        clk => clk, reset => reset,
        b_lsb => b_lsb, ctr_zero => ctr_zero,
        resetP => resetP, loadA => loadA, loadB => loadB, loadCtr => loadCtr,
        shiftLA => shiftLA, shiftRB => shiftRB, dec => dec,
        loadP => loadP, sub => sub,
        done => done
    );
end struct;