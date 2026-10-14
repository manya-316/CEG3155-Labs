entity xor2 is
    port (
        a, b : in bit;
        y : out bit
    );
end xor2;

architecture basic of xor2 is
begin
    y <= a xor b;
end basic;