
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
    output branch_funct3_t cmp_op,
    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_data_out,
    output logic mem_read,
    output logic mem_write,
    output logic [3:0] mem_byte_enable
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
    load_regfile = 1'b1;
    regfilemux_sel = sel;
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

function void loadDataOut();
    load_data_out = 1'b1;
endfunction

function void setALU(alumux::alumux1_sel_t sel1, alumux::alumux2_sel_t sel2, logic setop, alu_ops op);
    /* Student code here */
    alumux1_sel = sel1;
    alumux2_sel = sel2;
    if (setop)
        aluop = op; // else default value
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
    cmpmux_sel = sel;
    cmp_op = op;
endfunction

function void imm_choose_op();
    if(arith_funct3 == slt) begin
        setCMP(cmpmux::i_imm, blt);
        loadRegfile(regfilemux::br_en);
    end
    else if (arith_funct3 == sltu) begin
        setCMP(cmpmux::i_imm, bltu);
        loadRegfile(regfilemux::br_en);
    end
    else if(arith_funct3 == sr) begin // SRAI, SRLI
        if (funct7 == 7'b0100000 ) // SRAI
            setALU(alumux::rs1_out, alumux::i_imm, 1, alu_sra);
        else // SRLI
            setALU(alumux::rs1_out, alumux::i_imm, 1, alu_srl);
        loadRegfile(regfilemux::alu_out);
    end
    else begin // SLLI, XOR, OR, AND
        setALU(alumux::rs1_out, alumux::i_imm, 1, funct3);
        loadRegfile(regfilemux::alu_out);
    end


endfunction

function void reg_choose_op();
    if(arith_funct3 == add)  begin
        if (funct7 == 7'b0100000 ) // SUB
            setALU(alumux::rs1_out, alumux::rs2_out, 1, alu_sub);
        else // ADD
            setALU(alumux::rs1_out, alumux::rs2_out, 1, alu_add);
        loadRegfile(regfilemux::alu_out);
    end 
    else if(arith_funct3 == slt) begin // SLT
        setCMP(cmpmux::rs2_out, blt);
        loadRegfile(regfilemux::br_en);
    end
    else if (arith_funct3 == sltu) begin // SLTU
        setCMP(cmpmux::rs2_out, bltu);
        loadRegfile(regfilemux::br_en);
    end
    else if(arith_funct3 == sr) begin // SRA, SRL
        if (funct7 == 7'b0100000 ) // SRA
            setALU(alumux::rs1_out, alumux::rs2_out, 1, alu_sra);
        else // SRLI
            setALU(alumux::rs1_out, alumux::rs2_out, 1, alu_srl);
        loadRegfile(regfilemux::alu_out);
    end
    else begin // SLL, XOR, OR, AND
        setALU(alumux::rs1_out, alumux::rs2_out, 1, funct3);
        loadRegfile(regfilemux::alu_out);
    end
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
            loadMAR(marmux::pc_out);
        end

        s_fetch2: begin
            loadMDR();
            mem_read = 1'b1;
        end

        s_fetch3: begin 
            loadIR();
        end

        s_decode: begin 

        end

        s_imm: begin 
            // 
            if(opcode == op_imm)
                imm_choose_op();
            // Opcode is op_reg
            else begin
                reg_choose_op();
            end
            loadPC(pcmux::pc_plus4);
        end

        s_lui: begin  
            loadRegfile(regfilemux::u_imm);
            loadPC(pcmux::pc_plus4);
        end 

        s_auipc: begin 
            setALU(alumux::pc_out,alumux::u_imm, 1,alu_add);
            loadRegfile(regfilemux::alu_out);
            loadPC(pcmux::pc_plus4);
        end

        s_br: begin 
            setCMP(cmpmux::rs2_out, branch_funct3);
            setALU(alumux::pc_out, alumux::b_imm, 1,alu_add);
            if(br_en)
                loadPC(pcmux::alu_out);
            else
                loadPC(pcmux::pc_plus4);
        end

        s_calc_addr: begin 
            if(opcode == op_load)
                setALU(alumux::rs1_out, alumux::i_imm, 1, alu_add);
            else begin// Store
                setALU(alumux::rs1_out, alumux::s_imm, 1, alu_add);
                // Store wdata beforehand to get it prepared
                loadDataOut();
            end
            loadMAR(marmux::alu_out);
        end

        s_ld1: begin 
            mem_read = 1'b1;
            loadMDR();
        end

        s_ld2: begin 
            case(load_funct3)
                lb : loadRegfile(regfilemux::lb);
                lh : loadRegfile(regfilemux::lh);
                lw : loadRegfile(regfilemux::lw);
                lbu : loadRegfile(regfilemux::lbu);
                lhu : loadRegfile(regfilemux::lhu);
            endcase
            loadPC(pcmux::pc_plus4);
        end

        s_st1: begin
            mem_write = 1'b1;
            case(store_funct3) 
                sb : ;
                sh : ;
                sw : mem_byte_enable = 4'b1111;
            endcase
        end

        s_st2: begin
            loadPC(pcmux::pc_plus4);
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
                 rv32i_types::op_lui: next_state = s_lui;
                 rv32i_types::op_auipc: next_state = s_auipc;
                 rv32i_types::op_jal: ;
                 rv32i_types::op_jalr: ;
                 rv32i_types::op_br: next_state = s_br;
                 rv32i_types::op_load: next_state = s_calc_addr;
                 rv32i_types::op_store: next_state = s_calc_addr;
                 rv32i_types::op_imm: next_state = s_imm;
                 rv32i_types::op_reg: next_state = s_imm;
                 rv32i_types::op_csr: ;
             endcase
        s_imm:
            next_state = s_fetch1;
        s_lui:
            next_state = s_fetch1;
        s_calc_addr: 
            if(opcode == rv32i_types::op_load)
                next_state = s_ld1;
            else // Store
                next_state = s_st1;
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
