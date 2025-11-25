
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cusum_detection is
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
end cusum_detection;

architecture Behavioral of cusum_detection is
component addsub is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_operation_tvalid : IN STD_LOGIC;
    s_axis_operation_tready : OUT STD_LOGIC;
    s_axis_operation_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;
component max_0 is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;
component axis_data_fifo_0
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
end component;
component axis_broadcaster_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_tready : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) 
  );
end component;
component threshold_exceeding_comparator is
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
end component;
Signal fifo_up_stage_0_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_up_stage_0_tready, fifo_up_stage_0_tvalid: STD_LOGIC := '0';
Signal fifo_down_stage_0_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_down_stage_0_tready, fifo_down_stage_0_tvalid: STD_LOGIC := '0';
Signal sub_1_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal sub_1_result_tready, sub_1_result_tvalid: STD_LOGIC := '0';
Signal sub_1_operation_tready, add_stage_2_tready, sub_stage_2_tready, drift_tready, sub_up_stage_3_tready, sub_down_stage_3_tready, threshold_tready: STD_LOGIC := '0';
Signal fifo_stage_1_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_stage_1_tready, fifo_stage_1_tvalid: STD_LOGIC := '0';
Signal broadcast_diff_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
Signal broadcast_diff_tready, broadcast_diff_tvalid: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
Signal add_stage_2_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal add_stage_2_result_tready, add_stage_2_result_tvalid: STD_LOGIC := '0';
Signal sub_stage_2_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal sub_stage_2_result_tready, sub_stage_2_result_tvalid: STD_LOGIC := '0';
Signal fifo_add_stage_2_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_add_stage_2_result_tready, fifo_add_stage_2_result_tvalid: STD_LOGIC := '0';
Signal fifo_sub_stage_2_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_sub_stage_2_result_tready, fifo_sub_stage_2_result_tvalid: STD_LOGIC := '0';
Signal broadcast_drift_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
Signal broadcast_drift_tready, broadcast_drift_tvalid: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
Signal sub_up_stage_3_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal sub_up_stage_3_result_tready, sub_up_stage_3_result_tvalid: STD_LOGIC := '0';
Signal sub_down_stage_3_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal sub_down_stage_3_result_tready, sub_down_stage_3_result_tvalid: STD_LOGIC := '0';
Signal fifo_sub_up_stage_3_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_sub_up_stage_3_result_tready, fifo_sub_up_stage_3_result_tvalid: STD_LOGIC := '0';
Signal fifo_sub_down_stage_3_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_sub_down_stage_3_result_tready, fifo_sub_down_stage_3_result_tvalid: STD_LOGIC := '0';
Signal max_up_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal max_up_result_tready, max_up_result_tvalid: STD_LOGIC := '0';
Signal max_down_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal max_down_result_tready, max_down_result_tvalid: STD_LOGIC := '0';
Signal fifo_max_up_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_max_up_result_tready, fifo_max_up_result_tvalid: STD_LOGIC := '0';
Signal fifo_max_down_result_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_max_down_result_tready, fifo_max_down_result_tvalid: STD_LOGIC := '0';
Signal g_plus_out_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal g_plus_out_tready, g_plus_out_tvalid: STD_LOGIC := '0';
Signal g_minus_out_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal g_minus_out_tready, g_minus_out_tvalid: STD_LOGIC := '0';

Signal fifo_g_plus_tdata, fifo_g_minus_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
Signal fifo_g_plus_tvalid, fifo_g_minus_tvalid: STD_LOGIC := '0';
Signal fifo_g_plus_tready, fifo_g_minus_tready: STD_LOGIC := '0';


Signal inject_zero_up      : std_logic := '1';
Signal inject_zero_down      : std_logic := '1';

Signal inject_zero_sent_up : std_logic := '0';
Signal inject_zero_sent_down : std_logic := '0';

