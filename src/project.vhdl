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
    component sqrt_rom is
        port (
            address : in  std_logic_vector(7 downto 0);
            data    : out std_logic_vector(7 downto 0)
        );
    end component;

    component exp_rom is
        port (
            address : in  std_logic_vector(7 downto 0);
            data    : out std_logic_vector(7 downto 0)
        );
    end component;

    component log_rom is
        port (
            address : in  std_logic_vector(7 downto 0);
            data    : out std_logic_vector(7 downto 0)
        );
    end component;

    signal number1 : unsigned(7 downto 0); -- 0 - 255
    signal operator : std_logic_vector(2 downto 0);
    signal enter : std_logic_vector(1 downto 0);
    signal has_number : std_logic;
    signal sqrt_data : std_logic_vector(7 downto 0);
    signal exp_data  : std_logic_vector(7 downto 0);
    signal log_data  : std_logic_vector(7 downto 0);
begin
    -- operator:
    --    000     No operator      ok
    --    001     Plus             ok
    --    010     Minus            ok
    --    011     Multiplication   ok
    --    100     Division         ok
    --    101     sqrt(x)
    --    110     e^(x)
    --    111     loge(x)

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

    sqrt_lookup : sqrt_rom
        port map (
            address => std_logic_vector(number1),
            data    => sqrt_data
        );

    exp_lookup : exp_rom
        port map (
            address => std_logic_vector(number1),
            data    => exp_data
        );

    log_lookup : log_rom
        port map (
            address => std_logic_vector(number1),
            data    => log_data
        );

    process(clk, rst_n) begin
        if rst_n = '0' then
            operator <= "000";
            number1 <= to_unsigned(0, 8);
            enter(1) <= '0';
            has_number <= '0';
        elsif rising_edge(clk) then
            if enter = "01" then
                enter(1) <= '1';
                if operator = "000" and has_number = '0' then
                    -- Assign number
                    has_number <= '1';
                    number1 <= unsigned(ui_in);
                elsif operator = "000" and has_number = '1' then
                    -- Either to the operation directly, or assign the operator
                    if uio_in(3 downto 1) = "101" then -- sqrt(x)
                        number1 <= unsigned(sqrt_data);
                    elsif uio_in(3 downto 1) = "110" then -- e^(x)
                        number1 <= unsigned(exp_data);
                    elsif uio_in(3 downto 1) = "111" then -- loge(x)
                        number1 <= unsigned(log_data);
                    else
                        operator <= uio_in(3 downto 1);
                    end if;
                else
                    -- Update number, reset operator
                    operator <= "000";
                    if operator = "001" then -- Addition
                        number1 <= number1 + unsigned(ui_in);
                    elsif operator = "010" then -- Subtraction
                        number1 <= number1 - unsigned(ui_in);
                    elsif operator = "011" then -- Multiplication
                        number1 <= to_unsigned(0, 8);--resize(number1 * unsigned(ui_in), 8);
                    elsif operator = "100" then -- Division
                        number1 <= to_unsigned(0, 8);--resize(number1 / unsigned(ui_in), 8);
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