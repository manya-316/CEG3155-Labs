-- logicOR.vhd
-- this entity is an 8-bit logical OR operation,
-- whose output is the result of a bitwise OR
-- between the inputs a and b

entity logicOR is
    port (
        a : in bit_vector(7 downto 0);
        b : in bit_vector(7 downto 0);
        y : out bit_vector(7 downto 0)
    );
end logicOR;

architecture basic of logicOR is
    component or2 is
        port (
            a, b : in bit;
            y : out bit
        );
    end component;
begin
    gen_or8: for i in 0 to 7 generate
        u_bit: or2 port map (
            a  => a(i),
            b  => b(i),
            y   => y(i)
        );
    end generate gen_or8;
end basic;