module datapath
import rv32i_types::*;
(
    input clk,
    input rst,
    // The following input from Control
    input load_pc,
    input load_ir,
    input load_regfile,
    input load_mar,
    input load_mdr,
    input load_data_out,
    input pcmux::pcmux_sel_t pcmux_sel,
    input alumux::alumux1_sel_t alumux1_sel,
    input alumux::alumux2_sel_t alumux2_sel,
    input regfilemux::regfilemux_sel_t regfilemux_sel,
    input marmux::marmux_sel_t marmux_sel,
    input cmpmux::cmpmux_sel_t cmpmux_sel,
    input alu_ops aluop,
    input branch_funct3_t cmp_op,

    input rv32i_word mem_rdata,
    output rv32i_word mem_wdata, // signal used by RVFI Monitor
    output rv32i_word mem_address,
    // IR signals to control
    output [2:0] funct3,
    output [6:0] funct7,
    output rv32i_opcode opcode,
    output br_en,
    output [31:0] i_imm,
    output [31:0] s_imm,
    output [31:0] b_imm,
    output [31:0] u_imm,
    output [31:0] j_imm,
    output [4:0] rs1,
    output [4:0] rs2,   // Index of register
    output [4:0] rd,

    output [1:0] mar_lower // Lowr two bits of mar
    /* You will need to connect more signals to your datapath module*/
);

/******************* Signals Needed for RVFI Monitor *************************/
rv32i_word pcmux_out;
rv32i_word mdrreg_out;
/*****************************************************************************/
rv32i_word marmux_out;
rv32i_word alumux1_out;
rv32i_word alumux2_out;
rv32i_word alu_out;
rv32i_word cmpmux_out;
rv32i_word regfilemux_out;
rv32i_word rs1_out;         // Content of registers
rv32i_word rs2_out;
rv32i_word mem_data_out;

assign mem_wdata = mem_data_out;

/***************************** Registers *************************************/
// Keep Instruction register named `IR` for RVFI Monitor
ir IR(
    .load(load_ir),
    .in(mdrreg_out),
    .*
    //Fill in the wires
);

logic [31:0] mdr;
logic [31:0] mar_out;
logic [31:0] pc_out;

always_ff @( posedge clk ) begin : mdr_ff
    if (rst) begin
        mdr <= '0;
    end else if (load_mdr) begin
        mdr <= mem_rdata;
    end
end : mdr_ff
assign mdrreg_out = mdr;

always_ff @( posedge clk ) begin : mar_ff
    if (rst) begin
        mar_out <= '0;
    end else if (load_mar) begin
        mar_out <= marmux_out;
    end
end : mar_ff

// Alignment, for example align 0x1003 to 0x1000 
assign mem_address = {mar_out[31:2], 2'b0};
assign mar_lower = mar_out[1:0];

always_ff @( posedge clk ) begin : pc_ff
    if (rst) begin
        pc_out <= 32'h40000000;
    end else if (load_pc) begin
        pc_out <= pcmux_out;
    end
end : pc_ff

always_ff @( posedge clk ) begin :  data_out_ff
    if (rst) begin
        mem_data_out <= '0;
    end else if (load_data_out) begin
        mem_data_out <= (rs2_out << (mar_lower * 8));
    end
end : data_out_ff

regfile RegFile(
    .*,
    .load(load_regfile),
    .in(regfilemux_out),
    .src_a(rs1),
    .src_b(rs2),
    .dest(rd),
    .reg_a(rs1_out),
    .reg_b(rs2_out)
);

/*****************************************************************************/

/******************************* ALU and CMP *********************************/
alu ALU(
    .aluop(aluop),
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

cmp CMP(
    .cmp_op(cmp_op),
    .a(rs1_out),
    .b(cmpmux_out),
    .br_en(br_en)
);


/*****************************************************************************/

/******************************** Muxes **************************************/
always_comb begin : MUXES
    // We provide one (incomplete) example of a mux instantiated using
    // a case statement.  Using enumerated types rather than bit vectors
    // provides compile time type safety.  Defensive programming is extremely
    // useful in SystemVerilog. 
    unique case (pcmux_sel)
        pcmux::pc_plus4: pcmux_out = pc_out + 4;
        pcmux::alu_out: pcmux_out = alu_out;
        pcmux::alu_mod2: pcmux_out = {alu_out[31:1],1'b0};
        // etc.
    endcase

    unique case (marmux_sel)
        marmux::pc_out: marmux_out = pc_out;
        marmux::alu_out: marmux_out = alu_out;
    endcase

    unique case (cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = rs2_out;
        cmpmux::i_imm: cmpmux_out = i_imm;
    endcase

    unique case (alumux1_sel)
        alumux::rs1_out : alumux1_out = rs1_out;
        alumux::pc_out : alumux1_out = pc_out;
    endcase

    unique case (alumux2_sel)
        alumux::i_imm : alumux2_out = i_imm;
        alumux::u_imm : alumux2_out = u_imm;
        alumux::b_imm : alumux2_out = b_imm;
        alumux::s_imm : alumux2_out = s_imm;
        alumux::j_imm : alumux2_out = j_imm;
        alumux::rs2_out : alumux2_out = rs2_out;
    endcase

    unique case (regfilemux_sel)
        regfilemux::alu_out : regfilemux_out = alu_out;
        regfilemux::br_en : regfilemux_out = {31'b0, br_en};
        regfilemux::u_imm : regfilemux_out = u_imm;
        regfilemux::lw : regfilemux_out = mdrreg_out;
        regfilemux::pc_plus4 : regfilemux_out = pc_out + 4;
        regfilemux::lb :  regfilemux_out = {{24{mdrreg_out[8 * mar_lower + 7]}}, mdrreg_out[8 * mar_lower +: 8]};
        regfilemux::lbu :  regfilemux_out = {24'b0, mdrreg_out[8 * mar_lower +: 8]};
        regfilemux::lh : regfilemux_out = {{16{mdrreg_out[mar_lower[1] * 16 + 15]}}, mdrreg_out[mar_lower[1] * 16 +: 16]};
        regfilemux::lhu : regfilemux_out = {16'b0, mdrreg_out[mar_lower[1] * 16 +: 16]};
    endcase
end
/*****************************************************************************/
endmodule : datapath
