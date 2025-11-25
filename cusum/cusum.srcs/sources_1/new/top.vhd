library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        btn_inc: in std_logic;
        clk: in std_logic;
        rst: in std_logic;
        cat: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0)
    );
end top;

architecture Behavioral of top is
component cusum_detection is
    Generic(DRIFT: std_logic_vector(31 downto 0) := x"00000032";
            THRESHOLD: std_logic_vector(31 downto 0) := x"000000C8");
    Port ( s_axis_x_t_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           s_axis_x_t_tvalid: in STD_LOGIC;
           s_axis_x_t_tready: out STD_LOGIC;
           s_axis_x_t_1_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           s_axis_x_t_1_tvalid: in STD_LOGIC;
           s_axis_x_t_1_tready: out STD_LOGIC;
           s_axis_aclk : in STD_LOGIC;
           s_axis_aresetn: in STD_LOGIC;
           s_axis_detect_tdata : out STD_LOGIC;
           s_axis_detect_tvalid: out STD_LOGIC;
           s_axis_detect_tready: in STD_LOGIC);
end component;
component debouncer is
  Port ( clk : in std_logic;
        btn : in std_logic;
        en : out std_logic );
end component;
component display_7seg is
    Port ( digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC;
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0));
end component;
component counter is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (10 downto 0));
end component;
component rom is
    Port ( address : in STD_LOGIC_VECTOR (10 downto 0);
           dout_curr : out STD_LOGIC_VECTOR (31 downto 0);
           dout_prev : out STD_LOGIC_VECTOR (31 downto 0));
end component;
Signal debounced_btn: std_logic := '0';
Signal address: std_logic_vector(10 downto 0) := (others => '0');
Signal dout_curr, dout_prev: std_logic_vector(31 downto 0) := (others => '0');
Signal curr_valid, prev_valid: std_logic := '1';
Signal curr_ready, prev_ready: std_logic := '0';
Signal nrst: std_logic := not rst;
Signal detect_label: std_logic := '0';
Signal detect_valid: std_logic := '0';
Signal detect_ready: std_logic := '1';
Signal display_label, high_address_bytes: std_logic_vector(3 downto 0) := "0000";

begin
    DEBOUNCE: debouncer port map(clk => clk, btn => btn_inc, en => debounced_btn);
    GET_ADDRESS: counter port map(en => debounced_btn, clk => clk, rst => rst, count => address);
    MEMORY: rom port map(address => address, dout_curr => dout_curr, dout_prev => dout_prev);
    DETECT: cusum_detection 
        generic map(
            DRIFT => x"00000032",
            THRESHOLD => x"000000C8"
        )
        port map(
           s_axis_x_t_tdata => dout_curr,
           s_axis_x_t_tvalid => curr_valid,
           s_axis_x_t_tready => curr_ready,
           s_axis_x_t_1_tdata => dout_prev,
           s_axis_x_t_1_tvalid => prev_valid,
           s_axis_x_t_1_tready => prev_ready,
           s_axis_aclk => clk,
           s_axis_aresetn => nrst,
           s_axis_detect_tdata => detect_label,
           s_axis_detect_tvalid => detect_valid,
           s_axis_detect_tready => detect_ready
        );
    display_label <= "000" & detect_label;
    high_address_bytes <= '0' & address(10 downto 8);
    DISPLAY: display_7seg port map(
        digit0 => display_label,
        digit1 => address(3 downto 0),
        digit2 => address(7 downto 4),
        digit3 => high_address_bytes,
        clk => clk,
        cat => cat,
        an => an
    );
end Behavioral;
