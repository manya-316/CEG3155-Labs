-- dflipflop.vhd
-- Implementation of a d-flip-flop, 
-- allowing for one bit of data to be stored
-- and updated on the rising edge of a clock signal.

entity dflipflop is
    port (
        clk, reset, set, d : in bit;
        q : out bit 
    );
end dflipflop;

architecture basic of dflipflop is
begin
    storage : process (clk, reset, set)
    begin
        if reset = '1' then
            q <= '0';
        elsif set = '1' then
            q <= '1';
        elsif clk'event and clk = '1' then
            q <= d;
        end if;
    end process storage;
end basic;


    