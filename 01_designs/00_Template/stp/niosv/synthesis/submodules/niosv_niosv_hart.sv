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


`timescale 1 ns / 1 ns
import niosv_opcode_def::*;

module niosv_niosv_hart # (
   parameter DBG_EXPN_VECTOR = 32'h80000000,
   parameter RESET_VECTOR = 32'h00000000,
   parameter CORE_EXTN = 26'h0000100, // RV32I
   parameter DEBUG_ENABLED = 1'b0,
   parameter DEVICE_FAMILY = "Stratix 10",
   parameter DBG_PARK_LOOP_OFFSET = 32'd24,
   parameter USE_RESET_REQ = 1'b0,
   parameter DBG_DATA_S_BASE = 32'h000A0000,
   parameter TIMER_MSIP_DATA_S_BASE = 32'h000B0000,
   parameter DATA_CACHE_SIZE = 4096,
   parameter INST_CACHE_SIZE = 4096,
   parameter ITCM1_SIZE = 0,
   parameter ITCM1_BASE = 32'h0,
   parameter ITCM1_INIT_FILE = "UNUSED",
   parameter ITCM2_SIZE = 0,
   parameter ITCM2_BASE = 32'h0,
   parameter ITCM2_INIT_FILE = "UNUSED",
   parameter PERIPHERAL_REGION_A_SIZE = 0,
   parameter PERIPHERAL_REGION_A_BASE = 32'h0,
   parameter PERIPHERAL_REGION_B_SIZE = 0,
   parameter PERIPHERAL_REGION_B_BASE = 32'h0,
   parameter DTCM1_SIZE = 0,
   parameter DTCM1_BASE = 32'h0,
   parameter DTCM1_INIT_FILE = "UNUSED",
   parameter DTCM2_SIZE = 0,
   parameter DTCM2_BASE = 32'h0,
   parameter DTCM2_INIT_FILE = "UNUSED",
   parameter ECC_EN = 1'b0,
   parameter ITCS1_ADDR_WIDTH = 4'd10,
   parameter ITCS2_ADDR_WIDTH = 4'd10,
   parameter DTCS1_ADDR_WIDTH = 4'd10,
   parameter DTCS2_ADDR_WIDTH = 4'd10
) (

   input wire clk,
   input wire reset,
   input wire reset_req,
   output wire reset_req_ack,

   // write command
   //    address
   output wire [31:0]       instr_awaddr,
   output wire [2:0]        instr_awprot,
   output wire              instr_awvalid,
   output wire [2:0]        instr_awsize,
   output wire [7:0]        instr_awlen,
   output wire [1:0]        instr_awburst,
   input                    instr_awready,
   //  data
   output wire              instr_wvalid,
   output wire [31:0]       instr_wdata,
   output wire [3:0]        instr_wstrb,
   output wire              instr_wlast,
   input                    instr_wready,
 
   //write response
   input                    instr_bvalid,
   input [1:0]              instr_bresp,
   output wire              instr_bready,
 
   //read command
   output wire [31:0]       instr_araddr,
   output wire [2:0]        instr_arprot,
   output wire              instr_arvalid,
   output wire [2:0]        instr_arsize,
   output wire [7:0]        instr_arlen,
   output wire [1:0]        instr_arburst,
   input                    instr_arready,
 
   //read response
   input [31:0]             instr_rdata,
   input                    instr_rvalid,
   input [1:0]              instr_rresp,
   input                    instr_rlast,
   output wire              instr_rready,

   // write command
   //    address
   output wire [ADDR_W-1:0] data_awaddr,
   output wire [2:0]        data_awprot,
   output wire              data_awvalid,
   output wire [2:0]        data_awsize,
   output wire [7:0]        data_awlen,
   input                    data_awready,
   //  data
   output wire              data_wvalid,
   output wire [DATA_W-1:0] data_wdata,
   output wire [3:0]        data_wstrb,
   output wire              data_wlast,
   input                    data_wready,
 
   //write response
   input                    data_bvalid,
   input [1:0]              data_bresp,
   output wire              data_bready,
 
   //read command
   output wire [ADDR_W-1:0] data_araddr,
   output wire [2:0]        data_arprot,
   output wire              data_arvalid,
   output wire [2:0]        data_arsize,
   output wire [7:0]        data_arlen,
   input                    data_arready,
 
   //read response
   input [DATA_W-1:0]       data_rdata,
   input                    data_rvalid,
   input [1:0]              data_rresp,
   input                    data_rlast,
   output wire              data_rready,


   input wire        irq_timer,
   input wire        irq_sw,
   input wire [15:0] irq_plat_vec,
   input wire        irq_ext,

   input wire        irq_debug,

   output wire [1:0] core_ecc_status,
   output wire [3:0] core_ecc_src,

   // axi4-lite interface to access ITCM1
   // write command
   //    address
   input wire [ITCS1_ADDR_WIDTH-1:0]       itcs1_awaddr,
   input wire [2:0]        itcs1_awprot,
   input wire              itcs1_awvalid,
   output                  itcs1_awready,
   //  data
   input wire              itcs1_wvalid,
   input wire [31:0]       itcs1_wdata,
   input wire [3:0]        itcs1_wstrb,
   output                  itcs1_wready,
 
   //write response
   output                  itcs1_bvalid,
   output [1:0]            itcs1_bresp,
   input wire              itcs1_bready,
 
   //read command
   input wire [ITCS1_ADDR_WIDTH-1:0]       itcs1_araddr,
   input wire [2:0]        itcs1_arprot,
   input wire              itcs1_arvalid,
   output                  itcs1_arready,
 
   //read response
   output [31:0]           itcs1_rdata,
   output                  itcs1_rvalid,
   output [1:0]            itcs1_rresp,
   input wire              itcs1_rready,

   // axi4-lite interface to access ITCM2
   // write command
   //    address
   input wire [ITCS2_ADDR_WIDTH-1:0]       itcs2_awaddr,
   input wire [2:0]        itcs2_awprot,
   input wire              itcs2_awvalid,
   output                  itcs2_awready,
   //  data
   input wire              itcs2_wvalid,
   input wire [31:0]       itcs2_wdata,
   input wire [3:0]        itcs2_wstrb,
   output                  itcs2_wready,
 
   //write response
   output                  itcs2_bvalid,
   output [1:0]            itcs2_bresp,
   input wire              itcs2_bready,
 
   //read command
   input wire [ITCS2_ADDR_WIDTH-1:0]       itcs2_araddr,
   input wire [2:0]        itcs2_arprot,
   input wire              itcs2_arvalid,
   output                  itcs2_arready,
 
   //read response
   output [31:0]           itcs2_rdata,
   output                  itcs2_rvalid,
   output [1:0]            itcs2_rresp,
   input wire              itcs2_rready,


   // axi4-lite interface to access DTCM1
   // write command
   //    address
   input wire [DTCS1_ADDR_WIDTH-1:0]       dtcs1_awaddr,
   input wire [2:0]        dtcs1_awprot,
   input wire              dtcs1_awvalid,
   output                  dtcs1_awready,
   //  data
   input wire              dtcs1_wvalid,
   input wire [31:0]       dtcs1_wdata,
   input wire [3:0]        dtcs1_wstrb,
   output                  dtcs1_wready,
 
   //write response
   output                  dtcs1_bvalid,
   output [1:0]            dtcs1_bresp,
   input wire              dtcs1_bready,
 
   //read command
   input wire [DTCS1_ADDR_WIDTH-1:0]       dtcs1_araddr,
   input wire [2:0]        dtcs1_arprot,
   input wire              dtcs1_arvalid,
   output                  dtcs1_arready,
 
   //read response
   output [31:0]           dtcs1_rdata,
   output                  dtcs1_rvalid,
   output [1:0]            dtcs1_rresp,
   input wire              dtcs1_rready,

   // axi4-lite interface to access DTCM2
   // write command
   //    address
   input wire [DTCS2_ADDR_WIDTH-1:0]       dtcs2_awaddr,
   input wire [2:0]        dtcs2_awprot,
   input wire              dtcs2_awvalid,
   output                  dtcs2_awready,
   //  data
   input wire              dtcs2_wvalid,
   input wire [31:0]       dtcs2_wdata,
   input wire [3:0]        dtcs2_wstrb,
   output                  dtcs2_wready,
 
   //write response
   output                  dtcs2_bvalid,
   output [1:0]            dtcs2_bresp,
   input wire              dtcs2_bready,
 
   //read command
   input wire [DTCS2_ADDR_WIDTH-1:0]       dtcs2_araddr,
   input wire [2:0]        dtcs2_arprot,
   input wire              dtcs2_arvalid,
   output                  dtcs2_arready,
 
   //read response
   output [31:0]           dtcs2_rdata,
   output                  dtcs2_rvalid,
   output [1:0]            dtcs2_rresp,
   input wire              dtcs2_rready


);

   wire [31:0] core_ci_data0;
   wire [31:0] core_ci_data1;
   wire [31:0] core_ci_alu_result;
   wire [31:0] core_ci_ctrl;
   wire        core_ci_enable;
   wire [3:0]  core_ci_op;
   reg  [31:0] core_ci_result_int;
   wire [31:0] core_ci_result;
   wire        core_ci_done;

   wire [F7_FIELD_W-1:0] core_ci_f7 = core_ci_ctrl[F7_FIELD_H:F7_FIELD_L]; 

   niosv_g_core_niosv_niosv_hart # (
      .DBG_EXPN_VECTOR     (DBG_EXPN_VECTOR     ), 
      .RESET_VECTOR        (RESET_VECTOR        ),
      .USE_RESET_REQ       (USE_RESET_REQ       ), 
      .CORE_EXTN           (CORE_EXTN           ),
      .DEBUG_ENABLED       (DEBUG_ENABLED       ),
      .DEVICE_FAMILY       (DEVICE_FAMILY       ),
      .DBG_PARK_LOOP_OFFSET(DBG_PARK_LOOP_OFFSET),
      // TODO: replace this with the new perpipheral region parameters 
      .BOUNDARY_ADDRESS    (32'h00000000        ),
      .CACHE_ABOVE_RANGE   (0                   ),

      .DBG_DATA_S_BASE   (DBG_DATA_S_BASE),
      .TIMER_MSIP_DATA_S_BASE     (TIMER_MSIP_DATA_S_BASE),
      .DATA_CACHE_SIZE   (DATA_CACHE_SIZE),
      .INST_CACHE_SIZE   (INST_CACHE_SIZE),
      .ITCM1_SIZE (ITCM1_SIZE),
      .ITCM1_BASE (ITCM1_BASE),
      .ITCM1_INIT_FILE (ITCM1_INIT_FILE),
      .ITCM2_SIZE (ITCM2_SIZE),
      .ITCM2_BASE (ITCM2_BASE),
      .ITCM2_INIT_FILE (ITCM2_INIT_FILE),      
      .PERIPHERAL_REGION_A_SIZE (PERIPHERAL_REGION_A_SIZE),
      .PERIPHERAL_REGION_A_BASE (PERIPHERAL_REGION_A_BASE),
      .PERIPHERAL_REGION_B_SIZE (PERIPHERAL_REGION_B_SIZE),
      .PERIPHERAL_REGION_B_BASE (PERIPHERAL_REGION_B_BASE),
      .DTCM1_SIZE (DTCM1_SIZE),
      .DTCM1_BASE (DTCM1_BASE),
      .DTCM1_INIT_FILE (DTCM1_INIT_FILE),
      .DTCM2_SIZE (DTCM2_SIZE),
      .DTCM2_BASE (DTCM2_BASE),
      .DTCM2_INIT_FILE (DTCM2_INIT_FILE),
      .ECC_EN (ECC_EN),
      .ITCS1_ADDR_WIDTH (ITCS1_ADDR_WIDTH),
      .ITCS2_ADDR_WIDTH (ITCS2_ADDR_WIDTH),
      .DTCS1_ADDR_WIDTH (DTCS1_ADDR_WIDTH),
      .DTCS2_ADDR_WIDTH (DTCS2_ADDR_WIDTH)
   ) core_inst (
      .* 
   );
   assign core_ci_done = 1'b0;
   assign core_ci_result = 32'b0;




endmodule

