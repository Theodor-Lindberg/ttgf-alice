library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_alice is
    port (
        ui_in   : in  std_logic_vector(7 downto 0); -- x7 x6 x5 ... x0 
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_alice;

architecture rtl of tt_um_alice is
    signal number1 : unsigned(7 downto 0); -- 0 - 255
    signal operator : std_logic_vector(1 downto 0);
    signal enter : std_logic_vector(1 downto 0);
    signal has_number : std_logic;
begin
    -- operator:
    --    00     No operator
    --    01     Plus
    --    10     Minus
    --    11     Multiplication

    -- enter:
    --    01     Enter just pressed - set to 11 at the end
    --    11     Ignore enter
    --    10     Enter released - set to 00
    --    00     No enter

    -- uio:
    --   idx 0    in, enter
    --   idx 1-2  in, operator bits
    --   idx 7    error return

    enter(0) <= uio_in(0);
    uio_oe <= "10000000"; -- 0 = insignal

    process(clk, rst_n) begin
        if rst_n = '0' then
            operator <= "00";
            number1 <= to_unsigned(0, 8);
            enter(1) <= '0';
            has_number <= '0';
        elsif rising_edge(clk) then
            if enter = "01" then
                enter(1) <= '1';
                if operator = "00" and has_number = '0' then
                    -- Assign number
                    has_number <= '1';
                    number1 <= unsigned(ui_in);
                elsif operator = "00" and has_number = '1' then
                    -- Assign operator
                    operator <= uio_in(2 downto 1);
                else
                    -- Update number, reset operator
                    operator <= "00";
                    if operator = "01" then
                        number1 <= number1 + unsigned(ui_in);
                    elsif operator = "10" then
                        number1 <= number1 - unsigned(ui_in);
                    else
                        uio_out <= "10000000";
                    end if;
                end if;
            elsif enter = "10" then
                enter(1) <= '0';
            end if;
        end if;
    end process;
    
    uo_out <= std_logic_vector(number1);

end rtl;