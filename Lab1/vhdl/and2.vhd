-- and2.vhd
-- this entity is a basic and gate with two inputs,
-- where the output is the result of a boolean AND between the two inputs.

entity and2 is
    port (a, b : in bit; y : out bit);
end and2;

architecture basic of and2 is
begin
    y <= a and b;
end architecture basic;
