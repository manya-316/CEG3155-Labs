-- Tests alu_top with one case per operation plus the
-- flag cases. GReset is pulsed before each case because the multiplier
-- and divider start from S0 on reset. Each case waits 160 ns (7 GClock
-- edges) so the divider (6 edges) has time to finish.
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

    -- Free-running 100 MHz clock for the display controller
    CLK100MHZ <= not CLK100MHZ after 5 ns;

    -- Free-running GClock, 20 ns period
    GClock <= not GClock after 10 ns;

    stim_proc: process
    begin
        -- ADD 7 + 2: positive overflow, MuxOut = 00001001, V = 1
        GReset          <= '1';
        OperandA        <= "0111";
        OperandB        <= "0010";
        OperationSelect <= "00";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- SUB 5 - 5 = 0: MuxOut = 00000000, C = 1, Z = 1
        GReset          <= '1';
        OperandA        <= "0101";
        OperandB        <= "0101";
        OperationSelect <= "01";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- SUB -8 - 1: negative overflow, MuxOut = 00000111, C = 1, V = 1
        GReset          <= '1';
        OperandA        <= "1000";
        OperandB        <= "0001";
        OperationSelect <= "01";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- MUL 3 x 4 = 12: MuxOut = 00001100
        GReset          <= '1';
        OperandA        <= "0011";
        OperandB        <= "0100";
        OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- MUL 3 x -5 = -15: MuxOut = 11110001
        GReset          <= '1';
        OperandA        <= "0011";
        OperandB        <= "1011";
        OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- DIV -5 / 4: quotient -1, remainder -1, MuxOut = 11111111
        GReset          <= '1';
        OperandA        <= "1011";
        OperandB        <= "0100";
        OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- DIV 3 / 5: quotient 0, remainder 3, MuxOut = 00110000
        GReset          <= '1';
        OperandA        <= "0011";
        OperandB        <= "0101";
        OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- DIV 5 / 0: divide by zero, V = 1
        GReset          <= '1';
        OperandA        <= "0101";
        OperandB        <= "0000";
        OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0';
        wait for 160 ns;

        -- Hold idle at the end of simulation
        GReset <= '1';
        wait;
    end process;

end test_alu;