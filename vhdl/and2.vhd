entity and2 is
    port (a, b : in bit; y : out bit);
end and2;

architecture basic of and2 is
begin
    and2_behaviour : process is
    begin
        y <= a and b;
        wait on a, b;
    end process and2_behaviour;
end architecture basic;
