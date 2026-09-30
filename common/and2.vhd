entity and2 is
    port (a, b : in bit; y : out bit);
end and2;

architecture basic of and2 is
begin
    y <= a and b;
end architecture basic;
