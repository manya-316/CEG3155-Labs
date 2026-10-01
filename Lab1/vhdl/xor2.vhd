-- xor2.vhd
-- this entity is a basic xor gate with two inputs,
-- where the output is the result of a boolean XOR between the two inputs.

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
