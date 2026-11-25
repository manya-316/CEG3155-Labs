--display controller builds a 7-segment display driver for the DE2 board. It takes 8 4-bit inputs (d0..d7) and an 8-bit blanking input, and multiplexes them onto the 7-segment display. The refresh rate is set to about 100 Hz.
entity display_controller is
    port (
        clk100 : in bit;
        d0, d1, d2, d3, d4, d5, d6, d7 : in bit_vector(3 downto 0);
        blank : in bit_vector(7 downto 0);
        seg : out bit_vector(6 downto 0);                  -- CA..CG
        an : out bit_vector(7 downto 0)                    -- AN0..AN7
    );
end display_controller;

architecture behavioural of display_controller is
    signal refresh : integer range 0 to 1048575 := 0;     -- 20-bit counter
    signal digit : integer range 0 to 7;
    signal nyb : bit_vector(3 downto 0);
begin
    -- free-running refresh counter
    process (clk100)
    begin
        if clk100'event and clk100 = '1' then
            if refresh = 1048575 then
                refresh <= 0;
            else
                refresh <= refresh + 1;
            end if;
        end if;
    end process;

    digit <= refresh / 131072;                             -- bits 19..17

    -- pick the value and anode for the active digit
    process (digit, d0, d1, d2, d3, d4, d5, d6, d7, blank)
    begin
        an <= "11111111";
        case digit is
            when 0 => nyb <= d0; an(0) <= blank(0);
            when 1 => nyb <= d1; an(1) <= blank(1);
            when 2 => nyb <= d2; an(2) <= blank(2);
            when 3 => nyb <= d3; an(3) <= blank(3);
            when 4 => nyb <= d4; an(4) <= blank(4);
            when 5 => nyb <= d5; an(5) <= blank(5);
            when 6 => nyb <= d6; an(6) <= blank(6);
            when 7 => nyb <= d7; an(7) <= blank(7);
        end case;
    end process;

    -- hex digit to active-low segments (Appendix F, Table 1)
    with nyb select seg <=
        "1000000" when "0000", "1111001" when "0001",
        "0100100" when "0010", "0110000" when "0011",
        "0011001" when "0100", "0010010" when "0101",
        "0000010" when "0110", "1111000" when "0111",
        "0000000" when "1000", "0010000" when "1001",
        "0001000" when "1010", "0000011" when "1011",
        "1000110" when "1100", "0100001" when "1101",
        "0000110" when "1110", "0001110" when others;
end behavioural;