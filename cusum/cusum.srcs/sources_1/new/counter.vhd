library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (10 downto 0));
end counter;

architecture Behavioral of counter is
Signal internal_count: std_logic_vector(10 downto 0) := "00000000001";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            internal_count <= (others => '0');
        else
            if rising_edge(clk) then
                if en = '1' then
                    internal_count <= internal_count + 1;
                end if;
            end if;
        end if;
        count <= internal_count;
    end process;

end Behavioral;
