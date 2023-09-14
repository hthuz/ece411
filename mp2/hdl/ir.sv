
module ir
import rv32i_types::*;
(
    input clk,
    input rst,
    input load,
    input [31:0] in,        // Your instruction
    output [2:0] funct3,
    output [6:0] funct7,
    output rv32i_opcode opcode,
    output [31:0] i_imm,
    output [31:0] s_imm,
    output [31:0] b_imm,
    output [31:0] u_imm,
    output [31:0] j_imm,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd
);

logic [31:0] data;

assign funct3 = data[14:12];
assign funct7 = data[31:25];
assign opcode = rv32i_opcode'(data[6:0]);
assign i_imm = {{21{data[31]}}, data[30:20]};               // Sign extended to 32 bits
assign s_imm = {{21{data[31]}}, data[30:25], data[11:7]};   // Sign extended to 32 bits
assign b_imm = {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0}; // LSB is always 0
assign u_imm = {data[31:12], 12'h000}; // Shifted left by 12 bits
assign j_imm = {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0}; // Shifted left by 1 bit
assign rs1 = data[19:15];
assign rs2 = data[24:20];
assign rd = data[11:7];

//why "=" instead of "<="
always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= '0;
    end
    else if (load == 1)
    begin
        data <= in;
    end
    else
    begin
        data <= data;
    end
end

endmodule : ir
