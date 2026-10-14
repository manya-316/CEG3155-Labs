entity dff is 
    port (
        clk, clr, pre, d: in bit;
        q: out bit
    );
end dff;

architecture basic of dff is 
begin
    process(clk, clr, pre)
    begin
        if clr = '1' then
            q <= '0';
        elsif pre = '1' then
            q <= '1';
        elsif clk'event and clk = '1' then
            q <= d;
        end if;
    end process;
end basic;