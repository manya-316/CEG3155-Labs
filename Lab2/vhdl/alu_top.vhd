-- ALU top-level module for Lab 2. It instantiates the ALU components and the display controller, and connects them together. The ALU has 4-bit inputs A and B, a 2-bit operation select, and produces an 8-bit output (MuxOut) along with status flags (CarryOut, OverflowOut, ZeroOut). The display controller takes the ALU output and other relevant signals to drive a 7-segment display.
entity alu_top is
    port (
        GClock, GReset : in bit;
        CLK100MHZ : in bit;
        OperandA, OperandB : in bit_vector(3 downto 0);
        OperationSelect : in bit_vector(1 downto 0);
        MuxOut : out bit_vector(7 downto 0);
        CarryOut, OverflowOut, ZeroOut : out bit;
        seg : out bit_vector(6 downto 0);
        an : out bit_vector(7 downto 0)
    );
end alu_top;

architecture struct of alu_top is
    component rippleaddsub4bit is
        port (
            a, b : in bit_vector(3 downto 0);
            sub : in bit;
            s : out bit_vector(3 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;
    component shiftaddmul4bit is
        port (
            clk, reset : in bit;
            a, b : in bit_vector(3 downto 0);
            y : out bit_vector(7 downto 0);
            done : out bit
        );
    end component;
    component divider4bit is
        port (
        clk, reset : in bit;
        a, b : in bit_vector(3 downto 0); -- a is dividend, b is divisor
        quotient : out bit_vector(3 downto 0);
        remainder : out bit_vector(3 downto 0);
        done : out bit
    );
    end component;
    component mux41_8bit is 
        port (
            d0, d1, d2, d3 : in bit_vector(7 downto 0);
            sel : in bit_vector(1 downto 0);
            y : out bit_vector(7 downto 0)
        );
    end component;
    component status_logic is
        port (
        opsel : in bit_vector(1 downto 0);
        addsub_cout, addsub_ovf : in bit;
        a, b : in bit_vector(3 downto 0);
        muxout : in bit_vector(7 downto 0);
        carry_out, zero_out, overflow_out : out bit
    );
    end component;
    component display_controller is
        port (
            clk100 : in bit;
            d0, d1, d2, d3, d4, d5, d6, d7 : in bit_vector(3 downto 0);
            blank : in bit_vector(7 downto 0);
            seg : out bit_vector(6 downto 0);
            an : out bit_vector(7 downto 0)
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
    component dff is
        port (
            clk, clr, pre, d : in bit;
            q : out bit
        );
    end component;

    signal addsub_s, addsub_q : bit_vector(3 downto 0);
    signal addsub_cout, addsub_ovf, cout_q, ovf_q : bit;
    signal product : bit_vector(7 downto 0);
    signal quotient, remainder : bit_vector(3 downto 0);
    signal mul_done, div_done : bit;
    signal addsub_8, divres_8, mux_y : bit_vector(7 downto 0);
    signal op_digit : bit_vector(3 downto 0);
begin

    u_addsub : rippleaddsub4bit port map (a => OperandA, b => OperandB, sub => OperationSelect(0), s => addsub_s, cout => addsub_cout, ovf => addsub_ovf);
    r_sum : Reg4Bit port map (clk => GClock, reset => GReset, load => '1', d => addsub_s, q => addsub_q);
    r_cout : dff port map (clk => GClock, clr => GReset, pre => '0', d => addsub_cout, q => cout_q);
    r_ovf : dff port map (clk => GClock, clr => GReset, pre => '0', d => addsub_ovf, q => ovf_q);
    u_mul : shiftaddmul4bit port map (clk => GClock, reset => GReset, a => OperandA, b => OperandB, y => product, done => mul_done);
    u_div : divider4bit port map (clk => GClock, reset => GReset, a => OperandA, b => OperandB, quotient => quotient, remainder => remainder, done => div_done);
    addsub_8 <= "0000" & addsub_q;
    divres_8 <= remainder & quotient;
    u_mux : mux41_8bit port map (d0 => addsub_8, d1 => addsub_8, d2 => product, d3 => divres_8, sel => OperationSelect, y => mux_y);
    MuxOut <= mux_y;

    u_status : status_logic port map (opsel => OperationSelect, addsub_cout => cout_q, addsub_ovf => ovf_q, a => OperandA, b => OperandB, muxout => mux_y, carry_out => CarryOut, zero_out => ZeroOut, overflow_out => OverflowOut);
    
    op_digit <= "00" & OperationSelect;
    u_display : display_controller port map (clk100 => CLK100MHZ, d0 => mux_y(3 downto 0), d1 => mux_y(7 downto 4), d2 => "0000", d3 => "0000", d4 => op_digit, d5 => "0000", d6 => OperandB, d7 => OperandA, blank => "00101100", seg => seg, an => an);
end struct;