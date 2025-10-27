
module niosv (
	adt7301_MISO,
	adt7301_MOSI,
	adt7301_SCLK,
	adt7301_SS_n,
	clk_50m_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_locked,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk_pre_phy_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_addr_cmd_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_config_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_phy_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_afi_phy_clk,
	mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_phy_clk,
	mem_if_ddr3_emif_fpga_status_local_init_done,
	mem_if_ddr3_emif_fpga_status_local_cal_success,
	mem_if_ddr3_emif_fpga_status_local_cal_fail,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_dm,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	oct_rzqin,
	pll_locked_export,
	reset_50m_reset_n);	

	input		adt7301_MISO;
	output		adt7301_MOSI;
	output		adt7301_SCLK;
	output		adt7301_SS_n;
	input		clk_50m_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_locked;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_write_clk_pre_phy_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_addr_cmd_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_config_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_mem_phy_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_afi_phy_clk;
	output		mem_if_ddr3_emif_fpga_pll_sharing_pll_avl_phy_clk;
	output		mem_if_ddr3_emif_fpga_status_local_init_done;
	output		mem_if_ddr3_emif_fpga_status_local_cal_success;
	output		mem_if_ddr3_emif_fpga_status_local_cal_fail;
	output	[14:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output	[0:0]	memory_mem_ck;
	output	[0:0]	memory_mem_ck_n;
	output	[0:0]	memory_mem_cke;
	output	[0:0]	memory_mem_cs_n;
	output	[3:0]	memory_mem_dm;
	output	[0:0]	memory_mem_ras_n;
	output	[0:0]	memory_mem_cas_n;
	output	[0:0]	memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[31:0]	memory_mem_dq;
	inout	[3:0]	memory_mem_dqs;
	inout	[3:0]	memory_mem_dqs_n;
	output	[0:0]	memory_mem_odt;
	input		oct_rzqin;
	output		pll_locked_export;
	input		reset_50m_reset_n;
endmodule
