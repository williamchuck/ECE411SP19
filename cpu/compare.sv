import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module compare
(
    input branch_funct3_t cmpop,
    input rv32i_word arg1,
    input rv32i_word arg2,
    output logic br_en
);

always_comb
begin
    case(cmpop)
        beq: br_en = (arg1 == arg2);
            
        bne: br_en = (arg1 != arg2);
            
        blt: br_en = ($signed(arg1) < $signed(arg2));
            
        bge: br_en = ($signed(arg1) >= $signed(arg2));
            
        bltu: br_en = (arg1 < arg2);
            
        bgeu: br_en = (arg1 >= arg2);
        
        default:
            br_en = 1'b0;
    endcase
end
endmodule : compare

