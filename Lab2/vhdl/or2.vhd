entity or2 is
    port (
        a, b : in bit;
        y : out bit
    );
end or2;

architecture basic of or2 is
begin
    y <= a or b;
end basic;