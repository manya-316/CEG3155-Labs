entity mux31 is
    port (
        a0, a1, a2 : in bit_vector(7 downto 0);
        x : out bit_vector(7 downto 0);
    );
end mux31;

architecture basic of mux31 is
    mux31_behaviour : process is
    begin
        