Signal temp_g_minus_out_tvalid, temp_g_plus_out_tvalid: std_logic := '0';
Signal temp_g_minus_out_tdata, temp_g_plus_out_tdata: std_logic_vector(31 downto 0) := (others => '0');
begin
    FIFO_UP_STAGE_0: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => s_axis_x_t_tvalid,
            s_axis_tready => s_axis_x_t_tready,
            s_axis_tdata => s_axis_x_t_tdata,
            m_axis_tvalid => fifo_up_stage_0_tvalid,
            m_axis_tready => fifo_up_stage_0_tready,
            m_axis_tdata => fifo_up_stage_0_tdata
        );
    FIFO_DOWN_STAGE_0: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => s_axis_x_t_1_tvalid,
            s_axis_tready => s_axis_x_t_1_tready,
            s_axis_tdata => s_axis_x_t_1_tdata,
            m_axis_tvalid => fifo_down_stage_0_tvalid,
            m_axis_tready => fifo_down_stage_0_tready,
            m_axis_tdata => fifo_down_stage_0_tdata
        );
    SUB_1:
        addsub port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_up_stage_0_tvalid,
            s_axis_a_tready => fifo_up_stage_0_tready,
            s_axis_a_tdata => fifo_up_stage_0_tdata,
            s_axis_b_tvalid => fifo_down_stage_0_tvalid,
            s_axis_b_tready => fifo_down_stage_0_tready,
            s_axis_b_tdata => fifo_down_stage_0_tdata,
            s_axis_operation_tvalid => '1',
            s_axis_operation_tready => sub_1_operation_tready,
            s_axis_operation_tdata => x"01",
            m_axis_result_tvalid => sub_1_result_tvalid,
            m_axis_result_tready => sub_1_result_tready,
            m_axis_result_tdata => sub_1_result_tdata
        );
    FIFO_STAGE_1: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => sub_1_result_tvalid,
            s_axis_tready => sub_1_result_tready,
            s_axis_tdata => sub_1_result_tdata,
            m_axis_tvalid => fifo_stage_1_tvalid,
            m_axis_tready => fifo_stage_1_tready,
            m_axis_tdata => fifo_stage_1_tdata
        );
    BROADCAST_DIFF:
        axis_broadcaster_0 port map(
            aclk => s_axis_aclk,
            aresetn => s_axis_aresetn,
            s_axis_tvalid => fifo_stage_1_tvalid,
            s_axis_tready => fifo_stage_1_tready,
            s_axis_tdata => fifo_stage_1_tdata,
            m_axis_tvalid => broadcast_diff_tvalid,
            m_axis_tready => broadcast_diff_tready,
            m_axis_tdata => broadcast_diff_tdata
        );
    ADD_STAGE_2:
        addsub port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_g_plus_tvalid,
            s_axis_a_tready => fifo_g_plus_tready,
            s_axis_a_tdata => fifo_g_plus_tdata,
            s_axis_b_tvalid => broadcast_diff_tvalid(1),
            s_axis_b_tready => broadcast_diff_tready(1),
            s_axis_b_tdata => broadcast_diff_tdata(63 downto 32),
            s_axis_operation_tvalid => '1',
            s_axis_operation_tready => add_stage_2_tready,
            s_axis_operation_tdata => x"00",
            m_axis_result_tvalid => add_stage_2_result_tvalid,
            m_axis_result_tready => add_stage_2_result_tready,
            m_axis_result_tdata => add_stage_2_result_tdata
        );
        process(s_axis_aclk)
        begin
            if rising_edge(s_axis_aclk) then
                if add_stage_2_result_tvalid = '1' then
                    report "ADDITION";
                end if;
            end if;
        end process;
     SUB_STAGE_2:
        addsub port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_g_minus_tvalid,
            s_axis_a_tready => fifo_g_minus_tready,
            s_axis_a_tdata => fifo_g_minus_tdata,
            s_axis_b_tvalid => broadcast_diff_tvalid(0),
            s_axis_b_tready => broadcast_diff_tready(0),
            s_axis_b_tdata => broadcast_diff_tdata(31 downto 0),
            s_axis_operation_tvalid => '1',
            s_axis_operation_tready => sub_stage_2_tready,
            s_axis_operation_tdata => x"01",
            m_axis_result_tvalid => sub_stage_2_result_tvalid,
            m_axis_result_tready => sub_stage_2_result_tready,
            m_axis_result_tdata => sub_stage_2_result_tdata
        );
    FIFO_UP_STAGE_2: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => add_stage_2_result_tvalid,
            s_axis_tready => add_stage_2_result_tready,
            s_axis_tdata => add_stage_2_result_tdata,
            m_axis_tvalid => fifo_add_stage_2_result_tvalid,
            m_axis_tready => fifo_add_stage_2_result_tready,
            m_axis_tdata => fifo_add_stage_2_result_tdata
        );
    FIFO_DOWN_STAGE_2: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => sub_stage_2_result_tvalid,
            s_axis_tready => sub_stage_2_result_tready,
            s_axis_tdata => sub_stage_2_result_tdata,
            m_axis_tvalid => fifo_sub_stage_2_result_tvalid,
            m_axis_tready => fifo_sub_stage_2_result_tready,
            m_axis_tdata => fifo_sub_stage_2_result_tdata
        );
    BROADCAST_DRIFT:
        axis_broadcaster_0 port map(
            aclk => s_axis_aclk,
            aresetn => s_axis_aresetn,
            s_axis_tvalid => '1',
            s_axis_tready => drift_tready,
            s_axis_tdata => DRIFT,
            m_axis_tvalid => broadcast_drift_tvalid,
            m_axis_tready => broadcast_drift_tready,
            m_axis_tdata => broadcast_drift_tdata
        );
    SUB_UP_STAGE_3:
        addsub port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_add_stage_2_result_tvalid,
            s_axis_a_tready => fifo_add_stage_2_result_tready,
            s_axis_a_tdata => fifo_add_stage_2_result_tdata,
            s_axis_b_tvalid => broadcast_drift_tvalid(1),
            s_axis_b_tready => broadcast_drift_tready(1),
            s_axis_b_tdata => broadcast_drift_tdata(63 downto 32),
            s_axis_operation_tvalid => '1',
            s_axis_operation_tready => sub_up_stage_3_tready,
            s_axis_operation_tdata => x"01",
            m_axis_result_tvalid => sub_up_stage_3_result_tvalid,
            m_axis_result_tready => sub_up_stage_3_result_tready,
            m_axis_result_tdata => sub_up_stage_3_result_tdata
        );
     SUB_DOWN_STAGE_3:
        addsub port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_sub_stage_2_result_tvalid,
            s_axis_a_tready => fifo_sub_stage_2_result_tready,
            s_axis_a_tdata => fifo_sub_stage_2_result_tdata,
            s_axis_b_tvalid => broadcast_drift_tvalid(0),
            s_axis_b_tready => broadcast_drift_tready(0),
            s_axis_b_tdata => broadcast_drift_tdata(31 downto 0),
            s_axis_operation_tvalid => '1',
            s_axis_operation_tready => sub_down_stage_3_tready,
            s_axis_operation_tdata => x"01",
            m_axis_result_tvalid => sub_down_stage_3_result_tvalid,
            m_axis_result_tready => sub_down_stage_3_result_tready,
            m_axis_result_tdata => sub_down_stage_3_result_tdata
        );
    FIFO_UP_STAGE_3: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => sub_up_stage_3_result_tvalid,
            s_axis_tready => sub_up_stage_3_result_tready,
            s_axis_tdata => sub_up_stage_3_result_tdata,
            m_axis_tvalid => fifo_sub_up_stage_3_result_tvalid,
            m_axis_tready => fifo_sub_up_stage_3_result_tready,
            m_axis_tdata => fifo_sub_up_stage_3_result_tdata
        );
    FIFO_DOWN_STAGE_3: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => sub_down_stage_3_result_tvalid,
            s_axis_tready => sub_down_stage_3_result_tready,
            s_axis_tdata => sub_down_stage_3_result_tdata,
            m_axis_tvalid => fifo_sub_down_stage_3_result_tvalid,
            m_axis_tready => fifo_sub_down_stage_3_result_tready,
            m_axis_tdata => fifo_sub_down_stage_3_result_tdata
        );
    MAX_UP:
        max_0 port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_sub_up_stage_3_result_tvalid,
            s_axis_a_tready => fifo_sub_up_stage_3_result_tready,
            s_axis_a_tdata => fifo_sub_up_stage_3_result_tdata,
            m_axis_result_tvalid => max_up_result_tvalid,
            m_axis_result_tready => max_up_result_tready,
            m_axis_result_tdata => max_up_result_tdata
        );
    MAX_DOWN:
        max_0 port map(
            aclk => s_axis_aclk,
            s_axis_a_tvalid => fifo_sub_down_stage_3_result_tvalid,
            s_axis_a_tready => fifo_sub_down_stage_3_result_tready,
            s_axis_a_tdata => fifo_sub_down_stage_3_result_tdata,
            m_axis_result_tvalid => max_down_result_tvalid,
            m_axis_result_tready => max_down_result_tready,
            m_axis_result_tdata => max_down_result_tdata
        );
    FIFO_UP_STAGE_4: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => max_up_result_tvalid,
            s_axis_tready => max_up_result_tready,
            s_axis_tdata => max_up_result_tdata,
            m_axis_tvalid => fifo_max_up_result_tvalid,
            m_axis_tready => fifo_max_up_result_tready,
            m_axis_tdata => fifo_max_up_result_tdata
        );
    FIFO_DOWN_STAGE_4: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => max_down_result_tvalid,
            s_axis_tready => max_down_result_tready,
            s_axis_tdata => max_down_result_tdata,
            m_axis_tvalid => fifo_max_down_result_tvalid,
            m_axis_tready => fifo_max_down_result_tready,
            m_axis_tdata => fifo_max_down_result_tdata
        );
    THRESHOLD_COMPARISON:
        threshold_exceeding_comparator port map(
            g_plus_tdata => fifo_max_up_result_tdata,
            g_plus_tvalid => fifo_max_up_result_tvalid,
            g_plus_tready => fifo_max_up_result_tready,
            g_minus_tdata => fifo_max_down_result_tdata,
            g_minus_tvalid => fifo_max_down_result_tvalid,
            g_minus_tready  => fifo_max_down_result_tready,
            threshold_tdata => THRESHOLD,
            threshold_tvalid => '1',
            threshold_tready => threshold_tready,
            aclk => s_axis_aclk,
            g_plus_out_tdata => g_plus_out_tdata,
            g_plus_out_tvalid => g_plus_out_tvalid,
            g_plus_out_tready => g_plus_out_tready,
            g_minus_out_tdata => g_minus_out_tdata,
            g_minus_out_tvalid => g_minus_out_tvalid,
            g_minus_out_tready => g_minus_out_tready,
            label_tdata => s_axis_detect_tdata,
            label_tvalid => s_axis_detect_tvalid,
            label_tready => s_axis_detect_tready
        );
        
    process(s_axis_aclk)
    begin
        if rising_edge(s_axis_aclk) then
            if s_axis_aresetn = '0' then
                inject_zero_up <= '1';
            else
                if g_plus_out_tready = '1' then
                    if inject_zero_up = '1' then
                        report "DONE INIT";
                        inject_zero_up <= '0';
                        temp_g_plus_out_tdata  <= (others => '0');
                        temp_g_plus_out_tvalid <= '1';
                    else
                        temp_g_plus_out_tdata <= g_plus_out_tdata;
                        temp_g_plus_out_tvalid <= g_plus_out_tvalid;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(s_axis_aclk)
    begin
        if rising_edge(s_axis_aclk) then
            if s_axis_aresetn = '0' then
                inject_zero_down <= '1';
            else
                if g_minus_out_tready = '1' then
                    if inject_zero_down = '1' then
                        report "DONE INIT";
                        inject_zero_down <= '0';
                        temp_g_minus_out_tdata  <= (others => '0');
                        temp_g_minus_out_tvalid <= '1';
                    else
                        temp_g_minus_out_tdata <= g_minus_out_tdata;
                        temp_g_minus_out_tvalid <= g_minus_out_tvalid;
                    end if;
                end if;
            end if;
        end if;
    end process;
    FIFO_UP_STAGE_5: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => temp_g_plus_out_tvalid,
            s_axis_tready => g_plus_out_tready,
            s_axis_tdata => temp_g_plus_out_tdata,
            m_axis_tvalid => fifo_g_plus_tvalid,
            m_axis_tready => fifo_g_plus_tready,
            m_axis_tdata => fifo_g_plus_tdata
        );
    process(s_axis_aclk)
    begin
        if rising_edge(s_axis_aclk) then
            if temp_g_plus_out_tvalid = '1' then
                report "PUSH FEEDBACK TO FIFO " & integer'image(to_integer(unsigned(temp_g_plus_out_tdata)));
            end if;
        end if;
    end process;
    FIFO_DOWN_STAGE_5: 
        axis_data_fifo_0 port map(
            s_axis_aresetn => s_axis_aresetn,
            s_axis_aclk => s_axis_aclk,
            s_axis_tvalid => temp_g_minus_out_tvalid,
            s_axis_tready => g_minus_out_tready,
            s_axis_tdata => temp_g_minus_out_tdata,
            m_axis_tvalid => fifo_g_minus_tvalid,
            m_axis_tready => fifo_g_minus_tready,
            m_axis_tdata => fifo_g_minus_tdata
        );
end Behavioral;
