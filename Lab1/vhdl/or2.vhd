-- or2.vhd
-- this entity is a basic or gate with two inputs,
-- where the output is the result of a boolean OR between the two inputs.

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