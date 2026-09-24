entity DisplayRegister is
    port (
        clk : in bit;
        reset : in bit;
        load : in bit;
        d0, d1, d2, d3, d4, d5, d6, d7 : in bit;
        q0, q1, q2, q3, q4, q5, q6, q7 : out bit);
end DisplayRegister;

architecture default of DisplayRegister is
    storage : process is 
        variable stored_d0, stored_d1, stored_d2, stored_d3, stored_d4, stored_d5, stored_d6, stored_d7 : bit;
    begin
        if clk = '1' then
            if load = '1' then
                stored_d0 := d0;
                stored_d1 := d1;
                stored_d2 := d2;
                stored_d3 := d3;
                stored_d4 := d4;
                stored_d5 := d5;
                stored_d6 := d6;
                stored_d7 := d7;
            elsif reset = '1' then
                stored_d0 := '0';
                stored_d1 := '0';
                stored_d2 := '0';
                stored_d3 := '0';
                stored_d4 := '0';
                stored_d5 := '0';
                stored_d6 := '0';
                stored_d7 := '0';
            end if;
        end if;

        q0 <= stored_d0;
        q1 <= stored_d1;
        q2 <= stored_d2;
        q3 <= stored_d3;
        q4 <= stored_d4;
        q5 <= stored_d5;
        q6 <= stored_d6;
        q7 <= stored_d7;

        wait on clk, d0, d1, d2, d3, d4, d5, d6, d7, load, reset;
    end process storage;
end architecture default;