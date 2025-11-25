library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
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
Signal s_axis_x_t_tdata, s_axis_x_t_1_tdata: std_logic_vector(31 downto 0) := (others => '0');
Signal s_axis_x_t_tvalid, s_axis_x_t_tready, s_axis_x_t_1_tvalid, s_axis_x_t_1_tready: std_logic := '0';
Signal s_axis_aclk: std_logic := '0';
Signal s_axis_aresetn: std_logic := '0';
Signal s_axis_detect_tdata, s_axis_detect_tvalid: std_logic := '0';
Signal s_axis_detect_tready: std_logic := '1';
signal end_of_reading : std_logic := '0';
signal rd_count, wr_count : integer := 0;

constant T: time := 20ns;

signal last_tdata: std_logic_vector(31 downto 0);

begin
    process
    begin
        s_axis_aresetn <= '0';
        wait for 50ns;
        s_axis_aresetn <= '1';
        wait;
    end process;
    s_axis_detect_tready <= '1';
    s_axis_aclk <= not s_axis_aclk after T / 2;
    process(s_axis_aclk)
        file test_data : text open read_mode is "binary_temperatures_BMP180.csv";
        variable in_line : line;
        variable val: integer;
        variable space : character;
        variable comma : character;
    begin
         if rising_edge(s_axis_aclk) then
            if end_of_reading = '0' then 
                if not endfile(test_data) then  
                    if rd_count = 0 then
                        readline(test_data, in_line);
                        read(in_line, val);
                        last_tdata <= std_logic_vector(to_signed(val, 32));
                        rd_count <= rd_count + 1;
                    else
                       if s_axis_x_t_tready = '1' and s_axis_x_t_1_tready = '1' then
                            readline(test_data, in_line);
                            read(in_line, val);
                            s_axis_x_t_1_tdata <= last_tdata;
                            s_axis_x_t_1_tvalid <= '1';
                            s_axis_x_t_tdata <= std_logic_vector(to_signed(val, 32));
                            s_axis_x_t_tvalid <= '1';
                            last_tdata <= std_logic_vector(to_signed(val, 32));
                            rd_count <= rd_count + 1;
                       end if;
                    end if;
                else
                    file_close(test_data);
                    end_of_reading <= '1';
                end if;   
            end if;
         end if;
    end process;
    DETECTION:
        cusum_detection generic map (
            DRIFT => x"00000032",
            THRESHOLD => x"000000C8"
        )
                        port map(
            s_axis_x_t_tdata => s_axis_x_t_tdata,
            s_axis_x_t_tvalid => s_axis_x_t_tvalid,
            s_axis_x_t_tready => s_axis_x_t_tready,
            s_axis_x_t_1_tdata => s_axis_x_t_1_tdata,
            s_axis_x_t_1_tvalid => s_axis_x_t_1_tvalid,
            s_axis_x_t_1_tready => s_axis_x_t_1_tready,
            s_axis_aclk => s_axis_aclk,
            s_axis_aresetn => s_axis_aresetn,
            s_axis_detect_tdata => s_axis_detect_tdata,
            s_axis_detect_tvalid => s_axis_detect_tvalid,
            s_axis_detect_tready => s_axis_detect_tready  
        );
        
    process
        file results : text open write_mode is "results.csv";
        variable out_line : line;
    begin
        wait until rising_edge(s_axis_aclk);
        if wr_count <= rd_count then
            if s_axis_detect_tvalid = '1' then   -- write the result only when it is valid
        
                write(out_line, wr_count);
                write(out_line, string'(", "));
                write(out_line, s_axis_detect_tdata);
                writeline(results, out_line);
                
                wr_count <= wr_count + 1;
            end if;
        else
            file_close(results);
            report "execution finished...";
            wait;
        end if;

    end process;

end Behavioral;
