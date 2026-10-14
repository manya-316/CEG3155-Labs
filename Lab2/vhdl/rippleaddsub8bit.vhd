--8-bit adder/subtractor for the multiplier's product register
entity rippleaddsub8bit is
    port (
        a, b : in bit_vector(7 downto 0);
        sub : in bit;
        s : out bit_vector(7 downto 0);
        cout : out bit;
        ovf : out bit
    );
end rippleaddsub8bit;

architecture basic of rippleaddsub8bit is 
    component rippleadder4bit is
        port (
            a, b : in bit_vector(3 downto 0);
            cin : in bit;
            s : out bit_vector(3 downto 0);
            cout : out bit;
            ovf : out bit
        );
    end component;

    component xor2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
    signal b_xor_sub : bit_vector(7 downto 0);
    signal c_mid : bit;
    signal ovf_low : bit;
begin
    b_xor_gen : for i in 0 to 7 generate
        xor_inst : xor2 port map(
            a => b(i),
            b => sub,
            y => b_xor_sub(i)
        );
    end generate b_xor_gen;

    low_half : rippleadder4bit port map(
        a => a(3 downto 0),
        b => b_xor_sub(3 downto 0),
        cin => sub,
        s => s(3 downto 0),
        cout => c_mid,
        ovf => ovf_low
    );
    high_half : rippleadder4bit port map(
        a => a(7 downto 4),
        b => b_xor_sub(7 downto 4),
        cin => c_mid,
        s => s(7 downto 4),
        cout => cout,
        ovf => ovf
    );
end basic;