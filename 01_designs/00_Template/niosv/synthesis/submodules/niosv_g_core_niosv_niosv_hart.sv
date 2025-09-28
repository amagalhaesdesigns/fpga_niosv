// (C) 2001-2023 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// TODO: DO all TODO's and remove TODO's
`default_nettype none
`timescale 1 ns / 1 ns
import niosv_opcode_def::*;
import niosv_g_fp_def::*;

module niosv_g_core_niosv_niosv_hart # (
   parameter DBG_EXPN_VECTOR          = 32'h80000000,
   parameter RESET_VECTOR             = 32'h00000000,
   parameter CORE_EXTN                = 26'h0000100,  // RV32I
   parameter DEBUG_ENABLED            = 1'b0,
   parameter DEVICE_FAMILY            = "Stratix 10",
   parameter DBG_PARK_LOOP_OFFSET     = 32'd24,
   parameter USE_RESET_REQ            = 1'b0,
   parameter BOUNDARY_ADDRESS         = 32'h0000C000,
   parameter CACHE_ABOVE_RANGE        = 1'b1,

   parameter DBG_DATA_S_BASE          = 32'h000A0000,
   parameter TIMER_MSIP_DATA_S_BASE   = 32'h000B0000,
   parameter DATA_CACHE_SIZE          = 4096,
   parameter INST_CACHE_SIZE          = 4096,
   parameter ITCM1_SIZE               = 0,
   parameter ITCM1_BASE               = 32'h0,
   parameter ITCM1_INIT_FILE          = "UNUSED",
   parameter ITCM2_SIZE               = 0,
   parameter ITCM2_BASE               = 32'h0,
   parameter ITCM2_INIT_FILE          = "UNUSED",
   parameter PERIPHERAL_REGION_A_SIZE = 0,
   parameter PERIPHERAL_REGION_A_BASE = 32'h0,
   parameter PERIPHERAL_REGION_B_SIZE = 0,
   parameter PERIPHERAL_REGION_B_BASE = 32'h0,
   parameter DTCM1_SIZE               = 0,
   parameter DTCM1_BASE               = 32'h0,
   parameter DTCM1_INIT_FILE          = "UNUSED",
   parameter DTCM2_SIZE               = 0,
   parameter DTCM2_BASE               = 32'h0,
   parameter DTCM2_INIT_FILE          = "UNUSED",
   parameter ECC_EN                   = 1'b0,
   parameter ITCS1_ADDR_WIDTH         = 4'd10,
   parameter ITCS2_ADDR_WIDTH         = 4'd10,
   parameter DTCS1_ADDR_WIDTH         = 4'd10,
   parameter DTCS2_ADDR_WIDTH         = 4'd10
) (
   input  wire clk,
   input  wire reset,
   input  wire reset_req,
   output wire reset_req_ack,

   // Instruction Interface
   // TODO: Replace interface with AXI4-(Lite??) Interface; *W, B* channels
   // terminated not used.

   // write command
   //    address
   output wire [31:0]                 instr_awaddr,
   output wire [2:0]                  instr_awprot,
   output wire                        instr_awvalid,
   output wire [2:0]                  instr_awsize,
   output wire [7:0]                  instr_awlen,
   output wire [1:0]                  instr_awburst,
   input  wire                        instr_awready,
   //  data
   output wire                        instr_wvalid,
   output wire [31:0]                 instr_wdata,
   output wire [3:0]                  instr_wstrb,
   output wire                        instr_wlast,
   input  wire                        instr_wready,

   //write response
   input  wire                        instr_bvalid,
   input  wire [1:0]                  instr_bresp,
   output wire                        instr_bready,

   //read command
   output wire [31:0]                 instr_araddr,
   output wire [2:0]                  instr_arprot,
   output wire                        instr_arvalid,
   output wire [2:0]                  instr_arsize,
   output wire [7:0]                  instr_arlen,
   output wire [1:0]                  instr_arburst,
   input  wire                        instr_arready,

   //read response
   input  wire [31:0]                 instr_rdata,
   input  wire                        instr_rvalid,
   input  wire [1:0]                  instr_rresp,
   input  wire                        instr_rlast,
   output wire                        instr_rready,

   // write command
   //    address
   output wire [ADDR_W-1:0]           data_awaddr,
   output wire [2:0]                  data_awprot,
   output wire                        data_awvalid,
   output wire [2:0]                  data_awsize,
   output wire [7:0]                  data_awlen,
   input  wire                        data_awready,
   //  data
   output wire                        data_wvalid,
   output wire [DATA_W-1:0]           data_wdata,
   output wire [3:0]                  data_wstrb,
   output wire                        data_wlast,
   input  wire                        data_wready,

   //write response
   input  wire                        data_bvalid,
   input  wire [1:0]                  data_bresp,
   output wire                        data_bready,

   //read command
   output wire [ADDR_W-1:0]           data_araddr,
   output wire [2:0]                  data_arprot,
   output wire                        data_arvalid,
   output wire [2:0]                  data_arsize,
   output wire [7:0]                  data_arlen,
   input  wire                        data_arready,

   //read response
   input  wire [DATA_W-1:0]           data_rdata,
   input  wire                        data_rvalid,
   input  wire [1:0]                  data_rresp,
   input  wire                        data_rlast,
   output wire                        data_rready,

   input wire                         irq_timer,
   input wire                         irq_sw,
   input wire [15:0]                  irq_plat_vec,
   input wire                         irq_ext,

   input wire                         irq_debug,

   output wire [31:0]                 core_ci_data0,
   output wire [31:0]                 core_ci_data1,
   output wire [31:0]                 core_ci_alu_result,
   output wire [31:0]                 core_ci_ctrl,
   output wire                        core_ci_enable,
   output wire [3:0]                  core_ci_op,
   input  wire                        core_ci_done,
   input  wire [31:0]                 core_ci_result,

   output wire [3:0]                  core_ecc_src,
   output wire [1:0]                  core_ecc_status,

   // axi4-lite interface to access ITCM1
   // write command
   //    address
   input  wire [ITCS1_ADDR_WIDTH-1:0] itcs1_awaddr,
   input  wire [2:0]                  itcs1_awprot,
   input  wire                        itcs1_awvalid,
   output wire                        itcs1_awready,

   //  data
   input  wire                        itcs1_wvalid,
   input  wire [31:0]                 itcs1_wdata,
   input  wire [3:0]                  itcs1_wstrb,
   output wire                        itcs1_wready,

   //write response
   output wire                        itcs1_bvalid,
   output wire [1:0]                  itcs1_bresp,
   input  wire                        itcs1_bready,

   //read command
   input  wire [ITCS1_ADDR_WIDTH-1:0] itcs1_araddr,
   input  wire [2:0]                  itcs1_arprot,
   input  wire                        itcs1_arvalid,
   output wire                        itcs1_arready,

   //read response
   output wire [31:0]                 itcs1_rdata,
   output wire                        itcs1_rvalid,
   output wire [1:0]                  itcs1_rresp,
   input  wire                        itcs1_rready,

   // axi4-lite interface to access ITCM2
   // write command
   //    address
   input  wire [ITCS2_ADDR_WIDTH-1:0] itcs2_awaddr,
   input  wire [2:0]                  itcs2_awprot,
   input  wire                        itcs2_awvalid,
   output wire                        itcs2_awready,
   //  data
   input  wire                        itcs2_wvalid,
   input  wire [31:0]                 itcs2_wdata,
   input  wire [3:0]                  itcs2_wstrb,
   output wire                        itcs2_wready,

   //write response
   output wire                        itcs2_bvalid,
   output wire [1:0]                  itcs2_bresp,
   input  wire                        itcs2_bready,

   //read command
   input  wire [ITCS2_ADDR_WIDTH-1:0] itcs2_araddr,
   input  wire [2:0]                  itcs2_arprot,
   input  wire                        itcs2_arvalid,
   output wire                        itcs2_arready,

   //read response
   output wire [31:0]                 itcs2_rdata,
   output wire                        itcs2_rvalid,
   output wire [1:0]                  itcs2_rresp,
   input  wire                        itcs2_rready,

   // axi4-lite interface to access DTCM1
   // write command
   //    address
   input  wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_awaddr,
   input  wire [2:0]                  dtcs1_awprot,
   input  wire                        dtcs1_awvalid,
   output wire                        dtcs1_awready,

   //  data
   input  wire                        dtcs1_wvalid,
   input  wire [31:0]                 dtcs1_wdata,
   input  wire [3:0]                  dtcs1_wstrb,
   output wire                        dtcs1_wready,

   //write response
   output wire                        dtcs1_bvalid,
   output wire [1:0]                  dtcs1_bresp,
   input  wire                        dtcs1_bready,

   //read command
   input  wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_araddr,
   input  wire [2:0]                  dtcs1_arprot,
   input  wire                        dtcs1_arvalid,
   output wire                        dtcs1_arready,

   //read response
   output wire [31:0]                 dtcs1_rdata,
   output wire                        dtcs1_rvalid,
   output wire [1:0]                  dtcs1_rresp,
   input  wire                        dtcs1_rready,

   // axi4-lite interface to access DTCM2
   // write command
   //    address
   input  wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_awaddr,
   input  wire [2:0]                  dtcs2_awprot,
   input  wire                        dtcs2_awvalid,
   output wire                        dtcs2_awready,

   //  data
   input  wire                        dtcs2_wvalid,
   input  wire [31:0]                 dtcs2_wdata,
   input  wire [3:0]                  dtcs2_wstrb,
   output wire                        dtcs2_wready,

   //write response
   output wire                        dtcs2_bvalid,
   output wire [1:0]                  dtcs2_bresp,
   input  wire                        dtcs2_bready,

   //read command
   input  wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_araddr,
   input  wire [2:0]                  dtcs2_arprot,
   input  wire                        dtcs2_arvalid,
   output wire                        dtcs2_arready,

   //read response
   output wire [31:0]                 dtcs2_rdata,
   output wire                        dtcs2_rvalid,
   output wire [1:0]                  dtcs2_rresp,
   input  wire                        dtcs2_rready
);

   localparam RAM_TYPE = ((DEVICE_FAMILY == "Arria 10") || (DEVICE_FAMILY == "Arria V GZ")  || (DEVICE_FAMILY == "Stratix V")) ? "M20K" :
                         ((DEVICE_FAMILY == "Arria V" ) || (DEVICE_FAMILY == "Cyclone V")) ? "M10K" :
                         ((DEVICE_FAMILY == "Arria II GX" ) || (DEVICE_FAMILY == "Arria II GZ") || (DEVICE_FAMILY == "Cyclone 10 LP") || (DEVICE_FAMILY == "Cyclone IV E") ||
                          (DEVICE_FAMILY == "Cyclone IV GX") || (DEVICE_FAMILY == "MAX 10") || (DEVICE_FAMILY == "Stratix IV")) ? "M9K" : "AUTO";

   localparam NUM_REG = get_num_gpr(CORE_EXTN);
   localparam RF_ADDR_W = $clog2(NUM_REG);
   // localparam LOCAL_RST_DEPTH = 8;
   localparam ATOMIC_ENABLED = CORE_EXTN[RV_A];
   localparam MULDIV_ENABLED = CORE_EXTN[RV_M];
   localparam FLOAT_ENABLED  = CORE_EXTN[RV_F];

   localparam DBG_PARK_LOOP = DBG_EXPN_VECTOR + DBG_PARK_LOOP_OFFSET;
   localparam RST_REQ_DEPTH = 16;

   wire internal_reset;

   wire core_nmi_irq = 1'b0;

   // register file signals
   wire [RF_ADDR_W-1:0] rd_reg_a;
   wire [RF_ADDR_W-1:0] rd_reg_b;
   wire [RF_ADDR_W-1:0] rd_reg_c;  // only applies to FPR

   wire [DATA_W-1:0]    rd_gpr_data_a;
   wire [DATA_W-1:0]    rd_gpr_data_b;
   wire                 wr_gpr_en;
   wire [RF_ADDR_W-1:0] wr_gpr;
   wire [DATA_W-1:0]    wr_gpr_data;

   wire [FP32_W-1:0]    rd_fpr_data_a;
   wire [FP32_W-1:0]    rd_fpr_data_b;
   wire [FP32_W-1:0]    rd_fpr_data_c;
   wire                 wr_fpr_en;
   wire [RF_ADDR_W-1:0] wr_fpr;
   wire [FP32_W-1:0]    wr_fpr_data;

   wire       D_ready;
   wire       E_ready;
   wire       M0_ready;
   wire       W_ready;

   logic      I_instr_valid;
   reg        D_instr_valid;
   reg        E_instr_valid;
   reg        M0_instr_valid;
   reg        W_instr_valid;

   logic [31:0] I_instr_pc;
   reg   [31:0] D_instr_pc;
   reg   [31:0] D_instr_pc_nxt;
   reg   [31:0] E_instr_pc;
   reg   [31:0] E_nxt_seq_pc;
   reg   [31:0] M0_nxt_seq_pc;
   reg   [31:0] M0_instr_pc;
   reg   [31:0] M0_nxt_pc;
   reg   [31:0] W_instr_pc;

   logic [31:0] nxt_instr_pc;
   reg   [31:0] nxt_I_instr_pc;
   reg   [31:0] nxt_D_instr_pc;
   reg   [31:0] nxt_E_instr_pc;
   reg   [31:0] nxt_M0_instr_pc;
   reg   [31:0] nxt_W_instr_pc;

   reg   [31:0] jmp_I_instr_pc;
   reg   [31:0] jmp_D_instr_pc;
   reg   [31:0] jmp_E_instr_pc;
   reg   [31:0] jmp_M0_instr_pc;
   reg   [31:0] jmp_W_instr_pc;

   logic [31:0] I_instr_word;
   reg   [31:0] D_instr_word;
   reg   [31:0] E_instr_word;
   reg   [31:0] M0_instr_word;
   reg   [31:0] W_instr_word;

   wire I_use_imm;
   reg  D_use_imm;
   wire [IMM_W-1:0] I_imm;
   reg  [IMM_W-1:0] D_imm;

   wire       I_misc_mem_op;

   wire       D_cmo_op;
   reg        E_cmo_op;
   reg        M0_cmo_op;

   wire       I_amo_op;
   reg        D_amo_op;
   reg        E_amo_op;
   logic      M0_amo_op;

   wire       D_mul_op;
   wire       D_mul_s1_signed;
   wire       D_mul_s2_signed;
   wire       D_mul_use_lsw;
   reg        E_mul_op;
   reg        E_mul_s1_signed;
   reg        E_mul_s2_signed;
   reg        E_mul_use_lsw;
   wire       E_mul_valid;

   wire       D_div_op;
   reg        E_div_op;
   reg        M0_div_op;

   wire [4:0] M0_amo_op_type = M0_instr_word[31:27];
   wire [2:0] M0_cmo_op_type = {M0_instr_word[27], M0_instr_word[21:20]};

   exe_ops_ext_t D_exe_op;
   exe_ops_ext_t E_exe_op;

   fp_op_decode_t D_fp_op_decode;
   fp_op_decode_t E_fp_op_decode;

   reg  [31:0] D_i_mtval;
   reg  [31:0] E_d_mtval;
   reg  [31:0] M0_e_mtval;
   wire [31:0] M0_mtval;
   reg  [31:0] C_expn_mtval;

   wire E_unaligned_redir;

   wire D_needs_gp_rs1;
   wire D_needs_gp_rs2;

   wire D_gpr_wr_en;
   reg  E_gpr_wr_en;
   reg  M0_gpr_wr_en;
   wire M0_gpr_wr_en_nxt;
   reg  W_gpr_wr_en;

   wire D_needs_fp_rs1;
   wire D_needs_fp_rs2;
   wire D_needs_fp_rs3;

   wire D_fpr_wr_en;
   reg  E_fpr_wr_en;
   reg  M0_fpr_wr_en;
   wire M0_fpr_wr_en_nxt;
   reg  W_fpr_wr_en;

   reg  M0_load_en;
   wire M0_load_en_nxt;

   wire [DATA_W-1:0] E_exe_result;
   wire [DATA_W-1:0] E_alu_result;
   wire [DATA_W-1:0] E_ls_addr;
   reg  [DATA_W-1:0] M0_exe_result;
   wire [DATA_W-1:0] M0_ls_addr = M0_exe_result;
   wire [DATA_W-1:0] M0_load_data;
   reg  [DATA_W-1:0] M0_gpr_result_data_nxt;
   reg  [FP32_W-1:0] M0_fpr_result_data_nxt;
   reg  [DATA_W-1:0] W_gpr_exe_result;
   reg  [DATA_W-1:0] W_fpr_exe_result;

   wire [RF_ADDR_W-1:0] D_rd;
   reg  [RF_ADDR_W-1:0] E_rd;
   reg  [RF_ADDR_W-1:0] M0_rd;
   reg  [RF_ADDR_W-1:0] W_rd;

   wire [DATA_W-1:0] D_exe_s1;
   wire [DATA_W-1:0] D_exe_s2;
   reg  [DATA_W-1:0] E_exe_s1;
   reg  [DATA_W-1:0] E_exe_s2;

   reg  [DATA_W-1:0] M0_exe_s1;
   reg  [DATA_W-1:0] M0_exe_s2;

   wire I_mem_op;
   wire I_load_op;
   wire I_store_op;
   reg  D_mem_op;
   reg  D_load_op;
   reg  D_store_op;
   wire D_long_fp_op;
   reg  D_branch_op;
   reg  E_branch_op;
   reg  E_mem_op;
   reg  E_load_op;
   reg  E_store_op;
   reg  E_long_op;
   reg  M0_mem_op;
   reg  M0_load_op;
   reg  M0_store_op;
   reg  M0_long_op;
   wire D_ebreak_instr;
   wire D_ecall_instr;
   reg  E_jmp;
   reg  E_ebreak_instr;
   reg  E_ecall_instr;
   wire D_signed_cmp;
   reg  E_signed_cmp;

   wire        M0_div_stall;
   wire        M0_mul_pending;
   wire        M0_div_pending;
   wire        M0_mul_done;
   wire        M0_div_done;
   wire [31:0] M0_mul_result;
   wire [31:0] M0_div_result;

   mem_size_t  D_mem_size;
   byteen_t    D_mem_byteen;
   wire        D_mem_signext;
   mem_size_t  E_mem_size;
   byteen_t    E_mem_byteen;
   reg         E_mem_signext;
   mem_size_t  M0_mem_size;
   byteen_t    M0_mem_byteen;
   reg         M0_mem_signext;

   logic       E_fpu_state_dirtied;    // For updates to FPU state in MSTATUS

   wire        E_fpu_to_fpr_done;
   wire [31:0] E_fpu_to_fpr_result;
   wire        E_fpu_to_gpr_done;
   wire [31:0] E_fpu_to_gpr_result;
   fp_flags_t  E_fpu_flags;
   reg         M0_fpu_to_fpr_e_done;   // FPU single-cycle instruction outputs carried in pipeline from E stage
   reg [31:0]  M0_fpu_to_fpr_e_result;
   reg         M0_fpu_to_gpr_e_done;
   reg [31:0]  M0_fpu_to_gpr_e_result;
   fp_flags_t  M0_fpu_e_flags;
   wire        M0_fpu_op_pending;      // FPU multi-cycle instruction outputs directly into Mx stage(s)
   reg         M0_fpu_to_fpr_done;
   reg [31:0]  M0_fpu_to_fpr_result;
   reg         M0_fpu_to_gpr_done;
   reg [31:0]  M0_fpu_to_gpr_result;
   fp_flags_t  M0_fpu_flags;

   logic [4:0] M0_fpu_fflags;          // For CSR interface
   logic       M0_fpu_fflags_valid;

   wire [3:0]  D_ci_op;
   reg  [3:0]  E_ci_op;
   reg  [3:0]  M0_ci_op;
   wire        M0_ci_enable = (|M0_ci_op);
   reg         M0_ci_pending;

   wire [RS1_FIELD_W-1:0]   I_iw_rs1 = I_instr_word[RS1_FIELD_H:RS1_FIELD_L];
   wire [RS2_FIELD_W-1:0]   I_iw_rs2 = I_instr_word[RS2_FIELD_H:RS2_FIELD_L];
   wire [R_RS3_FIELD_W-1:0] I_iw_rs3 = I_instr_word[R_RS3_FIELD_H:R_RS3_FIELD_L];

   reg  [RS1_FIELD_W-1:0]   D_iw_rs1;  // TODO: why register this when we're already registering D_instruction_word ??
   reg  [RS2_FIELD_W-1:0]   D_iw_rs2;
   reg  [R_RS3_FIELD_W-1:0] D_iw_rs3;

   reg  [DATA_W-1:0]        D_rs1_gpr_val;
   reg  [DATA_W-1:0]        D_rs2_gpr_val;
   reg  [FP32_W-1:0]        D_rs1_fpr_val;
   reg  [DATA_W-1:0]        D_rs2_fpr_val;
   reg  [DATA_W-1:0]        D_rs3_fpr_val;

   reg  [DATA_W-1:0]        E_rs1_gpr_val;
   reg  [DATA_W-1:0]        E_rs2_gpr_val;
   reg  [FP32_W-1:0]        E_rs1_fpr_val;
   reg  [FP32_W-1:0]        E_rs2_fpr_val;
   reg                      E_store_gpr;   // indicates that the store will take its data from a GPR, not FPR

   reg  [DATA_W-1:0]        M0_rs1_gpr_val;
   reg  [DATA_W-1:0]        M0_rs2_gpr_val;
   reg  [DATA_W-1:0]        M0_store_data;

   wire M0_ls_op_done;
   wire M0_instr_done;
   wire M0_multicycle_instr_done = 1'b0;
   wire M0_multicycle_instr_pending;

   wire M0_ls_instr_pending;

   wire D_dep_stall_from_E;
   wire D_dep_stall_from_M0;

   wire [31:0] D_branch_tgt_pc;
   wire [31:0] D_jal_tgt_pc;
   reg  [31:0] E_branch_tgt_pc;
   reg  [31:0] E_jal_tgt_pc;
   reg  [31:0] M0_branch_tgt_pc;
   reg  [31:0] M0_jal_tgt_pc;

   wire [31:0] E_redirect_pc;
   reg  [31:0] M0_redirect_pc;
   reg  [31:0] nxt_M0_redirect_pc;
   wire        E_unaligned_redirect_pc;
   wire        E_redirect;
   reg         M0_redirect;
   wire        M0_redirect_nxt;

   reg branch_redir_back;
   reg branch_redir_pndg;

   wire branch_stall;

   wire        D_csr_read;
   wire        D_csr_write;
   wire        D_csr_set;
   wire        D_csr_clr;
   wire [11:0] D_csr_addr = D_instr_word[I_IMM_FIELD_H:I_IMM_FIELD_L];
   reg         E_csr_read;
   reg         E_csr_write;
   reg         E_csr_set;
   reg         E_csr_clr;
   reg  [11:0] E_csr_addr;
   wire [11:0] C_addr;
   wire        C_read;
   reg         C_write;
   wire        C_set;
   wire        C_clr;
   wire [31:0] C_read_data;
   wire [31:0] C_write_data;
   wire [31:0] C_expn_redirect_pc;
   wire [31:0] C_csr_epc;
   wire [31:0] C_debug_pc;

   wire I_expn;
   reg  D_i_expn;
   reg  E_i_expn;
   reg  M0_i_expn;
   reg  W_i_expn;
   wire D_expn;
   reg  E_d_expn;
   reg  M0_d_expn;
   reg  W_d_expn;
   wire E_expn;
   reg  M0_e_expn;
   reg  W_e_expn;
   wire M0_expn;
   wire M0_ls_expn;
   reg  W_m0_expn;
   reg  W_m0_ls_expn;
   wire W_expn;
   wire C_csr_access_expn;

   wire M0_sstep_expn;

   expn_code_t I_expn_type  = INSTR_ADDR_MISAL;
   expn_code_t D_expn_type;
   expn_code_t E_expn_type;
   expn_code_t M0_expn_type;
   expn_code_t M0_ls_expn_type;
   expn_code_t W_expn_type  = INSTR_ADDR_MISAL;

   expn_code_t D_i_expn_type;
   expn_code_t E_i_expn_type;
   expn_code_t M0_i_expn_type;
   expn_code_t W_i_expn_type;

   expn_code_t E_d_expn_type;
   expn_code_t M0_d_expn_type;
   expn_code_t W_d_expn_type;

   expn_code_t M0_e_expn_type;
   expn_code_t W_e_expn_type;

   expn_code_t W_m0_expn_type;

   expn_code_t C_expn_type;
   reg         C_expn_update;
   reg         C_expn_taken;

   reg [31:0]  C_expn_pc;
   reg [31:0]  C_dbg_expn_pc;
   wire        C_sstep_en;

   expn_code_t nxt_csr_expn_type;
   reg nxt_csr_expn_update;
   reg nxt_expn_taken;
   reg [31:0] nxt_csr_expn_pc;
   reg [31:0] nxt_dbg_expn_pc;

   wire flush_E;
   wire flush_D;
   wire flush_I;
   wire flush_fetch;

   reg irq_flush;
   reg nxt_reset_req_flush;
   reg C_reset_req_flush;

   logic [1:0] I_instr_resp;

   wire E_pc_trigger;
   reg  M0_instr_trigger;
   wire E_iw_trigger;
   wire C_trig_pc_en;
   wire C_trig_iw_en;
   wire C_trig_st_data_en;
   wire C_trig_st_adrs_en;
   wire C_trig_ld_data_en;
   wire C_trig_ld_adrs_en;
   wire C_trig_in_dm;
   wire M0_ls_triggered = 1'b0;
   wire [31:0] C_tdata2;
   wire M0_ebreak_to_dm;
   wire trig_to_dm;

   // Instruction Words carry forward chain from one stage to next
   // in --> I --> D --> E --> M0 --> W
   //
   // **************************************************************************** //
   // *********************************   in --> I      ************************** //
   // **************************************************************************** //

   wire I_is_branch;
   reg D_is_branch;
   reg E_is_branch;
   reg M0_is_branch;

   wire I_is_wfi;
   reg D_is_wfi;
   reg E_is_wfi;
   reg M0_is_wfi;

   reg exception_redirect_back;
   reg exception_redir_pndg;
   reg dbg_expn_redirect_back;
   reg dbg_expn_redir_pndg;

   reg D_mret_instr;
   reg E_mret_instr;
   reg M0_mret_instr;
   reg W_mret_instr;

   reg D_dret_instr;
   reg E_dret_instr;
   reg M0_dret_instr;
   reg W_dret_instr;

   reg D_fencei_instr;
   reg E_fencei_instr;
   reg M0_fencei_instr;

   wire M0_expn_ret;
   wire M0_dbg_ret;
   wire M0_icache_inv;

   wire C_debug_mode;
   wire C_ebreak_in_dm;

   dbg_expn_code_t core_dbg_expn_type, nxt_dbg_expn_type, C_dbg_expn_type;

   reg C_dbg_expn_update;
   reg C_dbg_expn_taken;

   wire nxt_dbg_expn_update;
   reg  nxt_dbg_expn_taken;
   expn_code_t plat_irq_num;

   wire [3:0] core_irq_priority;
   wire core_irq;
   wire core_irq_en;
   wire core_debug_irq;
   wire core_irq_pndg;

   wire M0_wait_for_irq;
   wire M0_ecc_wait_for_nmi;
   reg  M0_ecc_stall;

   wire nxt_reset_req_done;
   wire PC_reset_ack;
   reg [RST_REQ_DEPTH-1:0] reset_req_done_q;
   reg reset_req_ack_reg;
   reg  core_reset_req;

   wire [3:0] instr_ecc;
   wire [1:0] itag_ecc;

   wire [1:0] D_gpr_ecc;
   reg  [1:0] E_gpr_ecc;
   reg  [1:0] M0_gpr_ecc;
   wire [1:0] D_fpr_ecc;
   reg  [1:0] E_fpr_ecc;
   reg  [1:0] M0_fpr_ecc;
   wire D_gpr_incorrect;
   reg  E_gpr_incorrect;
   reg  M0_gpr_incorrect;
   wire D_fpr_incorrect;
   reg  E_fpr_incorrect;
   reg  M0_fpr_incorrect;
   wire D_instr_incorrect;
   reg  E_instr_incorrect;
   reg  M0_instr_incorrect;
   wire D_itag_incorrect;
   reg  E_itag_incorrect;
   reg  M0_itag_incorrect;

   wire [1:0] M0_dcache_data_ecc;
   wire [1:0] M0_dcache_dtag_ecc;
   wire [1:0] M0_dcache_dtcm1_ecc;
   wire [1:0] M0_dcache_dtcm2_ecc;
   reg  [1:0] M0_dcache_data_ecc_q;
   reg  [1:0] M0_dcache_dtag_ecc_q;
   reg  [1:0] M0_dcache_dtcm1_ecc_q;
   reg  [1:0] M0_dcache_dtcm2_ecc_q;
   wire       M0_data_incorrect;
   wire       M0_dtag_incorrect;
   wire       M0_dtcm1_incorrect;
   wire       M0_dtcm2_incorrect;

   reg  E_fatal_ecc;
   reg  M0_fatal_ecc;

   wire [3:0] I_instr_ecc;
   reg  [3:0] D_instr_ecc;
   reg  [3:0] E_instr_ecc;
   reg  [3:0] M0_instr_ecc;
   wire [1:0] I_itag_ecc;
   reg  [1:0] D_itag_ecc;
   reg  [1:0] E_itag_ecc;
   reg  [1:0] M0_itag_ecc;

   reg [4:0] E_ecc_rs1;
   reg [4:0] E_ecc_rs2;
   reg [4:0] M0_ecc_rs1;
   reg [4:0] M0_ecc_rs2;

   reg [5:0] ecc_status;
   reg [31:0] ecc_src;

   wire [1:0] D_rs1_gpr_ecc;
   wire [1:0] D_rs2_gpr_ecc;
   wire [1:0] D_rs1_fpr_ecc;
   wire [1:0] D_rs2_fpr_ecc;
   wire [1:0] D_rs3_fpr_ecc;

   always @(posedge clk, posedge reset) begin
      if (reset)
         core_reset_req <= 1'b0;
      else
         core_reset_req <= USE_RESET_REQ & reset_req & ~(C_debug_mode | C_dbg_expn_update);
   end

   reg [31:0] dbg_vector;

   wire M0_ci_done = core_ci_done;
   wire [31:0] M0_ci_result = core_ci_result;
   assign core_ci_data0       = M0_exe_s1;
   assign core_ci_data1       = M0_exe_s2;
   assign core_ci_alu_result  = M0_exe_result;
   assign core_ci_ctrl        = M0_instr_word;
   assign core_ci_enable      = M0_ci_enable;
   assign core_ci_op          = M0_ci_op;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         dbg_vector <= DBG_EXPN_VECTOR;
      else begin
         if (M0_instr_valid)
            if (C_debug_mode)
               dbg_vector <= DBG_PARK_LOOP;
            else
               dbg_vector <= DBG_EXPN_VECTOR;
      end
   end

   // Issue new instruction request (or not)
   //    - Branch being processed by pipeline
   //          - TODO: This inserts a stall in pipe. To be removed and replaced with branch prediction logic
   //    - Instruction request sent, waiting for response
   //    - Instruction request asserted, waiting for it to be accepted
   //    - Intruction in F stage not consumed (stalled)
   wire[31:0] icache_araddr;
   wire icache_arvalid;
   wire icache_arready;
   wire icache_rvalid;
   wire[31:0] icache_rdata;

   niosv_g_fetch # (
      .RESET_VECTOR     (RESET_VECTOR),
      .ECC_EN           (ECC_EN),
      .BUFFER_SIZE      (4)
   ) instr_fetch_inst (
      .clk              (clk),
      .reset            (internal_reset),
      .external_reset   (reset),
      .reset_req        (core_reset_req && USE_RESET_REQ),
      .reset_ack        (PC_reset_ack),

      // ======== AXI4-Lite Interface ========
      // read address
      .instr_araddr     (icache_araddr),
      .instr_arvalid    (icache_arvalid),
      .instr_arready    (icache_arready),

      // read response
      .instr_rvalid     (icache_rvalid),
      .instr_rdata      (icache_rdata),
      .instr_rresp      (instr_rresp),
      .instr_ecc        (instr_ecc),
      .itag_ecc         (itag_ecc),

      // ========== Core Interface ===========
      .dbg_expn_redir   (DEBUG_ENABLED ? C_dbg_expn_taken : 1'b0),   // Debug Exceptions
      .expn_redir       (C_expn_taken),                              // Exceptions in machine mode
      .instr_redir      (M0_redirect),                               // Instruction Redirect
      .dbg_vector       (dbg_vector),
      .expn_vector      (C_expn_redirect_pc),
      .branch_addr      (M0_redirect_pc),
      .hazard           (~D_ready | branch_stall),
      .prg_addr         (I_instr_pc),
      .prg_data         (I_instr_word),
      .prg_resp         (I_instr_resp),
      .prg_instr_ecc    (I_instr_ecc),
      .prg_itag_ecc     (I_itag_ecc),

      .prg_data_valid   (I_instr_valid)
   );

   logic[31:0] instr_word_awaddr;
   logic[31:0] instr_word_araddr;

   // Word to byte address conversion
   // I_cache logic is word address based hence this is required.
   assign instr_awaddr = {instr_word_awaddr[29:0], 2'b00};
   assign instr_araddr = {instr_word_araddr[29:0], 2'b00};

   //cache NCR parameters are word addresses...
   //Set start address higher than end address to disable a region
   niosv_g_instr_cache # (
      .RAM_TYPE                  (RAM_TYPE),
      .NCR1_START                (DBG_DATA_S_BASE / 4),
      .NCR1_END                  ((DBG_DATA_S_BASE + 32'h0000ffff) / 4),
      .NCR2_START                (0),
      .NCR2_END                  (2000000),

      .ICACHE_SIZE               (INST_CACHE_SIZE),
      .DEBUG_ENABLED             (DEBUG_ENABLED),
      .DBG_DATA_S_BASE           (DBG_DATA_S_BASE),
      .TIMER_MSIP_DATA_S_BASE    (TIMER_MSIP_DATA_S_BASE),
      .PERIPHERAL_REGION_A_SIZE  (PERIPHERAL_REGION_A_SIZE),
      .PERIPHERAL_REGION_A_BASE  (PERIPHERAL_REGION_A_BASE),
      .PERIPHERAL_REGION_B_SIZE  (PERIPHERAL_REGION_B_SIZE),
      .PERIPHERAL_REGION_B_BASE  (PERIPHERAL_REGION_B_BASE),
      .ITCM1_SIZE                (ITCM1_SIZE),
      .ITCM1_BASE                (ITCM1_BASE),
      .ITCM1_INIT_FILE           (ITCM1_INIT_FILE),
      .ITCM2_SIZE                (ITCM2_SIZE),
      .ITCM2_BASE                (ITCM2_BASE),
      .ITCM2_INIT_FILE           (ITCM2_INIT_FILE),
      .ECC_EN                    (ECC_EN),
      .DEVICE_FAMILY             (DEVICE_FAMILY),
      .ITCS1_ADDR_WIDTH          (ITCS1_ADDR_WIDTH),
      .ITCS2_ADDR_WIDTH          (ITCS2_ADDR_WIDTH)
   ) icache_inst (
      .clk                       (clk),
      .rst                       (reset),
      .flush                     (1'b0),
      .prefetch                  (1'b0),
      .cache_inv_req             (M0_icache_inv),

      .write_ready               (),
      .read_ready                (icache_arready),
      .read_valid                (icache_rvalid),
      .cpu_wren                  (1'b0),
      .cpu_ren                   (icache_arvalid),                // Instr request
      .cpu_address               ({2'b00, icache_araddr[31:2]}),  // Requested PC
      .to_cpu                    (icache_rdata),                  // Response Instruction from icache or itcm
      .from_cpu                  (32'h00000000),

      .instr_ecc_to_cpu          (instr_ecc),
      .itag_ecc_to_cpu           (itag_ecc),

      .awaddr                    (instr_word_awaddr),
      .awprot                    (instr_awprot),
      .awvalid                   (instr_awvalid),
      .awsize                    (instr_awsize),
      .awlen                     (instr_awlen),
      .awburst                   (instr_awburst),
      .awready                   (instr_awready),

      .wvalid                    (instr_wvalid),
      .wdata                     (instr_wdata),
      .wstrb                     (instr_wstrb),
      .wlast                     (instr_wlast),
      .wready                    (instr_wready),

      .bvalid                    (instr_bvalid),
      .bresp                     (instr_bresp),
      .bready                    (instr_bready),

      // I-cache write interface from core interface
      .araddr                    (instr_word_araddr),
      .arprot                    (instr_arprot),
      .arvalid                   (instr_arvalid),
      .arsize                    (instr_arsize),
      .arlen                     (instr_arlen),
      .arburst                   (instr_arburst),
      .arready                   (instr_arready),

      .rdata                     (instr_rdata),
      .rvalid                    (instr_rvalid),
      .rresp                     (instr_rresp),
      .rready                    (instr_rready),

      .M0_wait_for_irq           (M0_wait_for_irq),

      .itcs1_awaddr              (itcs1_awaddr),
      .itcs1_awprot              (itcs1_awprot),
      .itcs1_awvalid             (itcs1_awvalid),
      .itcs1_awready             (itcs1_awready),

      .itcs1_wvalid              (itcs1_wvalid),
      .itcs1_wdata               (itcs1_wdata),
      .itcs1_wstrb               (itcs1_wstrb),
      .itcs1_wready              (itcs1_wready),

      .itcs1_bvalid              (itcs1_bvalid),
      .itcs1_bresp               (itcs1_bresp),
      .itcs1_bready              (itcs1_bready),

      .itcs1_araddr              (itcs1_araddr),
      .itcs1_arprot              (itcs1_arprot),
      .itcs1_arvalid             (itcs1_arvalid),
      .itcs1_arready             (itcs1_arready),

      .itcs1_rdata               (itcs1_rdata),
      .itcs1_rvalid              (itcs1_rvalid),
      .itcs1_rresp               (itcs1_rresp),
      .itcs1_rready              (itcs1_rready),

      .itcs2_awaddr              (itcs2_awaddr),
      .itcs2_awprot              (itcs2_awprot),
      .itcs2_awvalid             (itcs2_awvalid),
      .itcs2_awready             (itcs2_awready),

      .itcs2_wvalid              (itcs2_wvalid),
      .itcs2_wdata               (itcs2_wdata),
      .itcs2_wstrb               (itcs2_wstrb),
      .itcs2_wready              (itcs2_wready),

      .itcs2_bvalid              (itcs2_bvalid),
      .itcs2_bresp               (itcs2_bresp),
      .itcs2_bready              (itcs2_bready),

      .itcs2_araddr              (itcs2_araddr),
      .itcs2_arprot              (itcs2_arprot),
      .itcs2_arvalid             (itcs2_arvalid),
      .itcs2_arready             (itcs2_arready),

      .itcs2_rdata               (itcs2_rdata),
      .itcs2_rvalid              (itcs2_rvalid),
      .itcs2_rresp               (itcs2_rresp),
      .itcs2_rready              (itcs2_rready)
   );

   wire [COPCODE_W-1:0]  I_iw_cop = I_instr_word[COPCODE_FIELD_H:COPCODE_FIELD_L];
   wire [OPCODE_W-1:0]   E_iw_op  = E_instr_word[OPCODE_FIELD_H:OPCODE_FIELD_L];
   wire [F3_FIELD_W-1:0] I_iw_f3  = I_instr_word[F3_FIELD_H:F3_FIELD_L];

   wire I_ld_op        = (I_iw_cop == LOAD_COP);
   wire I_st_op        = (I_iw_cop == STORE_COP);
   wire I_branch_op    = (I_iw_cop == B_COP);
   wire I_alu_i_op     = (I_iw_cop == ALU_I_COP);
   wire I_jalr_instr   = (I_iw_cop == JALR_COP);
   wire I_jal_instr    = (I_iw_cop == JAL_COP);
   wire I_auipc_instr  = (I_iw_cop == AUIPC_COP);
   wire I_lui_instr    = (I_iw_cop == LUI_COP);
   wire I_fp_ld_op     = FLOAT_ENABLED /*&& (I_iw_f3 == F3_2)*/ && (I_iw_cop == FP_LOAD_COP);
   wire I_fp_st_op     = FLOAT_ENABLED /*&& (I_iw_f3 == F3_2)*/ && (I_iw_cop == FP_STORE_COP);

   wire I_beq_instr    = I_branch_op && (I_iw_f3 == F3_0);
   wire I_bne_instr    = I_branch_op && (I_iw_f3 == F3_1);
   wire I_blt_instr    = I_branch_op && (I_iw_f3 == F3_4);
   wire I_bge_instr    = I_branch_op && (I_iw_f3 == F3_5);
   wire I_bltu_instr   = I_branch_op && (I_iw_f3 == F3_6);
   wire I_bgeu_instr   = I_branch_op && (I_iw_f3 == F3_7);
   wire I_ebreak_instr = (I_instr_word == EBREAK_INSTR);
   wire I_ecall_instr  = (I_instr_word == ECALL_INSTR);
   wire I_mret_instr   = (I_instr_word == MRET_INSTR);
   wire I_dret_instr   = DEBUG_ENABLED && (I_instr_word == DRET_INSTR);
   wire I_fencei_instr = (I_iw_cop == MISC_MEM_COP) && (I_iw_f3 == F3_1);

   assign I_load_op    = I_ld_op | I_fp_ld_op;
   assign I_store_op   = I_st_op | I_fp_st_op;

   wire I_itype        = I_jalr_instr | I_load_op | I_alu_i_op;
   wire I_stype        = I_store_op;
   wire I_btype        = I_branch_op;
   wire I_utype        = I_lui_instr | I_auipc_instr;
   wire I_jtype        = I_jal_instr;

   // Extended immediate for various instructions
   // Use itype immediate as shamt for shift instructions since only lower five bits will ever be used
   wire [IMM_W-1:0] I_itype_ext_imm = {{I_IMM_EXT{I_instr_word[I_IMM_S]}}, I_instr_word[I_IMM_FIELD_H:I_IMM_FIELD_L]};
   wire [IMM_W-1:0] I_stype_ext_imm = {{S_IMM_EXT{I_instr_word[S_IMM_S]}}, I_instr_word[S_IMM1_FIELD_H:S_IMM1_FIELD_L], I_instr_word[S_IMM0_FIELD_H:S_IMM0_FIELD_L]};
   wire [IMM_W-1:0] I_btype_ext_imm = {
                        {B_IMM_EXT{I_instr_word[B_IMM3_FIELD_H]}},      // sign extension
                        I_instr_word[B_IMM3_FIELD_H:B_IMM3_FIELD_L],
                        I_instr_word[B_IMM2_FIELD_H:B_IMM2_FIELD_L],
                        I_instr_word[B_IMM1_FIELD_H:B_IMM1_FIELD_L],
                        I_instr_word[B_IMM0_FIELD_H:B_IMM0_FIELD_L],
                        1'b0
                     };
   wire [IMM_W-1:0] I_utype_ext_imm = {I_instr_word[U_IMM_FIELD_H:U_IMM_FIELD_L], LUI_EXT};
   wire [IMM_W-1:0] I_jtype_ext_imm = {
                        {J_IMM_EXT{I_instr_word[J_IMM3_FIELD_H]}},      // sign extension
                        I_instr_word[J_IMM3_FIELD_H:J_IMM3_FIELD_L],
                        I_instr_word[J_IMM2_FIELD_H:J_IMM2_FIELD_L],
                        I_instr_word[J_IMM1_FIELD_H:J_IMM1_FIELD_L],
                        I_instr_word[J_IMM0_FIELD_H:J_IMM0_FIELD_L],
                        1'b0
                     };

   assign I_mem_op = I_load_op | I_store_op;
   assign I_amo_op = ATOMIC_ENABLED & (I_iw_cop == ATOMIC_COP);
   assign I_misc_mem_op = (I_iw_cop == MISC_MEM_COP);

   assign I_use_imm = I_itype | I_stype | I_utype | I_amo_op | I_misc_mem_op;  // when setting D_exe_s2 = D_imm; want D_imm = 32'b0 for atomics and misc_mem_ops
   assign I_imm = ({IMM_W{I_itype}} & I_itype_ext_imm) |
                  ({IMM_W{I_stype}} & I_stype_ext_imm) |
                  ({IMM_W{I_btype}} & I_btype_ext_imm) |
                  ({IMM_W{I_utype}} & I_utype_ext_imm) |
                  ({IMM_W{I_jtype}} & I_jtype_ext_imm);

   assign I_is_branch = I_instr_valid & (I_jal_instr   |
                                         I_jalr_instr  |
                                         I_beq_instr   |
                                         I_bne_instr   |
                                         I_blt_instr   |
                                         I_bge_instr   |
                                         I_bltu_instr  |
                                         I_bgeu_instr  |
                                         I_mret_instr  |
                                         (I_dret_instr & C_debug_mode)
                                        );

   assign branch_stall = (D_is_branch & D_instr_valid) | (E_is_branch & E_instr_valid) | (M0_is_branch & M0_instr_valid);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_is_branch  <= 1'b0;
         E_is_branch  <= 1'b0;
         M0_is_branch <= 1'b0;
      end
      else begin
         if (D_ready) begin
            D_is_branch <= I_is_branch;
         end

         if (E_ready) begin
            E_is_branch <= D_is_branch & D_instr_valid;
         end

         if (M0_ready) begin
            M0_is_branch <= E_is_branch & E_instr_valid;
         end
      end
   end

   // ***** WFI instruction ***** //
   // Pass on the instruction to M0 and wait for any interrupt. Interrupt need not be service.
   // As soon as interrupt is pending, M0 is ready.
   // If interrupts are enabled, it should be taken on the next instruction.

   assign I_is_wfi = (I_instr_word == WFI_INSTR);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_is_wfi  <= 1'b0;
         E_is_wfi  <= 1'b0;
         M0_is_wfi <= 1'b0;
      end
      else begin
         if (D_ready) begin
            D_is_wfi <= I_is_wfi & ~C_debug_mode;
         end

         if (E_ready) begin
            E_is_wfi <= D_is_wfi & D_instr_valid;
         end

         if (M0_ready) begin
            M0_is_wfi <= E_is_wfi & E_instr_valid;
         end
      end
   end

   // **************************************************************************** //
   // *********************************   I --> D       ************************** //
   // **************************************************************************** //

   // Dependency Check and Stall for all instructions, single- and multicycle
   // TODO: Include logic for stalls from branch and exceptions (may already be solved by the formulation below).

   assign D_dep_stall_from_E = E_instr_valid & E_long_op &
                               (((E_rd == D_iw_rs1) &
                                 ((E_gpr_wr_en & D_needs_gp_rs1) | (E_fpr_wr_en & D_needs_fp_rs1))) ||
                                ((E_rd == D_iw_rs2) &
                                 ((E_gpr_wr_en & D_needs_gp_rs2) | (E_fpr_wr_en & D_needs_fp_rs2))) ||
                                ((E_rd == D_iw_rs3) &
                                 (E_fpr_wr_en & D_needs_fp_rs3)));
   assign D_dep_stall_from_M0 = ~M0_instr_done &
                                (((M0_rd == D_iw_rs1) &
                                  ((M0_gpr_wr_en & D_needs_gp_rs1) | (M0_fpr_wr_en & D_needs_fp_rs1))) ||
                                 ((M0_rd == D_iw_rs2) &
                                  ((M0_gpr_wr_en & D_needs_gp_rs2) | (M0_fpr_wr_en & D_needs_fp_rs2))) ||
                                 ((M0_rd == D_iw_rs3) &
                                  (M0_fpr_wr_en & D_needs_fp_rs3)));

   assign D_ready = flush_E | (E_ready & ~(D_dep_stall_from_E | D_dep_stall_from_M0));

   generate if (DEBUG_ENABLED) begin : gen_E_debug
   // Instruction trigger will be flagged before completion of the instruction.
   // Comparision is done in E stage to be precise: Instruction ahead of this instruction could update the trigger settings.

      // TODO: Currently exact match only for instruction PC
      assign E_pc_trigger = C_trig_pc_en & (E_instr_pc == C_tdata2);

      // Opcode match only for instruction trigger.
      assign E_iw_trigger = C_trig_iw_en & (E_iw_op == C_tdata2[6:0]);
   end
   else begin : gen_E_debug_tieoff
      assign E_pc_trigger = 1'b0;
      assign E_iw_trigger = 1'b0;
   end
   endgenerate

   always @(posedge clk) begin
      if (D_ready) begin
         D_instr_pc  <= I_instr_pc;
         D_iw_rs1    <= I_iw_rs1;
         D_iw_rs2    <= I_iw_rs2;
         D_iw_rs3    <= I_iw_rs3;
         D_branch_op <= I_branch_op;
         D_load_op   <= I_load_op;
         D_store_op  <= I_store_op;
         D_mem_op    <= I_mem_op;
         D_amo_op    <= I_amo_op;
         D_imm       <= I_imm;
         D_use_imm   <= I_use_imm;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_instr_valid <= 1'b0;
         D_instr_word <= NOP_VAL;  // NOP
      end
      else if (D_ready) begin
         D_instr_word <= I_instr_word;

         if (flush_I | C_expn_taken | C_dbg_expn_taken)
            D_instr_valid <= 1'b0;
         else if (branch_stall)
            D_instr_valid <= 1'b0;
         else
            D_instr_valid <= I_instr_valid;
      end
   end

   always @(posedge clk, posedge reset) begin
      if (reset) begin
         D_instr_ecc <= 4'b0;
         D_itag_ecc  <= 4'b0;
      end
      else if (D_ready) begin
         D_instr_ecc <= I_instr_ecc;
         D_itag_ecc  <= I_itag_ecc;
      end
   end

   assign D_instr_incorrect = (D_instr_ecc[1:0] == 2'b11);
   assign D_itag_incorrect  = (D_itag_ecc == 2'b11);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_mret_instr   <= 1'b0;
         D_dret_instr   <= 1'b0;
         D_fencei_instr <= 1'b0;
      end
      else if (D_ready) begin
         D_mret_instr   <= I_mret_instr;
         D_dret_instr   <= I_dret_instr;
         D_fencei_instr <= I_fencei_instr;
      end
   end

   // **************************************************************************** //
   // *********************************   D --> E       ************************** //
   // **************************************************************************** //

   assign E_ready = M0_ready;
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_instr_word <= NOP_VAL;  // NOP
      end
      else if (E_ready) begin
         E_instr_word <= D_instr_word;
      end
   end

   always @(posedge clk) begin
      if (E_ready) begin
         E_exe_s1        <= D_exe_s1;
         E_exe_s1        <= D_exe_s1;
         E_exe_s2        <= D_exe_s2;
         E_mul_s1_signed <= D_mul_s1_signed;
         E_mul_s2_signed <= D_mul_s2_signed;
         E_mul_use_lsw   <= D_mul_use_lsw;
         E_rd            <= D_rd;
         E_exe_op        <= D_exe_op;
         E_fp_op_decode  <= D_fp_op_decode;
         E_rs1_gpr_val   <= D_rs1_gpr_val;
         E_rs2_gpr_val   <= D_rs2_gpr_val;
         E_rs1_fpr_val   <= D_rs1_fpr_val;
         E_rs2_fpr_val   <= D_rs2_fpr_val;
         E_store_gpr     <= D_needs_gp_rs2;
         E_instr_pc      <= D_instr_pc;
         E_nxt_seq_pc    <= D_instr_pc + 4'd4;
         E_branch_tgt_pc <= D_branch_tgt_pc;
         E_csr_addr      <= D_csr_addr;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_instr_valid     <= 1'b0;
         E_gpr_wr_en       <= 1'b0;
         E_fpr_wr_en       <= 1'b0;
         E_fatal_ecc       <= 1'b0;
         E_gpr_incorrect   <= 1'b0;
         E_fpr_incorrect   <= 1'b0;
         E_instr_incorrect <= 1'b0;
         E_itag_incorrect  <= 1'b0;
      end
      else if (flush_D) begin
         E_instr_valid     <= 1'b0;
         E_gpr_wr_en       <= 1'b0;
         E_fpr_wr_en       <= 1'b0;
         E_fatal_ecc       <= 1'b0;
         E_gpr_incorrect   <= 1'b0;
         E_fpr_incorrect   <= 1'b0;
         E_instr_incorrect <= 1'b0;
         E_itag_incorrect  <= 1'b0;
      end
      else if (E_ready) begin
         if (D_dep_stall_from_E | D_dep_stall_from_M0) begin
            E_instr_valid     <= 1'b0;
            E_gpr_wr_en       <= 1'b0;
            E_fpr_wr_en       <= 1'b0;
            E_fatal_ecc       <= 1'b0;
            E_gpr_incorrect   <= 1'b1;
            E_fpr_incorrect   <= 1'b1;
            E_instr_incorrect <= 1'b0;
            E_itag_incorrect  <= 1'b0;
         end
         else begin
            E_gpr_wr_en       <= D_gpr_wr_en & D_instr_valid;
            E_fpr_wr_en       <= D_fpr_wr_en & D_instr_valid;
            E_instr_valid     <= D_instr_valid;
            E_fatal_ecc       <= (D_gpr_incorrect | D_fpr_incorrect | D_instr_incorrect | D_itag_incorrect) & D_instr_valid;
            E_gpr_incorrect   <= D_gpr_incorrect & D_instr_valid;
            E_fpr_incorrect   <= D_fpr_incorrect & D_instr_valid;
            E_instr_incorrect <= D_instr_incorrect & D_instr_valid;
            E_itag_incorrect  <= D_itag_incorrect & D_instr_valid;
         end
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_long_op      <= 1'b0;
         E_branch_op    <= 1'b0;
         E_mem_op       <= 1'b0;
         E_load_op      <= 1'b0;
         E_store_op     <= 1'b0;
         E_jmp          <= 1'b0;
         E_ebreak_instr <= 1'b0;
         E_ecall_instr  <= 1'b0;
         E_signed_cmp   <= 1'b0;
         E_csr_write    <= 1'b0;
         E_csr_read     <= 1'b0;
         E_cmo_op       <= 1'b0;
         E_amo_op       <= 1'b0;
         E_mul_op       <= 1'b0;
         E_div_op       <= 1'b0;
         E_ci_op        <= 4'b0;
      end
      else if (E_ready) begin
         E_long_op      <= D_load_op | D_store_op | D_amo_op | D_mul_op | D_div_op | D_cmo_op | (|D_ci_op) | D_long_fp_op;
         E_branch_op    <= D_branch_op;
         E_ebreak_instr <= D_ebreak_instr;
         E_ecall_instr  <= D_ecall_instr;
         E_mem_op       <= D_mem_op;
         E_load_op      <= D_load_op;
         E_store_op     <= D_store_op;
         E_signed_cmp   <= D_signed_cmp;
         E_csr_write    <= D_csr_write;
         E_csr_read     <= D_csr_read;
         E_csr_set      <= D_csr_set;
         E_csr_clr      <= D_csr_clr;
         E_cmo_op       <= D_cmo_op;
         E_amo_op       <= D_amo_op;
         E_mul_op       <= D_mul_op;
         E_div_op       <= D_div_op;
         E_ci_op        <= D_ci_op;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_mret_instr   <= 1'b0;
         E_dret_instr   <= 1'b0;
         E_fencei_instr <= 1'b0;
      end
      else if (E_ready) begin
         E_mret_instr   <= D_mret_instr;
         E_dret_instr   <= D_dret_instr & C_debug_mode;
         E_fencei_instr <= D_fencei_instr;
      end
   end

   always @(posedge clk) begin
      if (E_ready) begin
         E_mem_size    <= D_mem_size;
         E_mem_byteen  <= D_mem_byteen;
         E_mem_signext <= D_mem_signext;
      end
   end

   assign E_exe_result = C_read ? C_read_data : E_alu_result;

   // **************************************************************************** //
   // *********************************   E --> M0      ************************** //
   // **************************************************************************** //

   // Stall from M0 Stage- load/store instructions and other multicycle
   // instructions cause this stall.

   // M0_ready is deasserted for multicycle instructions,

   /* TODO: Temp- replace this with good name */ wire other_multicycle_instr_pending = 1'b0;

   assign M0_wait_for_irq = M0_is_wfi & ~core_irq_pndg;
   assign M0_ecc_wait_for_nmi = (M0_ecc_stall | M0_fatal_ecc | M0_dtag_incorrect | M0_data_incorrect | M0_dtcm1_incorrect | M0_dtcm2_incorrect)  & ~(core_nmi_irq | core_debug_irq | core_reset_req);

   assign M0_multicycle_instr_pending =  M0_ecc_wait_for_nmi
                                       | M0_ls_instr_pending
                                       | M0_wait_for_irq
                                       | M0_mul_pending
                                       | M0_div_pending
                                       | ((M0_ci_pending | (|M0_ci_op)) & ~M0_ci_done)
                                       | M0_fpu_op_pending
                                       | other_multicycle_instr_pending;

   assign M0_ready = ~M0_multicycle_instr_pending & W_ready;

   // Kill redirection from E instruction if M0 flags exception
   assign E_unaligned_redir = (E_redirect   & E_unaligned_redirect_pc) |
                              (E_mret_instr & (|C_csr_epc[1:0])) |
                              (E_dret_instr & (|C_debug_pc[1:0]));

   assign M0_redirect_nxt = (E_redirect | E_mret_instr | E_dret_instr | E_fencei_instr) & E_instr_valid & ~flush_E & ~E_unaligned_redir;

   always @(*) begin
      unique case (1)
         E_dret_instr   : nxt_M0_redirect_pc = C_debug_pc;
         E_mret_instr   : nxt_M0_redirect_pc = C_csr_epc;
         E_fencei_instr : nxt_M0_redirect_pc = E_nxt_seq_pc;
         default        : nxt_M0_redirect_pc = E_redirect_pc;
      endcase
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_instr_word <= NOP_VAL;  // NOP
         M0_redirect <= 1'b1;
         M0_mret_instr <= 1'b0;
         M0_dret_instr <= 1'b0;
         M0_fencei_instr <= 1'b0;
      end
      else if (M0_ready) begin
         M0_instr_word <= E_instr_word;
         M0_redirect   <= M0_redirect_nxt;
         M0_mret_instr <= E_mret_instr;
         M0_dret_instr <= E_dret_instr;
         M0_fencei_instr <= E_fencei_instr;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_redirect_pc <= RESET_VECTOR;
      else
         M0_redirect_pc <= nxt_M0_redirect_pc;
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_instr_pc <= E_instr_pc;
         M0_nxt_seq_pc <= E_nxt_seq_pc;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_nxt_pc <= RESET_VECTOR;
      else if (M0_ready & E_instr_valid & ~flush_E) begin
         if (M0_redirect_nxt)
            M0_nxt_pc <= nxt_M0_redirect_pc;
         else
            M0_nxt_pc <= E_nxt_seq_pc;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_instr_valid <= 1'b0;
         M0_mem_op <= 1'b0;
         M0_load_op  <= 1'b0;
         M0_store_op <= 1'b0;
         M0_long_op <= 1'b0;
         M0_gpr_incorrect <= 1'b0;
         M0_fpr_incorrect <= 1'b0;
         M0_instr_incorrect <= 1'b0;
         M0_itag_incorrect <= 1'b0;
         M0_fatal_ecc <= 1'b0;
      end
      else if (M0_ready) begin
         if (flush_E) begin
            M0_instr_valid <= 1'b0;
            M0_gpr_incorrect <= 1'b0;
            M0_fpr_incorrect <= 1'b0;
            M0_instr_incorrect <= 1'b0;
            M0_itag_incorrect <= 1'b0;
            M0_fatal_ecc <= 1'b0;
         end
         else begin
            M0_instr_valid <= E_instr_valid;
            M0_fatal_ecc <= E_fatal_ecc;
            M0_gpr_incorrect <= E_gpr_incorrect;
            M0_fpr_incorrect <= E_fpr_incorrect;
            M0_instr_incorrect <= E_instr_incorrect;
            M0_itag_incorrect <= E_itag_incorrect;
         end

         if (E_instr_valid) begin
            M0_mem_op   <= E_mem_op & ~(flush_E | E_expn | E_d_expn);
            M0_load_op  <= E_load_op  & ~(flush_E | E_expn | E_d_expn);
            M0_store_op <= E_store_op & ~(flush_E | E_expn | E_d_expn);
            M0_long_op  <= E_long_op;
         end
         else if (M0_expn) begin
            M0_mem_op   <= 1'b0;
            M0_load_op  <= 1'b0;
            M0_store_op <= 1'b0;
            M0_long_op  <= 1'b0;
         end

      end
      else begin
         M0_instr_valid <= 1'b0;
         M0_mem_op   <= 1'b0;
         M0_load_op  <= 1'b0;
         M0_store_op <= 1'b0;
         M0_long_op  <= 1'b0;
      end
   end

   generate if (ATOMIC_ENABLED) begin : gen_M0_atomic
      always @(posedge clk, posedge internal_reset) begin
         if (internal_reset)
            M0_amo_op <= 1'b0;
         else if (M0_ready) begin
            if (E_instr_valid)
               M0_amo_op <= E_amo_op & ~(flush_E | E_expn | E_d_expn);
            else if (M0_expn)
               M0_amo_op <= 1'b0;
         end
         else
            M0_amo_op <= 1'b0;
      end
   end
   else begin : gen_M0_atomic_tieoff
      assign M0_amo_op = 1'b0;
   end
   endgenerate

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_cmo_op <= 1'b0;
      else if (M0_ready) begin
         if (E_instr_valid)
            M0_cmo_op <= E_cmo_op & ~(flush_E | E_expn | E_d_expn);
         else if (M0_expn)
            M0_cmo_op <= 1'b0;
      end
      else
         M0_cmo_op <= 1'b0;
   end

   assign E_mul_valid = E_instr_valid & E_mul_op & ~(flush_E | E_expn | E_d_expn);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         // M0_mul_op <= 1'b0;
         M0_div_op <= 1'b0;
         M0_ci_op  <= 4'b0;
      end
      else if (M0_ready) begin
         if (E_instr_valid) begin
            // M0_mul_op <= E_mul_op & ~(flush_E | E_expn | E_d_expn);
            M0_div_op <= E_div_op & ~(flush_E | E_expn | E_d_expn);
            M0_ci_op  <= (flush_E | E_expn | E_d_expn) ? 4'b0 : E_ci_op;
         end
         else if (M0_expn) begin     // TODO: Is this ever valid
            // M0_mul_op <= 1'b0;
            M0_div_op <= 1'b0;
            M0_ci_op  <= 4'b0;
         end
      end
      else begin
         // M0_mul_op <= 1'b0;
         M0_div_op <= 1'b0;
         M0_ci_op  <= 4'b0;
      end
   end

   // M0_load_en, M0_gpr_wr_en, and M0_fpr_wr_en are sticky for load and multicycle instructions.
   assign M0_load_en_nxt   = M0_load_en;
   assign M0_gpr_wr_en_nxt = M0_gpr_wr_en;
   assign M0_fpr_wr_en_nxt = M0_fpr_wr_en;
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_load_en   <= 1'b0;
         M0_gpr_wr_en <= 1'b0;
         M0_fpr_wr_en <= 1'b0;
      end
      else if (M0_ready && E_instr_valid) begin
         M0_load_en <= E_load_op;
         // Disable E register write if M0 flags exception
         M0_gpr_wr_en <= E_gpr_wr_en & ~(flush_E | E_expn | E_d_expn);
         M0_fpr_wr_en <= E_fpr_wr_en & ~(flush_E | E_expn | E_d_expn);
      end
      else if (M0_multicycle_instr_pending) begin
         M0_load_en   <= M0_load_en_nxt;
         M0_gpr_wr_en <= M0_gpr_wr_en_nxt;
         M0_fpr_wr_en <= M0_fpr_wr_en_nxt;
      end
      else begin
         M0_load_en   <= 1'b0;
         M0_gpr_wr_en <= 1'b0;
         M0_fpr_wr_en <= 1'b0;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_rd <= E_rd;
         M0_exe_result  <= E_exe_result;
         M0_rs1_gpr_val <= E_rs1_gpr_val;
         M0_rs2_gpr_val <= E_rs2_gpr_val;
         M0_store_data  <= E_store_gpr ? E_rs2_gpr_val : E_rs2_fpr_val;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_mem_size    <= E_mem_size;
         M0_mem_byteen  <= E_mem_byteen;
         M0_mem_signext <= E_mem_signext;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_fpu_to_fpr_e_done   <= E_fpu_to_fpr_done;
         M0_fpu_to_fpr_e_result <= E_fpu_to_fpr_result;
         M0_fpu_to_gpr_e_done   <= E_fpu_to_gpr_done;
         M0_fpu_to_gpr_e_result <= E_fpu_to_gpr_result;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_fpu_e_flags <= deasserted_fp_flags();
      end
      else if (M0_ready) begin
         M0_fpu_e_flags <= E_fpu_flags;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_ci_pending <= 1'b0;
      else if (|(M0_ci_op))
         M0_ci_pending <= 1'b1;
      else if (M0_ci_done)
         M0_ci_pending <= 1'b0;
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_exe_s1 <= E_exe_s1;
         M0_exe_s2 <= E_exe_s2;
      end
   end

   // **************************************************************************** //
   // *********************************   M0 --> W      ************************** //
   // **************************************************************************** //

   assign W_ready = 1'b1;

   // TODO: This assumes that specific ops will take more than 1 cycle. This may change.
   assign M0_instr_done =  (M0_instr_valid & ~M0_long_op) |                           // Single cycle ops executed in E stage.
                            M0_ls_op_done | M0_mul_done | M0_div_done | M0_ci_done |  // Multi-cycle ops done
                            M0_fpu_to_fpr_done | M0_fpu_to_gpr_done;

   always @(*) begin
      if (M0_rd == GPR0) begin
         M0_gpr_result_data_nxt = 32'b0;
      end
      else begin
         M0_gpr_result_data_nxt = M0_exe_result;
         case (1'b1)
            M0_mul_done          : M0_gpr_result_data_nxt = M0_mul_result;
            M0_div_done          : M0_gpr_result_data_nxt = M0_div_result;
            M0_ls_op_done        : M0_gpr_result_data_nxt = M0_load_data;
            M0_ci_done           : M0_gpr_result_data_nxt = M0_ci_result;
            M0_fpu_to_gpr_done   : M0_gpr_result_data_nxt = M0_fpu_to_gpr_result;
            M0_fpu_to_gpr_e_done : M0_gpr_result_data_nxt = M0_fpu_to_gpr_e_result;
         endcase
      end
   end

   always @(*) begin
      M0_fpr_result_data_nxt = M0_fpu_to_fpr_e_result;
      case (1'b1)
         M0_ls_op_done        : M0_fpr_result_data_nxt = M0_load_data;
         M0_fpu_to_fpr_done   : M0_fpr_result_data_nxt = M0_fpu_to_fpr_result;
      endcase
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         W_instr_word <= NOP_VAL;  // NOP
      end
      else if (W_ready & M0_instr_done) begin
         W_instr_word <= M0_instr_word;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         W_gpr_wr_en   <= 1'b0;
         W_fpr_wr_en   <= 1'b0;
         W_instr_valid <= 1'b0;
      end
      else if (W_ready && M0_instr_done) begin
         W_gpr_wr_en   <= M0_gpr_wr_en;
         W_fpr_wr_en   <= M0_fpr_wr_en;
         W_instr_valid <= 1'b1;
      end
      else begin
         W_gpr_wr_en   <= 1'b0;
         W_fpr_wr_en   <= 1'b0;
         W_instr_valid <= 1'b0;
      end
   end

   always @(posedge clk) begin
      if (W_ready) begin
         W_rd <= M0_rd;
         W_gpr_exe_result <= M0_gpr_result_data_nxt;
         W_fpr_exe_result <= M0_fpr_result_data_nxt;
      end
   end

   // **************************************************************************** //
   // *************************** Register file RAM Write  *********************** //
   // **************************************************************************** //

   // Write GPR: 2 cycle RAM latency hence result from one stage before W.
   // Abandon register write if load results in exception.
   assign wr_gpr_en = M0_gpr_wr_en & M0_instr_done & ~M0_expn;
   assign wr_gpr = M0_rd;
   assign wr_gpr_data = M0_gpr_result_data_nxt;

   assign wr_fpr_en = M0_fpr_wr_en & M0_instr_done & ~M0_expn;
   assign wr_fpr = M0_rd;
   assign wr_fpr_data = M0_fpr_result_data_nxt;

   // **************************************************************************** //
   // ************* Exception/Interrupt/Debug Interrupt Control Logic ************ //
   // **************************************************************************** //

   // Exception information trickels through the pipe. This keeps things in
   // order. Also, this avoids unnecessary stalls and wait. Flush logic is
   // central to M0 stage.
   // M0 stage is critical. This is where magic happens. Make sure the
   // following functionality is disabled if there is an exception from
   // previous stage:
   //    - gpr / fpr write
   //    - mem ops
   //    - branch redirection
   //    - mret/dret redirection
   //    - csr write
   //
   // When passing down the information, previous stage exception takes
   // priority. If I stage had exception, exception in D stage from that
   // instruction is meaningless. And so on...

   // I -> D exception information
   // Unaligned instruction or response error
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         D_i_expn <= 1'b0;
      else if (D_ready & I_instr_valid) begin
         D_i_expn <= (|I_instr_pc[1:0]) | (|I_instr_resp);
      end
   end

   always @(posedge clk) begin
      if (D_ready & I_instr_valid) begin
         D_i_expn_type <= (|I_instr_resp) ? INSTR_ACCESS_ERR : INSTR_ADDR_MISAL;
         D_i_mtval <= I_instr_pc;
      end
   end

   // D -> E exception information
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_d_expn <= 1'b0;
      end
      else begin
         if (E_ready)
            E_d_expn <= D_instr_valid & (D_expn | D_i_expn);
      end
   end

   always @(posedge clk) begin
      if (D_instr_valid & E_ready) begin
         E_d_expn_type <= D_i_expn ? D_i_expn_type : D_expn_type;
         E_d_mtval <= D_i_expn ? D_i_mtval : D_instr_word;
      end
   end

   // E -> M0 exception information
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_e_expn <= 1'b0;
      end
      else begin
         if (M0_ready)
            M0_e_expn <= E_instr_valid & ~flush_E & (E_expn | E_d_expn);
      end
   end

   always @(posedge clk) begin
      if (E_instr_valid & M0_ready) begin
         M0_e_expn_type <= E_d_expn ? E_d_expn_type : E_expn_type;
         M0_e_mtval     <= E_unaligned_redir ? nxt_M0_redirect_pc : E_d_mtval;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_instr_trigger <= 1'b0;
      else if (M0_ready)
         M0_instr_trigger <= E_instr_valid & (E_iw_trigger | E_pc_trigger);
   end

   assign M0_expn_type = M0_e_expn ? M0_e_expn_type : M0_ls_expn_type;
   assign M0_mtval = M0_e_expn ? M0_e_mtval : M0_ls_addr;

   // M0_ls_expn and M0_e_expn are mutually exclusive. If M0_e_expn then M0
   // won't have memory instruction and hence M0_ls_expn cannot be 1.
   assign M0_expn = M0_ls_expn | M0_e_expn;

   // Single step: If single step is enabled the let an instruction complete and then take debug exception.

   generate
      if (DEBUG_ENABLED) begin : gen_M0_debug
         assign M0_ebreak_to_dm = M0_expn & (M0_expn_type == BREAKPOINT) & (M0_instr_trigger ? C_trig_in_dm : C_ebreak_in_dm);
         assign trig_to_dm = ~M0_expn & M0_ls_triggered & C_trig_in_dm;
         assign M0_sstep_expn = ~C_debug_mode & C_sstep_en & M0_instr_done & ~trig_to_dm & ~M0_ebreak_to_dm;
         // Exceptions in debug mode don't modify debug CSRs. Just redirection!
         assign nxt_dbg_expn_update = nxt_dbg_expn_taken & ~C_debug_mode;
      end
      else begin : gen_M0_debug_tieoff
         assign M0_sstep_expn = 1'b0;
         assign nxt_dbg_expn_update = 1'b0;
         assign M0_ebreak_to_dm = 1'b0;
         assign trig_to_dm = 1'b0;
      end
   endgenerate

   // TODO: CSR update takes 2 cycles for exception. Analyze side effect. If
   // there are none, keep it this way. Otherwise, use nxt_* to register the
   // vaules in CSRs.
   // TODO: Nested exceptions in normal mode.

   // ************ Single stepping and exception ************//
   // If single stepping in enabled, prevent pipeline state updation due to any exception.
   // Pipeline state gets updated by single step exception.
   assign nxt_expn_taken = nxt_csr_expn_update & ~M0_sstep_expn;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         C_expn_update <= 1'b0;
         C_expn_taken  <= 1'b0;
      end
      else begin
         C_expn_update <= nxt_csr_expn_update;
         C_expn_taken <= nxt_expn_taken;
      end
   end

   always @(posedge clk) begin
      C_expn_type <= nxt_csr_expn_type;
      C_expn_pc <= nxt_csr_expn_pc;
      C_expn_mtval <= M0_mtval;
   end

   generate if (DEBUG_ENABLED) begin : gen_C_debug
      always @(posedge clk, posedge internal_reset) begin
         if (internal_reset) begin
            C_dbg_expn_update <= 1'b0;
            C_dbg_expn_taken  <= 1'b0;
         end
         else begin
            C_dbg_expn_taken <= nxt_dbg_expn_taken;
            C_dbg_expn_update <= nxt_dbg_expn_update;
         end
      end

      always @(posedge clk) begin
         C_dbg_expn_type <= nxt_dbg_expn_type;
         C_dbg_expn_pc <= nxt_dbg_expn_pc;
      end
   end
   endgenerate

   always @(posedge clk, posedge reset)
   begin
      if (reset)
         C_reset_req_flush <= 1'b0;
      else
         C_reset_req_flush <= nxt_reset_req_flush;
   end

   always @(*) begin
      nxt_csr_expn_update = 1'b0;
      nxt_csr_expn_type   = M0_expn_type;
      nxt_csr_expn_pc     = M0_instr_pc;

      nxt_dbg_expn_taken  = 1'b0;
      nxt_dbg_expn_type   = NO_EXPN;
      nxt_dbg_expn_pc     = M0_instr_pc;
      irq_flush = 1'b0;

      nxt_reset_req_flush = 1'b0;

      if (ECC_EN & (M0_gpr_incorrect | M0_fpr_incorrect)) begin
         if (core_debug_irq) begin
            irq_flush = 1'b1;
            nxt_dbg_expn_taken = 1'b1;
            nxt_dbg_expn_type = DM_IRQ;
         end
         else if (core_nmi_irq) begin
            irq_flush = 1'b1;
            nxt_csr_expn_update = 1'b1;
            nxt_csr_expn_type = ECC_FATAL;
            nxt_csr_expn_pc = M0_instr_pc;
         end
      end
      else if (DEBUG_ENABLED & ~(M0_multicycle_instr_pending) & core_debug_irq & ~C_dbg_expn_update & ~core_reset_req) begin
         irq_flush = 1'b1;

         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = DM_IRQ;

         // TODO: Don't look for valid instruction: nxt_expn_pc = M0_PC + 4
         if (M0_expn)
            nxt_dbg_expn_pc = M0_instr_pc;
         //else if (M0_redirect)
         //   nxt_dbg_expn_pc = M0_redirect_pc;
         else
            nxt_dbg_expn_pc = M0_nxt_pc;

      end
      else if (USE_RESET_REQ & ~(M0_multicycle_instr_pending) & core_reset_req & ~(C_debug_mode | C_dbg_expn_update))
      begin
         irq_flush = 1'b1;
         nxt_reset_req_flush = 1'b1;
      end
      else if (~(M0_multicycle_instr_pending) & core_irq & core_irq_en & ~C_expn_taken) begin
         irq_flush = 1'b1;
         nxt_csr_expn_update = 1'b1;

         if (core_irq_priority[0])
            nxt_csr_expn_type = plat_irq_num;
         else if (core_irq_priority[1])
            nxt_csr_expn_type = M_EXT_IRQ;
         else if (core_irq_priority[2])
            nxt_csr_expn_type = M_SW_IRQ;
         else
            nxt_csr_expn_type = M_T_IRQ;

         // PC value for EPC/DPC due to interrupt
         //    If M0 instruction causes exception when interrupt is to be
         //    serviced, take interrupt and reexecute exceptional instructio. If
         //    M0 has redirection due to branch, attach new PC to intr. Otherwise
         //    let M0 instruction retire and find instruction in E, D, I or
         //    buffer.
         //    If there is no insturction in the pipe, attach interrupt to
         //    incoming instruction. And flush when the instruction arrives.

         if (M0_expn)
            nxt_csr_expn_pc = M0_instr_pc;
         //else if (M0_redirect)
         //   nxt_csr_expn_pc = M0_redirect_pc;
         else
            nxt_csr_expn_pc = M0_nxt_pc;

      end
         // Exception in debug mode: debug registers are not updated
      else if (M0_expn & C_debug_mode) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_csr_expn_update = 1'b0;
      end
      // Trigger takes to debug mode
      else if (~M0_expn & M0_ls_triggered & C_trig_in_dm) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = EBREAK_DBG;
         nxt_dbg_expn_pc     = M0_nxt_pc;
      end
      // EBREAK takes to debug mode
      else if (M0_ebreak_to_dm) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = EBREAK_DBG;
         nxt_dbg_expn_pc     = M0_instr_pc;
      end
      else if (M0_sstep_expn) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = SINGLE_STP;

         // DPC value for single step exception.
         //    If there is an exception, update EPC with PC causing the exception and
         //    update DPC with "normal mode" exception vector address.

         if (M0_expn) begin
            nxt_dbg_expn_pc = C_expn_redirect_pc;

            nxt_csr_expn_update = 1'b1;
            nxt_csr_expn_pc     = M0_instr_pc;
         end
         else
            nxt_dbg_expn_pc = M0_nxt_pc;

      end
      else if (M0_expn) begin
         nxt_csr_expn_update = 1'b1;
         nxt_dbg_expn_taken  = 1'b0;
         nxt_csr_expn_type   = M0_expn_type;
         nxt_csr_expn_pc     = M0_instr_pc;
      end
      else if (M0_ls_triggered) begin
         nxt_csr_expn_update = 1'b1;
         nxt_dbg_expn_taken  = 1'b0;
         nxt_csr_expn_type   = BREAKPOINT;
         nxt_csr_expn_pc     = M0_nxt_pc;
      end
   end

   // Invalidate instruction going from E to M0
   // M0 exception OR M0 redirection OR Interrupt flush
   assign flush_E = M0_expn | M0_ls_triggered | (M0_redirect & (M0_mret_instr| M0_dret_instr | M0_fencei_instr)) | irq_flush | M0_sstep_expn;

   assign flush_D = flush_E;       // Invalidate instruction going from D to E;
   assign flush_I = flush_D;       // Invalidate instruction going from I to D

   assign M0_expn_ret = M0_redirect & M0_mret_instr;
   assign M0_dbg_ret = M0_redirect & M0_dret_instr;
   assign M0_icache_inv = M0_redirect & M0_fencei_instr;

   //------------------------------------------------------//
   //------ Register Files (GPR and optional FPR) ---------//
   //------------------------------------------------------//

   assign rd_reg_a = D_ready ? I_iw_rs1 : D_iw_rs1;
   assign rd_reg_b = D_ready ? I_iw_rs2 : D_iw_rs2;
   assign rd_reg_c = D_ready ? I_iw_rs3 : D_iw_rs3;  // FP only

   niosv_reg_file # (
      .RAM_TYPE (RAM_TYPE),
      .NUM_REG  (NUM_REG),
      .NUM_RD   (2),
      .DATA_W   (DATA_W),
      .ECC_EN   (ECC_EN),
      .DEVICE_FAMILY (DEVICE_FAMILY)
   ) gp_reg_file_inst (
      .clk             (clk),
      .reset           (internal_reset),

      .rd_reg_a        (rd_reg_a),
      .rd_data_a       (rd_gpr_data_a),
      .rd_reg_b        (rd_reg_b),
      .rd_data_b       (rd_gpr_data_b),
      .rd_reg_c        (),
      .rd_data_c       (),

      .wr_en           (wr_gpr_en),
      .wr_reg          (wr_gpr),
      .wr_data         (wr_gpr_data),

      .eccstatus_reg_a (D_rs1_gpr_ecc),
      .eccstatus_reg_b (D_rs2_gpr_ecc),
      .eccstatus_reg_c ()
   );

   generate
      if (!FLOAT_ENABLED) begin : gen_fp_reg_file_tieoff
         assign rd_fpr_data_a = 32'h00000000;
         assign rd_fpr_data_b = 32'h00000000;
         assign rd_fpr_data_c = 32'h00000000;
         assign D_rs1_fpr_ecc = 2'b00;
         assign D_rs2_fpr_ecc = 2'b00;
         assign D_rs3_fpr_ecc = 2'b00;
      end
      else begin : gen_fp_reg_file
         niosv_reg_file # (
            .RAM_TYPE (RAM_TYPE),
            .NUM_REG  (NUM_REG),
            .NUM_RD   (3),
            .DATA_W   (FP32_W),
            .ECC_EN   (ECC_EN),
            .DEVICE_FAMILY (DEVICE_FAMILY)
         ) fp_reg_file_inst (
            .clk             (clk),
            .reset           (internal_reset),

            .rd_reg_a        (rd_reg_a),
            .rd_data_a       (rd_fpr_data_a),
            .rd_reg_b        (rd_reg_b),
            .rd_data_b       (rd_fpr_data_b),
            .rd_reg_c        (rd_reg_c),
            .rd_data_c       (rd_fpr_data_c),

            .wr_en           (wr_fpr_en),
            .wr_reg          (wr_fpr),
            .wr_data         (wr_fpr_data),

            .eccstatus_reg_a (D_rs1_fpr_ecc),
            .eccstatus_reg_b (D_rs2_fpr_ecc),
            .eccstatus_reg_c (D_rs3_fpr_ecc)
         );
      end
   endgenerate

   //------------------------------------------------------//
   //------------- Dependence Resolution ------------------//
   //------------------------------------------------------//

   // RS1 Dependecy resolution
   // Take most recent value- nearest stage
   // TODO: figure out where to incorporate R0- from ALU or here : R0 = 0 Always!
   always @(*) begin
      if (D_iw_rs1 == GPR0)
         D_rs1_gpr_val = 32'b0;
      else begin
         if ((D_iw_rs1 == E_rd) && E_gpr_wr_en && E_instr_valid)
            D_rs1_gpr_val = E_fpu_to_gpr_done ? E_fpu_to_gpr_result : E_exe_result;
         else if ((D_iw_rs1 == M0_rd) && M0_instr_done && M0_gpr_wr_en) // TODO: Expand to M<n> stages to see impact on timing
            D_rs1_gpr_val = M0_gpr_result_data_nxt;
         else if ((D_iw_rs1 == W_rd) && W_gpr_wr_en)
            D_rs1_gpr_val = W_gpr_exe_result;
         else
            D_rs1_gpr_val = rd_gpr_data_a;
      end
   end

   // RS2 Dependecy resolution
   // TODO: For timing, figure out where to incorporate R0- from ALU or here : R0 = 0 Always!
   always @(*) begin
      if (D_iw_rs2 == GPR0)
         D_rs2_gpr_val = 32'b0;
      else begin
         if ((D_iw_rs2 == E_rd) && E_gpr_wr_en && E_instr_valid)
            D_rs2_gpr_val = E_fpu_to_gpr_done ? E_fpu_to_gpr_result : E_exe_result;
         else if ((D_iw_rs2 == M0_rd) && M0_instr_done && M0_gpr_wr_en)
            D_rs2_gpr_val = M0_gpr_result_data_nxt;
         else if ((D_iw_rs2 == W_rd) && W_gpr_wr_en)
            D_rs2_gpr_val = W_gpr_exe_result;
         else
            D_rs2_gpr_val = rd_gpr_data_b;
      end
   end

   // Dependency resolution for floating-point register accessess - FPR0 is a normal RW register
   always @(*) begin
      if ((D_iw_rs1 == E_rd) && E_fpu_to_fpr_done && E_instr_valid)
         D_rs1_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs1 == M0_rd) && M0_instr_done && M0_fpr_wr_en)
         D_rs1_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs1 == W_rd) && W_fpr_wr_en)
         D_rs1_fpr_val = W_fpr_exe_result;
      else
         D_rs1_fpr_val = rd_fpr_data_a;
   end
   always @(*) begin
      if ((D_iw_rs2 == E_rd) && E_fpu_to_fpr_done && E_instr_valid)
         D_rs2_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs2 == M0_rd) && M0_instr_done && M0_fpr_wr_en)
         D_rs2_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs2 == W_rd) && W_fpr_wr_en)
         D_rs2_fpr_val = W_fpr_exe_result;
      else
         D_rs2_fpr_val = rd_fpr_data_b;
   end
   always @(*) begin
      if ((D_iw_rs3 == E_rd) && E_fpu_to_fpr_done && E_instr_valid)
         D_rs3_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs3 == M0_rd) && M0_instr_done && M0_fpr_wr_en)
         D_rs3_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs3 == W_rd) && W_fpr_wr_en)
         D_rs3_fpr_val = W_fpr_exe_result;
      else
         D_rs3_fpr_val = rd_fpr_data_c;
   end

   //------------------------------------------------------//
   //------------- Instruction Decode ---------------------//
   //------------------------------------------------------//

   // TODO:parts of instr decode can be moved to pre-decode/ fectch stage for
   // timing. Ease pressure on decode mux.
   instr_decoder_niosv_niosv_hart # (
      .ATOMIC_ENABLED (ATOMIC_ENABLED),
      .MULDIV_ENABLED (MULDIV_ENABLED),
      .FLOAT_ENABLED  (FLOAT_ENABLED)
   ) instr_decoder_inst (
      .clk                 (clk),
      .reset               (internal_reset),

      .D_instr_valid       (D_instr_valid),
      .D_iw                (D_instr_word),
      .D_imm               (D_imm),
      .D_use_imm           (D_use_imm),
      .D_rs1_gpr_val       (D_rs1_gpr_val),  // Input to decoder after hazard resolution
      .D_rs2_gpr_val       (D_rs2_gpr_val),  // Input to decoder after hazard resolution

      .D_exe_s1            (D_exe_s1),       // Output from decoder- not necessarily D_rs1_gpr_val
      .D_exe_s2            (D_exe_s2),       // Output from decoder- not necessarily D_rs2_gpr_val
      .D_mul_s1_signed     (D_mul_s1_signed),
      .D_mul_s2_signed     (D_mul_s2_signed),
      .D_mul_use_lsw       (D_mul_use_lsw),

      .D_mem_size          (D_mem_size),
      .D_mem_byteen        (D_mem_byteen),
      .D_mem_signext       (D_mem_signext),

      .D_rd                (D_rd),
      .D_exe_op            (D_exe_op),
      .D_signed_cmp        (D_signed_cmp),

      .D_mul_op            (D_mul_op),
      .D_div_op            (D_div_op),
      .D_cmo_op            (D_cmo_op),
      .D_ci_op             (D_ci_op),

      .D_needs_gp_rs1      (D_needs_gp_rs1),
      .D_needs_gp_rs2      (D_needs_gp_rs2),
      .D_gpr_wr_en         (D_gpr_wr_en),
      .D_needs_fp_rs1      (D_needs_fp_rs1),
      .D_needs_fp_rs2      (D_needs_fp_rs2),
      .D_needs_fp_rs3      (D_needs_fp_rs3),
      .D_fpr_wr_en         (D_fpr_wr_en),

      .D_csr_read          (D_csr_read),
      .D_csr_write         (D_csr_write),
      .D_csr_set           (D_csr_set),
      .D_csr_clr           (D_csr_clr),

      .D_instr_pc          (D_instr_pc),
      .D_branch_tgt_pc     (D_branch_tgt_pc),

      .D_ebreak_instr      (D_ebreak_instr),
      .D_ecall_instr       (D_ecall_instr),

      .D_fp_op_decode      (D_fp_op_decode),

      .D_expn              (D_expn),
      .D_expn_type         (D_expn_type),
      .C_debug_mode        (C_debug_mode),

      .D_gpr_incorrect     (D_gpr_incorrect),
      .D_fpr_incorrect     (D_fpr_incorrect),
      .D_instr_incorrect   (D_instr_incorrect),
      .D_itag_incorrect    (D_itag_incorrect)
   );

   //------------------------------------------------------//
   //------------- Simple ALU -----------------------------//
   //------------------------------------------------------//

   niosv_g_alu alu_inst (
      .clk (clk),
      .reset (internal_reset),

      .E_exe_s1                (E_exe_s1),
      .E_exe_s2                (E_exe_s2),
      .E_branch_op             (E_branch_op),
      .E_exe_op                (E_exe_op),
      .E_exe_result            (E_alu_result),
      .E_instr_pc_nxt          (E_nxt_seq_pc),
      .E_signed_cmp            (E_signed_cmp),
      .E_branch_tgt_pc         (E_branch_tgt_pc),
      .E_redirect              (E_redirect),
      .E_redirect_pc           (E_redirect_pc),
      .E_unaligned_redirect_pc (E_unaligned_redirect_pc),
      .E_alu_add_result        (E_ls_addr)
   );

   //------------------------------------------------------//
   //------------- Multiplier Unit ------------------------//
   //------------------------------------------------------//

   generate if (MULDIV_ENABLED) begin : gen_muldiv
      niosv_multiplier # (
         .DEVICE_FAMILY (DEVICE_FAMILY)
      ) mul_inst (
         .clk              (clk),
         .reset            (internal_reset),

         .E_mul_valid      (E_mul_valid),
         .E_src1           (E_rs1_gpr_val),
         .E_src2           (E_rs2_gpr_val),
         .E_mul_s1_signed  (E_mul_s1_signed),
         .E_mul_s2_signed  (E_mul_s2_signed),
         .E_mul_use_lsw    (E_mul_use_lsw),
         .M0_ready         (M0_ready),
         .M0_mul_pending   (M0_mul_pending),
         .M0_mul_done      (M0_mul_done),
         .M0_mul_result    (M0_mul_result)
      );

      niosv_divider div_inst (
         .clk              (clk),
         .reset            (internal_reset),

         .E_src1           (E_rs1_gpr_val),
         .E_src2           (E_rs2_gpr_val),
         .E_valid          (E_instr_valid),
         .E_exe_op         (E_exe_op),
         .M0_valid         (M0_instr_valid),
         .M0_div_op        (M0_div_op),
         .M0_div_stall     (M0_div_stall),
         .M0_div_done      (M0_div_done),
         .M0_div_result    (M0_div_result)
      );
      assign M0_div_pending = M0_div_op | M0_div_stall;
   end
   else begin : gen_muldiv_tieoff
      assign M0_mul_pending = 1'b0;
      assign M0_mul_done    = 1'b0;

      assign M0_div_stall   = 1'b0;
      assign M0_div_pending = 1'b0;
      assign M0_div_done    = 1'b0;
   end
   endgenerate

   //------------------------------------------------------//
   //------------- Load/Store Unit ------------------------//
   //------------------------------------------------------//

   niosv_g_dcache # (
      .RAM_TYPE                  (RAM_TYPE),
      .ATOMIC_ENABLED            (ATOMIC_ENABLED),
      .DEBUG_ENABLED             (DEBUG_ENABLED),
      .BOUNDARY_ADDRESS          (BOUNDARY_ADDRESS),
      .CACHE_ABOVE_RANGE         (CACHE_ABOVE_RANGE),
      .CACHE_SIZE                (DATA_CACHE_SIZE),
      .DBG_DATA_S_BASE           (DBG_DATA_S_BASE),
      .TIMER_MSIP_DATA_S_BASE    (TIMER_MSIP_DATA_S_BASE),
      .PERIPHERAL_REGION_A_SIZE  (PERIPHERAL_REGION_A_SIZE),
      .PERIPHERAL_REGION_A_BASE  (PERIPHERAL_REGION_A_BASE),
      .PERIPHERAL_REGION_B_SIZE  (PERIPHERAL_REGION_B_SIZE),
      .PERIPHERAL_REGION_B_BASE  (PERIPHERAL_REGION_B_BASE),
      .DTCM1_SIZE                (DTCM1_SIZE),
      .DTCM1_BASE                (DTCM1_BASE),
      .DTCM1_INIT_FILE           (DTCM1_INIT_FILE),
      .DTCM2_SIZE                (DTCM2_SIZE),
      .DTCM2_BASE                (DTCM2_BASE),
      .DTCM2_INIT_FILE           (DTCM2_INIT_FILE),
      .DEVICE_FAMILY             (DEVICE_FAMILY),
      .ECC_EN                    (ECC_EN),
      .DTCS1_ADDR_WIDTH          (DTCS1_ADDR_WIDTH),
      .DTCS2_ADDR_WIDTH          (DTCS2_ADDR_WIDTH)
   ) lsu_inst (
      .clk                       (clk),
      .reset                     (internal_reset),

      .ls_op_done                (M0_ls_op_done),
      .load_data                 (M0_load_data),
      .load_op                   (M0_load_op),
      .store_op                  (M0_store_op),
      .ls_instr_pending          (M0_ls_instr_pending),
      .ls_expn                   (M0_ls_expn),
      .ls_expn_type              (M0_ls_expn_type),
      .store_data                (M0_store_data),
      .M0_ls_addr                (M0_ls_addr),
      .ls_mem_size               (M0_mem_size),
      .ls_mem_byteen             (M0_mem_byteen),
      .ls_mem_signext            (M0_mem_signext),

      .amo_op                    (M0_amo_op),
      .amo_op_type               (M0_amo_op_type),
      .amo_rs2_val               (M0_rs2_gpr_val),

      .cmo_op                    (M0_cmo_op),
      .cmo_op_type               (M0_cmo_op_type),

      .ls_awaddr                 (data_awaddr),
      .ls_awprot                 (data_awprot),
      .ls_awvalid                (data_awvalid),
      .ls_awsize                 (data_awsize),
      .ls_awlen                  (data_awlen),
      .ls_awready                (data_awready),

      .ls_wvalid                 (data_wvalid),
      .ls_wdata                  (data_wdata),
      .ls_wstrb                  (data_wstrb),
      .ls_wlast                  (data_wlast),
      .ls_wready                 (data_wready),

      .ls_bvalid                 (data_bvalid),
      .ls_bresp                  (data_bresp),
      .ls_bready                 (data_bready),

      .ls_araddr                 (data_araddr),
      .ls_arprot                 (data_arprot),
      .ls_arvalid                (data_arvalid),
      .ls_arsize                 (data_arsize),
      .ls_arlen                  (data_arlen),
      .ls_arready                (data_arready),

      .ls_rdata                  (data_rdata),
      .ls_rvalid                 (data_rvalid),
      .ls_rresp                  (data_rresp),
      .ls_rready                 (data_rready),
      .ls_rlast                  (data_rlast),

      .E_ls_addr                 (E_ls_addr),
      .E_valid                   (E_instr_valid),
      .E_load_op                 (E_load_op),
      .E_store_op                (E_store_op),
      .E_amo_op                  (E_amo_op),
      .E_cmo_op                  (E_cmo_op),

      .M0_ready                  (M0_ready),

      .in_debug_mode             (C_debug_mode),

      .dram_eccstatus            (M0_dcache_data_ecc),
      .dtag_eccstatus            (M0_dcache_dtag_ecc),
      .dtcm1_eccstatus           (M0_dcache_dtcm1_ecc),
      .dtcm2_eccstatus           (M0_dcache_dtcm2_ecc),

      .M0_wait_for_irq           (M0_wait_for_irq),

      .dtcs1_awaddr              (dtcs1_awaddr),
      .dtcs1_awprot              (dtcs1_awprot),
      .dtcs1_awvalid             (dtcs1_awvalid),
      .dtcs1_awready             (dtcs1_awready),

      .dtcs1_wvalid              (dtcs1_wvalid),
      .dtcs1_wdata               (dtcs1_wdata),
      .dtcs1_wstrb               (dtcs1_wstrb),
      .dtcs1_wready              (dtcs1_wready),

      .dtcs1_bvalid              (dtcs1_bvalid),
      .dtcs1_bresp               (dtcs1_bresp),
      .dtcs1_bready              (dtcs1_bready),

      .dtcs1_araddr              (dtcs1_araddr),
      .dtcs1_arprot              (dtcs1_arprot),
      .dtcs1_arvalid             (dtcs1_arvalid),
      .dtcs1_arready             (dtcs1_arready),

      .dtcs1_rdata               (dtcs1_rdata),
      .dtcs1_rvalid              (dtcs1_rvalid),
      .dtcs1_rresp               (dtcs1_rresp),
      .dtcs1_rready              (dtcs1_rready),

      .dtcs2_awaddr              (dtcs2_awaddr),
      .dtcs2_awprot              (dtcs2_awprot),
      .dtcs2_awvalid             (dtcs2_awvalid),
      .dtcs2_awready             (dtcs2_awready),

      .dtcs2_wvalid              (dtcs2_wvalid),
      .dtcs2_wdata               (dtcs2_wdata),
      .dtcs2_wstrb               (dtcs2_wstrb),
      .dtcs2_wready              (dtcs2_wready),

      .dtcs2_bvalid              (dtcs2_bvalid),
      .dtcs2_bresp               (dtcs2_bresp),
      .dtcs2_bready              (dtcs2_bready),

      .dtcs2_araddr              (dtcs2_araddr),
      .dtcs2_arprot              (dtcs2_arprot),
      .dtcs2_arvalid             (dtcs2_arvalid),
      .dtcs2_arready             (dtcs2_arready),

      .dtcs2_rdata               (dtcs2_rdata),
      .dtcs2_rvalid              (dtcs2_rvalid),
      .dtcs2_rresp               (dtcs2_rresp),
      .dtcs2_rready              (dtcs2_rready)
   );

   assign C_addr  = E_csr_addr;

   // CSR write cannot be undone. Also, if write is asserted for two or more
   // cycles, mask0 value may result in incorrect value in CSR. Hence write to
   // CSR must be executed when there M0 op is done and there is no exception
   // from M0.
   // TODO: Can CSR read/write be moved to M0?
   assign C_read       = E_csr_read & E_instr_valid;  // TODO: Analyze read side effects
   assign C_set        = E_csr_set  & E_instr_valid;
   assign C_clr        = E_csr_clr  & E_instr_valid;
   assign C_write_data = E_exe_s1;
   assign E_expn       = C_csr_access_expn | E_iw_trigger | E_pc_trigger | E_unaligned_redir;
   assign E_expn_type  = (E_iw_trigger | E_pc_trigger) ? BREAKPOINT :
                          E_unaligned_redir            ? INSTR_ADDR_MISAL : ILLEGAL_INSTR;

   always @(*) begin
      C_write = 1'b0;

      if (E_csr_write & E_instr_valid & ~flush_E & ~(E_iw_trigger | E_pc_trigger)) begin
         C_write = M0_ready;
      end
   end

   // FPU state is potentially dirtied by instructions that write to FP registers or have
   // non-zero FP exception flags (FCVT.W[U].S and FCMP have an integer result with FP flags).
   // It's okay to mark FPU state "dirty" in cases where it doesn't actually get dirtied
   // e.g. write to an FPR that already contains the same value, FP load that fails, etc.

   always @(*) begin
      E_fpu_state_dirtied = E_fpr_wr_en |
                            (E_gpr_wr_en &
                             (E_fp_op_decode.is_fcvt_to_gpr_op |
                             (E_fp_op_decode.fcmp_op != FCMP_NOP)));
   end

   always @(*) begin
      if (M0_fpu_to_gpr_done | M0_fpu_to_fpr_done) begin
         M0_fpu_fflags = {M0_fpu_flags.nv,
                          M0_fpu_flags.dz,
                          M0_fpu_flags.of,
                          M0_fpu_flags.uf,
                          M0_fpu_flags.nx};
         M0_fpu_fflags_valid = FLOAT_ENABLED ? 1'b1 : 1'b0;
      end
      else begin
         M0_fpu_fflags = {M0_fpu_e_flags.nv,
                          M0_fpu_e_flags.dz,
                          M0_fpu_e_flags.of,
                          M0_fpu_e_flags.uf,
                          M0_fpu_e_flags.nx};
         M0_fpu_fflags_valid = (FLOAT_ENABLED ? 1'b1 : 1'b0)
                             & (M0_fpu_to_gpr_e_done | M0_fpu_to_fpr_e_done);
      end
   end

   niosv_csr # (
      .RESET_VECTOR        (RESET_VECTOR),
      .CORE_EXTN           (CORE_EXTN),
      .DEBUG_ENABLED       (DEBUG_ENABLED)
   ) csr_inst (
      .clk                 (clk),
      .reset               (internal_reset),

      // CSR SW read/write
      .csr_read            (C_read),
      .csr_write           (C_write),
      .csr_addr            (C_addr),
      .csr_write_data      (C_write_data),
      .csr_read_data       (C_read_data),
      .csr_set             (C_set),
      .csr_clr             (C_clr),
      .csr_access_expn     (C_csr_access_expn),

      // CSR exception update
      .csr_expn_update     (C_expn_update),
      .csr_expn_type       (C_expn_type),
      .csr_expn_pc         (C_expn_pc),
      .csr_expn_mtval      (C_expn_mtval),

      .csr_dbg_expn_update (C_dbg_expn_update),
      .csr_dbg_expn_type   (C_dbg_expn_type),
      .csr_dbg_expn_pc     (C_dbg_expn_pc),

      .expn_redir_pc       (C_expn_redirect_pc),  // Redirect PC for exceptions
      .csr_epc             (C_csr_epc),

      .debug_pc_wire       (C_debug_pc),

      .expn_ret            (M0_expn_ret),
      .dbg_ret             (M0_dbg_ret),

      .fpu_state_dirtied   (E_fpu_state_dirtied),
      .M_fpu_fflags        (M0_fpu_fflags),
      .M_fpu_fflags_valid  (M0_fpu_fflags_valid),

      .irq_timer           (irq_timer),
      .irq_sw              (irq_sw),
      .irq_plat_vec        (irq_plat_vec),
      .irq_ext             (irq_ext),

      .irq_debug           (irq_debug),

      .core_irq_en         (core_irq_en),
      .core_irq_priority   (core_irq_priority),
      .core_irq            (core_irq),
      .core_debug_irq      (core_debug_irq),
      .core_irq_pndg       (core_irq_pndg),

      .in_debug_mode       (C_debug_mode),
      .csr_step_en         (C_sstep_en),
      .ebreak_in_dm        (C_ebreak_in_dm),

      .plat_irq_num        (plat_irq_num),

      .trig_pc_en          (C_trig_pc_en),
      .trig_instr_en       (C_trig_iw_en),
      .trig_st_adrs_en     (C_trig_st_adrs_en),
      .trig_st_data_en     (C_trig_st_data_en),
      .trig_ld_adrs_en     (C_trig_ld_adrs_en),
      .trig_ld_data_en     (C_trig_ld_data_en),
      .trigger_in_dm       (C_trig_in_dm),

      .trig_tdata2         (C_tdata2)
   );

   //------------------------------------------------------//
   //------------- Floating-point Unit --------------------//
   //------------------------------------------------------//

   generate
      if (!FLOAT_ENABLED) begin : gen_fpu_tieoff
         assign D_long_fp_op          = 1'b0;
         assign E_fpu_to_fpr_done     = 1'b0;
         assign E_fpu_to_fpr_result   = 32'd0;
         assign E_fpu_to_gpr_done     = 1'b0;
         assign E_fpu_to_gpr_result   = 32'd0;
         assign E_fpu_flags           = deasserted_fp_flags();
         assign M0_fpu_op_pending     = 1'b0;
         assign M0_fpu_to_fpr_done    = 1'b0;
         assign M0_fpu_to_fpr_result  = 32'd0;
         assign M0_fpu_to_gpr_done    = 1'b0;
         assign M0_fpu_to_gpr_result  = 32'd0;
         assign M0_fpu_flags          = deasserted_fp_flags();
      end
      else begin : gen_fpu
         niosv_g_fpu # (
            .DEVICE_FAMILY        (DEVICE_FAMILY)
         ) fpu_inst (
            .clk                  (clk),
            .reset                (internal_reset),
            .flush_DE             (flush_E),
            .D_fp_op_decode       (D_fp_op_decode),
            .D_rs1_fpr_val        (D_rs1_fpr_val),
            .D_rs2_fpr_val        (D_rs2_fpr_val),
            .D_rs3_fpr_val        (D_rs3_fpr_val),
            .D_rs1_gpr_val        (D_rs1_gpr_val),
            .D_long_fp_op         (D_long_fp_op),
            .E_ready              (E_ready),
            .E_instr_valid        (E_instr_valid),
            .E_gpr_wr_en          (E_gpr_wr_en),
            .E_fpu_to_fpr_done    (E_fpu_to_fpr_done),
            .E_fpu_to_fpr_result  (E_fpu_to_fpr_result),
            .E_fpu_to_gpr_done    (E_fpu_to_gpr_done),
            .E_fpu_to_gpr_result  (E_fpu_to_gpr_result),
            .E_fpu_flags          (E_fpu_flags),
            .M_fpu_op_pending     (M0_fpu_op_pending),
            .M_fpu_to_fpr_done    (M0_fpu_to_fpr_done),
            .M_fpu_to_fpr_result  (M0_fpu_to_fpr_result),
            .M_fpu_to_gpr_done    (M0_fpu_to_gpr_done),
            .M_fpu_to_gpr_result  (M0_fpu_to_gpr_result),
            .M_fpu_flags          (M0_fpu_flags)
         );
      end
   endgenerate

   // -------------------------- Reset Control ----------------------//

   // This is required so that reset_req_ack is not sent when instr request is pending or backpressured.
   //assign nxt_reset_req_done = USE_RESET_REQ ? C_reset_req_flush & (~(instr_req_q & instr_waitreq_q)) & ~instr_req_pending : 1'b0;
   assign nxt_reset_req_done = USE_RESET_REQ && C_reset_req_flush && PC_reset_ack;

   always @(posedge clk, posedge reset) begin
      if (reset) begin
         reset_req_done_q <= {RST_REQ_DEPTH{1'b0}};
      end
      else begin
         reset_req_done_q[0] <= nxt_reset_req_done;
         reset_req_done_q[RST_REQ_DEPTH-1:1] <= reset_req_done_q[RST_REQ_DEPTH-2:0];
      end
   end

   assign reset_req_ack = reset_req_ack_reg;

   // reset_req_ack pulse
   always @(posedge clk) begin
      reset_req_ack_reg <= reset_req_done_q[8] & ~reset_req_ack;
   end

   generate
      if (USE_RESET_REQ) begin : gen_reset_req_handler
         altera_reset_controller # (
            .NUM_RESET_INPUTS (2),
            .ADAPT_RESET_REQUEST (1)
         ) rst_ctrl_inst (
            .clk              (clk),

            .reset_in0        (reset),
            .reset_in1        (reset_req_done_q[2]),

            .reset_out        (internal_reset),

            // Unused Ports
            .reset_in2        (1'b0),
            .reset_in3        (1'b0),
            .reset_in4        (1'b0),
            .reset_in5        (1'b0),
            .reset_in6        (1'b0),
            .reset_in7        (1'b0),
            .reset_in8        (1'b0),
            .reset_in9        (1'b0),
            .reset_in10       (1'b0),
            .reset_in11       (1'b0),
            .reset_in12       (1'b0),
            .reset_in13       (1'b0),
            .reset_in14       (1'b0),
            .reset_in15       (1'b0),
            .reset_req_in0    (1'b0),
            .reset_req_in1    (1'b0),
            .reset_req_in2    (1'b0),
            .reset_req_in3    (1'b0),
            .reset_req_in4    (1'b0),
            .reset_req_in5    (1'b0),
            .reset_req_in6    (1'b0),
            .reset_req_in7    (1'b0),
            .reset_req_in8    (1'b0),
            .reset_req_in9    (1'b0),
            .reset_req_in10   (1'b0),
            .reset_req_in11   (1'b0),
            .reset_req_in12   (1'b0),
            .reset_req_in13   (1'b0),
            .reset_req_in14   (1'b0),
            .reset_req_in15   (1'b0),
            .reset_req        ()
         );
      end
      else begin : gen_reset_req_tieoff
         assign internal_reset = reset;
      end
   endgenerate

   // ECC Related Logic
   assign D_gpr_ecc = D_rs1_gpr_ecc | D_rs2_gpr_ecc;
   assign D_fpr_ecc = D_rs1_fpr_ecc | D_rs2_fpr_ecc | D_rs3_fpr_ecc;

   assign D_gpr_incorrect = (D_rs1_gpr_ecc == 2'b11) | (D_rs2_gpr_ecc == 2'b11);
   assign D_fpr_incorrect = (D_rs1_fpr_ecc == 2'b11) | (D_rs2_fpr_ecc == 2'b11) | (D_rs3_fpr_ecc == 2'b11);

   assign M0_data_incorrect  = M0_ls_op_done & M0_load_en & (M0_dcache_data_ecc == 2'b11);
   assign M0_dtag_incorrect  = M0_ls_op_done & M0_load_en & (M0_dcache_dtag_ecc == 2'b11);
   assign M0_dtcm1_incorrect = M0_ls_op_done & M0_load_en & (M0_dcache_dtcm1_ecc == 2'b11);
   assign M0_dtcm2_incorrect = M0_ls_op_done & M0_load_en & (M0_dcache_dtcm2_ecc == 2'b11);

   // Preserve worst scenario and associated registers
   // Software write to ecc_status and ecc_src will clear these.
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_gpr_ecc <= 2'b00;
         M0_gpr_ecc <= 2'b00;

         E_fpr_ecc <= 2'b00;
         M0_fpr_ecc <= 2'b00;

         E_instr_ecc <= 4'b00;
         E_itag_ecc <= 2'b00;

         M0_instr_ecc <= 4'b00;
         M0_itag_ecc <= 2'b00;

         M0_dcache_data_ecc_q <= 2'b00;
         M0_dcache_dtag_ecc_q <= 2'b00;
         M0_dcache_dtcm1_ecc_q <= 2'b00;
         M0_dcache_dtcm2_ecc_q <= 2'b00;

         M0_ecc_stall <= 1'b0;
      end
      else begin
         if (M0_ecc_wait_for_nmi)
            M0_ecc_stall <= 1'b1;

         if (E_ready & D_instr_valid & ~flush_D & ~(D_dep_stall_from_E | D_dep_stall_from_M0)) begin
            if ((~E_gpr_ecc[0] & D_gpr_ecc[0]) | (~E_gpr_ecc[1] & D_gpr_ecc[1])) begin
               E_gpr_ecc <= D_gpr_ecc;
            end

            if ((~E_fpr_ecc[0] & D_fpr_ecc[0]) | (~E_fpr_ecc[1] & D_fpr_ecc[1])) begin
               E_fpr_ecc <= D_fpr_ecc;
            end

            if ((~E_instr_ecc[0] & D_instr_ecc[0]) | (~E_instr_ecc[1] & D_instr_ecc[1])) begin
               E_instr_ecc <= D_instr_ecc;
            end

            if ((~E_itag_ecc[0] & D_itag_ecc[0]) | (~E_itag_ecc[1] & D_itag_ecc[1])) begin
               E_itag_ecc <= D_itag_ecc;
            end

         end

         if (M0_ready & E_instr_valid) begin
            M0_gpr_ecc   <= E_gpr_ecc;
            M0_fpr_ecc   <= E_fpr_ecc;
            M0_instr_ecc <= E_instr_ecc;
            M0_itag_ecc  <= E_itag_ecc;
         end

         if (M0_ls_op_done & M0_load_en) begin
            if ((~M0_dcache_data_ecc_q[0] & M0_dcache_data_ecc[0]) | (~M0_dcache_data_ecc_q[1] & M0_dcache_data_ecc[1])) begin
               M0_dcache_data_ecc_q <= M0_dcache_data_ecc;
            end

            if ((~M0_dcache_dtag_ecc_q[0] & M0_dcache_dtag_ecc[0]) | (~M0_dcache_dtag_ecc_q[1] & M0_dcache_dtag_ecc[1])) begin
               M0_dcache_dtag_ecc_q <= M0_dcache_dtag_ecc;
            end

            if ((~M0_dcache_dtcm1_ecc_q[0] & M0_dcache_dtcm1_ecc[0]) | (~M0_dcache_dtcm1_ecc_q[1] & M0_dcache_dtcm1_ecc[1])) begin
               M0_dcache_dtcm1_ecc_q <= M0_dcache_dtcm1_ecc;
            end

            if ((~M0_dcache_dtcm2_ecc_q[0] & M0_dcache_dtcm2_ecc[0]) | (~M0_dcache_dtcm2_ecc_q[1] & M0_dcache_dtcm2_ecc[1])) begin
               M0_dcache_dtcm2_ecc_q <= M0_dcache_dtcm2_ecc;
            end
         end
      end
   end

   always @(posedge clk) begin
      if (E_ready & D_instr_valid & ~flush_D & ~(D_dep_stall_from_E | D_dep_stall_from_M0)) begin
         if ((~E_gpr_ecc[0] & D_gpr_ecc[0]) | (~E_gpr_ecc[1] & D_gpr_ecc[1]) |
            (~E_fpr_ecc[0] & D_fpr_ecc[0]) | (~E_fpr_ecc[1] & D_fpr_ecc[1])) begin
            E_ecc_rs1 <= D_iw_rs1;
            E_ecc_rs2 <= D_iw_rs2;
         end
      end

      if (M0_ready & E_instr_valid & ~flush_E) begin
         M0_ecc_rs1 <= E_ecc_rs1;
         M0_ecc_rs2 <= E_ecc_rs2;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         ecc_status <= 6'b0;
         ecc_src <= 32'b0;
      end
      else if (M0_instr_valid) begin
         if (|M0_gpr_ecc) begin
            ecc_status <= {4'd1, M0_gpr_ecc};
            //ecc_src[RS1_FIELD_H:RS1_FIELD_L] <= M0_ecc_rs1;
            //ecc_src[RS2_FIELD_H:RS2_FIELD_L] <= M0_ecc_rs2;
         end
         else if (|M0_fpr_ecc) begin  // ECC status for FPR
            ecc_status <= {4'd10, M0_fpr_ecc};
            //ecc_src[RS1_FIELD_H:RS1_FIELD_L] <= M0_ecc_rs1;
            //ecc_src[RS2_FIELD_H:RS2_FIELD_L] <= M0_ecc_rs2;
         end
         else if (|M0_instr_ecc[1:0]) begin
            ecc_status[5:2] <= (M0_instr_ecc[3:2] == 2'b01) ? 4'd6 : (M0_instr_ecc[3:2] == 2'b11) ? 4'd7 : 4'd2;  // selection between instr cache , itcm1/itcm2
            ecc_status[1:0] <= M0_instr_ecc[1:0];
         end
         else if (|M0_itag_ecc) begin
            ecc_status <= {4'd3, M0_itag_ecc};
         end
      end
      else if (M0_ls_op_done & M0_load_en) begin
         if (|M0_dcache_data_ecc) begin
            ecc_status <= {4'd4, M0_dcache_data_ecc};
         end
         else if (|M0_dcache_dtag_ecc) begin
            ecc_status <= {4'd5, M0_dcache_dtag_ecc};
         end
         else if (|M0_dcache_dtcm1_ecc) begin
            ecc_status <= {4'd8, M0_dcache_dtcm1_ecc};
         end
         else if (|M0_dcache_dtcm2_ecc) begin
            ecc_status <= {4'd9, M0_dcache_dtcm2_ecc};
         end
      end
   end

   assign {core_ecc_src, core_ecc_status} = ecc_status;

endmodule

`default_nettype wire

