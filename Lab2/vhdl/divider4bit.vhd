-- divider4bit.vhd
-- 4-bit divider with remainder and quotient outputs, and done signal.
entity divider4bit is
    port (
        clk, reset : in bit;
        a, b : in bit_vector(3 downto 0); -- a is dividend, b is divisor
        quotient : out bit_vector(3 downto 0);
        remainder : out bit_vector(3 downto 0);
        done : out bit
    );
end divider4bit;

architecture struct of divider4bit is
    component divider_datapath is
        port (
            clk, reset : in bit;
            initR, loadT, loadR : in bit;
            loadA, shiftLA : in bit;
            loadB : in bit;
            resetQ, shiftLQ, loadNeg : in bit;
            loadXs : in bit;
            loadCtr, dec : in bit;
            a, b : in bit_vector(3 downto 0);
            ok : out bit;
            ctr_zero : out bit;
            signs_differ : out bit;
            quotient : out bit_vector(3 downto 0);
            remainder : out bit_vector(3 downto 0)
        );
    end component;
    component divider_controlpath is
        port (
            clk, reset : in bit;
            ok, ctr_zero, signs_differ : in bit;
            initR, loadA, loadB, resetQ, loadXs, loadCtr : out bit;
            shiftLA, shiftLQ, dec : out bit;
            loadT, loadR : out bit;
            loadNeg : out bit;
            done : out bit
        );
    end component;

    signal initR, loadT, loadR, loadA, shiftLA, loadB : bit;
    signal resetQ, shiftLQ, loadNeg, loadXs, loadCtr, dec : bit;
    signal ok, ctr_zero, signs_differ : bit;
begin
    dp : divider_datapath port map(
        clk => clk, reset => reset,
        initR => initR, loadT => loadT, loadR => loadR,
        loadA => loadA, shiftLA => shiftLA, loadB => loadB,
        resetQ => resetQ, shiftLQ => shiftLQ, loadNeg => loadNeg,
        loadXs => loadXs, loadCtr => loadCtr, dec => dec,
        a => a, b => b,
        ok => ok, ctr_zero => ctr_zero, signs_differ => signs_differ,
        quotient => quotient, remainder => remainder
    );

    cp : divider_controlpath port map(
        clk => clk, reset => reset,
        ok => ok, ctr_zero => ctr_zero, signs_differ => signs_differ,
        initR => initR, loadA => loadA, loadB => loadB,
        resetQ => resetQ, loadXs => loadXs, loadCtr => loadCtr,
        shiftLA => shiftLA, shiftLQ => shiftLQ, dec => dec,
        loadT => loadT, loadR => loadR, loadNeg => loadNeg,
        done => done
    );
end struct;