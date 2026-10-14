entity alu_testbench is
end alu_testbench;

architecture test_alu of alu_testbench is

    component alu_top is
        port (
            GClock, GReset : in bit;
            CLK100MHZ : in bit;
            OperandA : in bit_vector(3 downto 0);
            OperandB : in bit_vector(3 downto 0);
            OperationSelect : in bit_vector(1 downto 0);
            MuxOut : out bit_vector(7 downto 0);
            CarryOut : out bit;
            OverflowOut : out bit;
            ZeroOut : out bit;
            seg : out bit_vector(6 downto 0);
            an : out bit_vector(7 downto 0)
        );
    end component;

    signal GClock : bit := '0';
    signal GReset : bit := '1';
    signal CLK100MHZ : bit := '0';
    signal OperandA : bit_vector(3 downto 0) := "0000";
    signal OperandB : bit_vector(3 downto 0) := "0000";
    signal OperationSelect : bit_vector(1 downto 0) := "00";
    signal MuxOut : bit_vector(7 downto 0);
    signal CarryOut : bit;
    signal OverflowOut : bit;
    signal ZeroOut : bit;
    signal seg : bit_vector(6 downto 0);
    signal an : bit_vector(7 downto 0);

    constant GCLK_PERIOD : time := 20 ns;

begin

    uut: alu_top
        port map (
            GClock          => GClock,
            GReset          => GReset,
            CLK100MHZ       => CLK100MHZ,
            OperandA        => OperandA,
            OperandB        => OperandB,
            OperationSelect => OperationSelect,
            MuxOut          => MuxOut,
            CarryOut        => CarryOut,
            OverflowOut     => OverflowOut,
            ZeroOut         => ZeroOut,
            seg             => seg,
            an              => an
        );

    -- Free-running 100 MHz clock
    CLK100MHZ <= not CLK100MHZ after 5 ns;

    -- Free-running GClock
    GClock <= not GClock after 10 ns;

    -- Stimulus process
    stim_proc: process
    begin
        -- ADD (7 + 2) -> Positive Overflow (0111 + 0010 = 1001)
        GReset          <= '1';
        OperandA        <= "0111";
        OperandB        <= "0010";
        OperationSelect <= "00";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns; 

        -- SUB (5 - 5 = 0) -> ZeroOut flag test
        GReset          <= '1';
        OperandA        <= "0101";
        OperandB        <= "0101";
        OperationSelect <= "01";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns;

        -- SUB (-8 - 1 = -9) -> Negative Overflow test ("1000" - "0001")
        GReset          <= '1';
        OperandA        <= "1000";
        OperandB        <= "0001";
        OperationSelect <= "01";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns;

        -- DIV (11 / 4) -> Remainder = 3 ("0011"), Quotient = 2 ("0010")
        -- MuxOut = Remainder & Quotient -> "00110010"
        GReset          <= '1';
        OperandA        <= "1011";
        OperandB        <= "0100";
        OperationSelect <= "11";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns;

        -- DIV (3 / 5) -> Remainder = 3, Quotient = 0 (ZeroOut on Div)
        GReset          <= '1';
        OperandA        <= "0011";
        OperandB        <= "0101";
        OperationSelect <= "11";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns;

        -- MULT (3 * 4 = 12)
        GReset          <= '1';
        OperandA        <= "0011";
        OperandB        <= "0100";
        OperationSelect <= "10";
        wait for 20 ns;

        GReset <= '0';
        wait for 60 ns; 
        wait for 40 ns;

        -- Hold idle at the end of simulation
        GReset <= '1';
        wait;
    end process;

end test_alu;