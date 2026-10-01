entity not_gate is
    port (
        a : in bit;
        y : out bit
    );
end not_gate;

architecture basic of not_gate is
begin
    y <= not a;
end basic;