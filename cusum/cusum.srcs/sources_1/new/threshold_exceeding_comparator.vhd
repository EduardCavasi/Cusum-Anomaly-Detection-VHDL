----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2025 10:51:23 AM
-- Design Name: 
-- Module Name: threshold_exceeding_comparator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity threshold_exceeding_comparator is
    Port ( g_plus_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           g_plus_tvalid : in STD_LOGIC;
           g_plus_tready : out STD_LOGIC;
           g_minus_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           g_minus_tvalid : in STD_LOGIC;
           g_minus_tready : out STD_LOGIC;
           threshold_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           threshold_tvalid : in STD_LOGIC;
           threshold_tready : out STD_LOGIC;
           aclk : in STD_LOGIC;
           g_plus_out_tdata : out STD_LOGIC_VECTOR (31 downto 0);
           g_plus_out_tvalid : out STD_LOGIC;
           g_plus_out_tready : in STD_LOGIC;
           g_minus_out_tdata : out STD_LOGIC_VECTOR (31 downto 0);
           g_minus_out_tvalid : out STD_LOGIC;
           g_minus_out_tready : in STD_LOGIC;
           label_tdata : out STD_LOGIC;
           label_tvalid : out STD_LOGIC;
           label_tready : in STD_LOGIC);
end threshold_exceeding_comparator;

architecture Behavioral of threshold_exceeding_comparator is


type state_type is (S_READ, S_WRITE);
signal state : state_type := S_READ;

signal res_valid : STD_LOGIC := '0';
signal result_g_plus, result_g_minus : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal result_label: std_logic := '0';
signal a_ready, b_ready, op_ready : STD_LOGIC := '0';
signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

begin
    g_plus_tready <= external_ready;
    g_minus_tready <= external_ready;
    threshold_tready <= external_ready;
    
    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= g_plus_tvalid and g_minus_tvalid and threshold_tvalid;
    external_ready <= internal_ready and inputs_valid;
    
    label_tvalid <= '1' when state = S_WRITE else '0';
    label_tdata <= result_label;
    
    g_plus_out_tvalid <= '1' when state = S_WRITE else '0';
    g_plus_out_tdata <= result_g_plus;
    
    g_minus_out_tvalid <= '1' when state = S_WRITE else '0';
    g_minus_out_tdata <= result_g_minus;
    
    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                       report "COMPARISON PERFORMED BETWEEN A = " & integer'image(to_integer(unsigned(g_plus_tdata))) & " AND B = " & integer'image(to_integer(unsigned(g_minus_tdata)));
                       if g_plus_tdata > threshold_tdata or g_minus_tdata > threshold_tdata then
                            result_label <= '1';
                            result_g_plus <= (others => '0');
                            result_g_minus <= (others => '0');
                       else
                            result_label <= '0';
                            result_g_plus <= g_plus_tdata;
                            result_g_minus <= g_minus_tdata;
                       end if;
                       state <= S_WRITE;
                    end if;    
                when S_WRITE =>
                    if label_tready = '1' and g_plus_out_tready = '1' and g_minus_out_tready = '1' then
                        state <= S_READ;
                    end if;
            end case;
        end if;
    end process;


end Behavioral;
