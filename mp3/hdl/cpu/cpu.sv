
module cpu
import rv32i_types::*;
(
    input clk,
    input rst,
    input mem_resp,
    input rv32i_word mem_rdata,
    output logic mem_read,
    output logic mem_write,
    output logic [3:0] mem_byte_enable,
    output rv32i_word mem_address,
    output rv32i_word mem_wdata
);

/******************* Signals Needed for RVFI Monitor *************************/
logic load_pc;
logic load_regfile;
/*****************************************************************************/
logic load_ir;
logic load_mar;
logic load_mdr;
logic load_data_out;


alu_ops aluop;
branch_funct3_t cmp_op;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;
logic br_en;
logic [31:0] i_imm;
logic [31:0] s_imm;
logic [31:0] b_imm;
logic [31:0] u_imm;
logic [31:0] j_imm;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;

logic [1:0] mar_lower;
/**************************** Control Signals ********************************/
pcmux::pcmux_sel_t pcmux_sel;
alumux::alumux1_sel_t alumux1_sel;
alumux::alumux2_sel_t alumux2_sel;
regfilemux::regfilemux_sel_t regfilemux_sel;
marmux::marmux_sel_t marmux_sel;
cmpmux::cmpmux_sel_t cmpmux_sel;
/*****************************************************************************/

/* Instantiate MP 1 top level blocks here */

// Keep control named `control` for RVFI Monitor
control control(.*);

// Keep datapath named `datapath` for RVFI Monitor
datapath datapath(.*);

endmodule : cpu
