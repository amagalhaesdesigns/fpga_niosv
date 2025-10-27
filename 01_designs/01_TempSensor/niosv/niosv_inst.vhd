	component niosv is
		port (
			adt7301_MISO                                                : in    std_logic                     := 'X';             -- MISO
			adt7301_MOSI                                                : out   std_logic;                                        -- MOSI
			adt7301_SCLK                                                : out   std_logic;                                        -- SCLK
			adt7301_SS_n                                                : out   std_logic;                                        -- SS_n
			clk_50m_clk                                                 : in    std_logic                     := 'X';             -- clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_clk               : out   std_logic;                                        -- pll_mem_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk             : out   std_logic;                                        -- pll_write_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_locked                : out   std_logic;                                        -- pll_locked
			mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk_pre_phy_clk : out   std_logic;                                        -- pll_write_clk_pre_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_addr_cmd_clk          : out   std_logic;                                        -- pll_addr_cmd_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_clk               : out   std_logic;                                        -- pll_avl_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_config_clk            : out   std_logic;                                        -- pll_config_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_phy_clk           : out   std_logic;                                        -- pll_mem_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_afi_phy_clk               : out   std_logic;                                        -- afi_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_phy_clk           : out   std_logic;                                        -- pll_avl_phy_clk
			mem_if_ddr3_emif_fpga_status_local_init_done                : out   std_logic;                                        -- local_init_done
			mem_if_ddr3_emif_fpga_status_local_cal_success              : out   std_logic;                                        -- local_cal_success
			mem_if_ddr3_emif_fpga_status_local_cal_fail                 : out   std_logic;                                        -- local_cal_fail
			memory_mem_a                                                : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                                               : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                                               : out   std_logic_vector(0 downto 0);                     -- mem_ck
			memory_mem_ck_n                                             : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			memory_mem_cke                                              : out   std_logic_vector(0 downto 0);                     -- mem_cke
			memory_mem_cs_n                                             : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			memory_mem_dm                                               : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_mem_ras_n                                            : out   std_logic_vector(0 downto 0);                     -- mem_ras_n
			memory_mem_cas_n                                            : out   std_logic_vector(0 downto 0);                     -- mem_cas_n
			memory_mem_we_n                                             : out   std_logic_vector(0 downto 0);                     -- mem_we_n
			memory_mem_reset_n                                          : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                                               : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs                                              : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                                            : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                                              : out   std_logic_vector(0 downto 0);                     -- mem_odt
			oct_rzqin                                                   : in    std_logic                     := 'X';             -- rzqin
			pll_locked_export                                           : out   std_logic;                                        -- export
			reset_50m_reset_n                                           : in    std_logic                     := 'X'              -- reset_n
		);
	end component niosv;

	u0 : component niosv
		port map (
			adt7301_MISO                                                => CONNECTED_TO_adt7301_MISO,                                                --                           adt7301.MISO
			adt7301_MOSI                                                => CONNECTED_TO_adt7301_MOSI,                                                --                                  .MOSI
			adt7301_SCLK                                                => CONNECTED_TO_adt7301_SCLK,                                                --                                  .SCLK
			adt7301_SS_n                                                => CONNECTED_TO_adt7301_SS_n,                                                --                                  .SS_n
			clk_50m_clk                                                 => CONNECTED_TO_clk_50m_clk,                                                 --                           clk_50m.clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_clk               => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_clk,               -- mem_if_ddr3_emif_fpga_pll_sharing.pll_mem_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk             => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk,             --                                  .pll_write_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_locked                => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_locked,                --                                  .pll_locked
			mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk_pre_phy_clk => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk_pre_phy_clk, --                                  .pll_write_clk_pre_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_addr_cmd_clk          => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_addr_cmd_clk,          --                                  .pll_addr_cmd_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_clk               => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_clk,               --                                  .pll_avl_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_config_clk            => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_config_clk,            --                                  .pll_config_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_phy_clk           => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_phy_clk,           --                                  .pll_mem_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_afi_phy_clk               => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_afi_phy_clk,               --                                  .afi_phy_clk
			mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_phy_clk           => CONNECTED_TO_mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_phy_clk,           --                                  .pll_avl_phy_clk
			mem_if_ddr3_emif_fpga_status_local_init_done                => CONNECTED_TO_mem_if_ddr3_emif_fpga_status_local_init_done,                --      mem_if_ddr3_emif_fpga_status.local_init_done
			mem_if_ddr3_emif_fpga_status_local_cal_success              => CONNECTED_TO_mem_if_ddr3_emif_fpga_status_local_cal_success,              --                                  .local_cal_success
			mem_if_ddr3_emif_fpga_status_local_cal_fail                 => CONNECTED_TO_mem_if_ddr3_emif_fpga_status_local_cal_fail,                 --                                  .local_cal_fail
			memory_mem_a                                                => CONNECTED_TO_memory_mem_a,                                                --                            memory.mem_a
			memory_mem_ba                                               => CONNECTED_TO_memory_mem_ba,                                               --                                  .mem_ba
			memory_mem_ck                                               => CONNECTED_TO_memory_mem_ck,                                               --                                  .mem_ck
			memory_mem_ck_n                                             => CONNECTED_TO_memory_mem_ck_n,                                             --                                  .mem_ck_n
			memory_mem_cke                                              => CONNECTED_TO_memory_mem_cke,                                              --                                  .mem_cke
			memory_mem_cs_n                                             => CONNECTED_TO_memory_mem_cs_n,                                             --                                  .mem_cs_n
			memory_mem_dm                                               => CONNECTED_TO_memory_mem_dm,                                               --                                  .mem_dm
			memory_mem_ras_n                                            => CONNECTED_TO_memory_mem_ras_n,                                            --                                  .mem_ras_n
			memory_mem_cas_n                                            => CONNECTED_TO_memory_mem_cas_n,                                            --                                  .mem_cas_n
			memory_mem_we_n                                             => CONNECTED_TO_memory_mem_we_n,                                             --                                  .mem_we_n
			memory_mem_reset_n                                          => CONNECTED_TO_memory_mem_reset_n,                                          --                                  .mem_reset_n
			memory_mem_dq                                               => CONNECTED_TO_memory_mem_dq,                                               --                                  .mem_dq
			memory_mem_dqs                                              => CONNECTED_TO_memory_mem_dqs,                                              --                                  .mem_dqs
			memory_mem_dqs_n                                            => CONNECTED_TO_memory_mem_dqs_n,                                            --                                  .mem_dqs_n
			memory_mem_odt                                              => CONNECTED_TO_memory_mem_odt,                                              --                                  .mem_odt
			oct_rzqin                                                   => CONNECTED_TO_oct_rzqin,                                                   --                               oct.rzqin
			pll_locked_export                                           => CONNECTED_TO_pll_locked_export,                                           --                        pll_locked.export
			reset_50m_reset_n                                           => CONNECTED_TO_reset_50m_reset_n                                            --                         reset_50m.reset_n
		);

