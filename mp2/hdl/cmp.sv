
module cmp
import rv32i_types::*;
(
    input branch_funct3_t cmp_op,
    input [31:0] a, b, // A points to rs1_out, B points to mux
    output logic br_en
);

always_comb 
begin
    unique case (cmp_op)
        beq : br_en = (a == b);
        bne : br_en = (a != b);
        blt : br_en = ($signed(a) < $signed(b));
        bge : br_en = ($signed(a) >= $signed(b));
        bltu : br_en = (a < b);
        bgeu : br_en = (a >= b);
    endcase;
end

endmodule : cmp

