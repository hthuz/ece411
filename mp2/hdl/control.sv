
module control
import rv32i_types::*; /* Import types defined in rv32i_types.sv */
(
    input clk,
    input rst,
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic br_en,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic mem_resp,
    output pcmux::pcmux_sel_t pcmux_sel,
    output alumux::alumux1_sel_t alumux1_sel,
    output alumux::alumux2_sel_t alumux2_sel,
    output regfilemux::regfilemux_sel_t regfilemux_sel,
    output marmux::marmux_sel_t marmux_sel,
    output cmpmux::cmpmux_sel_t cmpmux_sel,
    output alu_ops aluop,
    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_data_out,
    output logic mem_read,
    output logic mem_write
);

/***************** USED BY RVFIMON --- ONLY MODIFY WHEN TOLD *****************/
logic trap;
logic [4:0] rs1_addr, rs2_addr;
logic [3:0] rmask, wmask;
/*****************************************************************************/

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;

assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign rs1_addr = rs1;
assign rs2_addr = rs2;

always_comb
begin : trap_check
    trap = '0;
    rmask = '0;
    wmask = '0;

    case (opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr:;

        op_br: begin
            case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = '1;
            endcase
        end

        op_load: begin
            case (load_funct3)
                lw: rmask = 4'b1111;
                lh, lhu: rmask = 4'bXXXX /* Modify for MP2 Final */ ;
                lb, lbu: rmask = 4'bXXXX /* Modify for MP2 Final */ ;
                default: trap = '1;
            endcase
        end

        op_store: begin
            case (store_funct3)
                sw: wmask = 4'b1111;
                sh: wmask = 4'bXXXX /* Modify for MP2 Final */ ;
                sb: wmask = 4'bXXXX /* Modify for MP2 Final */ ;
                default: trap = '1;
            endcase
        end

        default: trap = '1;
    endcase
end
/*****************************************************************************/

enum int unsigned {
    /* List of states */
    s_fetch1, s_fetch2, s_fetch3,
    s_decode,
    s_imm,
    s_lui,
    s_auipc,
    s_br,
    s_calc_addr,
    s_ld1, s_ld2,
    s_st1, s_st2
} state, next_state;

/************************* Function Definitions *******************************/
/**
 *  You do not need to use these functions, but it can be nice to encapsulate
 *  behavior in such a way.  For example, if you use the `loadRegfile`
 *  function, then you only need to ensure that you set the load_regfile bit
 *  to 1'b1 in one place, rather than in many.
 *
 *  SystemVerilog functions must take zero "simulation time" (as opposed to 
 *  tasks).  Thus, they are generally synthesizable, and appropraite
 *  for design code.  Arguments to functions are, by default, input.  But
 *  may be passed as outputs, inouts, or by reference using the `ref` keyword.
**/

/**
 *  Rather than filling up an always_block with a whole bunch of default values,
 *  set the default values for controller output signals in this function,
 *   and then call it at the beginning of your always_comb block.
**/
function void set_defaults();
    load_pc = 1'b0;
    load_ir = 1'b0;
    load_mar = 1'b0;
    load_mdr = 1'b0;
    load_regfile = 1'b0;
    load_data_out = 1'b0;

    mem_read = 1'b0;
    mem_write = 1'b0;

    pcmux_sel = pcmux::pc_plus4;
    alumux1_sel = alumux::rs1_out;
    alumux2_sel = alumux::i_imm;
    regfilemux_sel = regfilemux::alu_out;
    marmux_sel = marmux::pc_out;
    cmpmux_sel = cmpmux::rs2_out;
endfunction

/**
 *  Use the next several functions to set the signals needed to
 *  load various registers
**/
function void loadPC(pcmux::pcmux_sel_t sel);
    load_pc = 1'b1;
    pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
endfunction

function void loadMAR(marmux::marmux_sel_t sel);
    load_mar = 1'b1;
    marmux_sel = sel;
endfunction

function void loadMDR();
    load_mdr = 1'b1;
endfunction

function void loadIR();
    load_ir = 1'b1;
endfunction

function void setALU(alumux::alumux1_sel_t sel1, alumux::alumux2_sel_t sel2, logic setop, alu_ops op);
    /* Student code here */


    if (setop)
        aluop = op; // else default value
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
endfunction

/*****************************************************************************/

    /* Remember to deal with rst signal */

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    case(state) 
        s_fetch1: begin 
            load_pc(pcmux::pc_plus4);
            loadMAR(marmux::pc_out);
        end

        s_fetch2: begin
            loadMDR();
        end

        s_fetch3: begin 
            loadIR();
        end

        s_decode: begin 

        end

        s_imm: begin 

        end

        s_lui: begin  

        end 

        s_auipc: begin 

        end

        s_br: begin 

        end

        s_calc_addr: begin 


        end

        s_ld1: begin 

        end

        s_ld2: begin 

        end

        s_st1: begin

        end

        s_st2: begin

        end
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */

     case(state)
         s_fetch1: 
             next_state = s_fetch2;
         s_fetch2:
             if(mem_resp)
                 next_state = s_fetch3;
             else
                 next_state = s_fetch2;
         s_fetch3:
             next_state = s_decode;
         s_decode:
             case(opcode)
                 rv32i_opcode::op_lui: next_state = s_lui;
                 rv32i_opcode::op_auipc: next_state = s_auipc;
                 rv32i_opcode::op_jal: ;
                 rv32i_opcode::op_jalr: ;
                 rv32i_opcode::op_br: next_state = s_br;
                 rv32i_opcode::op_load: ;
                 rv32i_opcode::op_store: ;
                 rv32i_opcode::op_imm: next_state = s_imm;
                 rv32i_opcode::op_reg: ;
                 rv32i_opcode::op_csr: ;
             endcase
        s_imm:
            next_state = s_fetch1;
        s_lui:
            next_state = s_fetch1;
        s_calc_addr: ;
        s_ld1:
            if(mem_resp)
                next_state = s_ld2;
            else
                next_state = s_ld1;
        s_ld2:
            next_state = s_fetch1;
        s_st1:
            if(mem_resp)
                next_state = s_st2;
            else
                next_state = s_st1;
        s_st2:
            next_state = s_fetch1;
        s_auipc:
            next_state = s_fetch1;
        s_br:
            next_state = s_fetch1;
     endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst) 
        state <= s_fetch1;
    else
        state <= next_state;
end

endmodule : control
