entity shiftaddmul4bit is
    port (
        a, b : in bit_vector(3 downto 0);
        y : out bit_vector (7 downto 0)
    );
end shiftaddmul4bit;

architecture struct of shiftaddmul4bit is
    component rippleaddsub4bit is
        port (
            a, b : in bit_vector(7 downto 0);
            sub : in bit;
            s : out bit_vector(7 downto 0);
            cout : out bit
        );
    end component;

begin
end struct;