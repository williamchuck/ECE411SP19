import rv32i_types::*;

module alu
(
    input logic clk,
    input alu_ops aluop,
    input muldiv,
    input alu_stall,
    input [31:0] a, b,
    output logic [31:0] f,
    output logic resp,
    output logic ready
);
logic d, muldiv_ready, muldiv_resp;
logic [32:0] opA, opB, Aval, Bval;
logic [31:0] muldiv_f, alu_f;
assign resp = muldiv ? muldiv_resp : 1'b1;
assign ready = muldiv ? muldiv_ready : 1'b1;
assign f = muldiv ? muldiv_f : alu_f;

always_comb begin
    case (aluop)
        alu_add:  alu_f = a + b;
        alu_sll:  alu_f = a << b[4:0];
        alu_sra:  alu_f = $signed(a) >>> b[4:0];
        alu_sub:  alu_f = a - b;
        alu_xor:  alu_f = a ^ b;
        alu_srl:  alu_f = a >> b[4:0];
        alu_or:   alu_f = a | b;
        alu_and:  alu_f = a & b;
    endcase
end

always_comb begin
    case (mul_ops'(aluop))
        mul, mulh: begin
            opA = {a[31], a};
            opB = {b[31], b};
            d = 1'b0;
        end
        mulhsu: begin
            opA = {a[31], a};
            opB = {1'b0, b};
            d = 1'b0;
        end
        mulhu: begin
            opA = {1'b0, a};
            opB = {1'b0, b};
            d = 1'b0;
        end
        div, rem: begin
            opA = {a[31], a};
            opB = {b[31], b};
            d = 1'b1;
        end
        divu, remu: begin
            opA = {1'b0, a};
            opB = {1'b0, b};
            d = 1'b1;
        end
        default: {opA, opB, d} = {33'dX, 33'dX, 1'dX};
    endcase
end

always_comb begin
    case(mul_ops'(aluop))
        mul: muldiv_f = Bval[31:0];
        mulh, mulhsu, mulhu: muldiv_f = {Aval[30:0], Bval[32]};
        div, divu: muldiv_f = Bval[31:0];
        rem, remu: muldiv_f = Aval[31:0];
    endcase
end

Multiplier multiplier
(
    .Clk(clk),
    .Run(muldiv),
    .stall(alu_stall),
    .opA,
    .opB,
    .div(d),
    .Aval,
    .Bval,
    .resp(muldiv_resp),
    .ready(muldiv_ready)
);

endmodule : alu

