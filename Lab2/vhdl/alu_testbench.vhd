-- alu_testbench.vhd
-- CEG3155 Lab 2. Tests alu_top: add and subtract flag cases, two positive
-- and two negative multiplications, two positive and two negative
-- divisions, and divide by zero. GReset is pulsed before each case because
-- the multiplier and divider start from S0 on reset. Each case waits
-- 160 ns (7 GClock edges) so the divider (6 edges) has time to finish.
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
        ---------------- ADD / SUB ----------------
        -- ADD 7 + 2: positive overflow, MuxOut = 00001001, V = 1
        GReset <= '1'; OperandA <= "0111"; OperandB <= "0010"; OperationSelect <= "00";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- SUB 5 - 5 = 0: MuxOut = 00000000, C = 1, Z = 1
        GReset <= '1'; OperandA <= "0101"; OperandB <= "0101"; OperationSelect <= "01";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- SUB -8 - 1: negative overflow, MuxOut = 00000111, C = 1, V = 1
        GReset <= '1'; OperandA <= "1000"; OperandB <= "0001"; OperationSelect <= "01";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        ---------------- MULTIPLY ----------------
        -- MUL 3 x 4 = 12: MuxOut = 00001100
        GReset <= '1'; OperandA <= "0011"; OperandB <= "0100"; OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- MUL 7 x 5 = 35: MuxOut = 00100011
        GReset <= '1'; OperandA <= "0111"; OperandB <= "0101"; OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- MUL 3 x -5 = -15: MuxOut = 11110001
        GReset <= '1'; OperandA <= "0011"; OperandB <= "1011"; OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- MUL -4 x -3 = 12: MuxOut = 00001100
        GReset <= '1'; OperandA <= "1100"; OperandB <= "1101"; OperationSelect <= "10";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        ---------------- DIVIDE (MuxOut = remainder & quotient) ----------------
        -- DIV 7 / 2 = 3 r 1: MuxOut = 0001 0011
        GReset <= '1'; OperandA <= "0111"; OperandB <= "0010"; OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- DIV 6 / 3 = 2 r 0: MuxOut = 0000 0010
        GReset <= '1'; OperandA <= "0110"; OperandB <= "0011"; OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- DIV -7 / 2 = -3 r -1: MuxOut = 1111 1101
        GReset <= '1'; OperandA <= "1001"; OperandB <= "0010"; OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- DIV -6 / -4 = 1 r -2: MuxOut = 1110 0001
        GReset <= '1'; OperandA <= "1010"; OperandB <= "1100"; OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- DIV 5 / 0: divide by zero, V = 1
        GReset <= '1'; OperandA <= "0101"; OperandB <= "0000"; OperationSelect <= "11";
        wait for 20 ns;
        GReset <= '0'; wait for 160 ns;

        -- Hold idle at the end of simulation
        GReset <= '1';
        wait;
    end process;

end test_alu;