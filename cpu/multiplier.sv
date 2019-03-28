module multiplier(
    input   logic [31:0] a,
    input   logic [31:0] b,
    output  logic [31:0] f
);

assign f = a * b;

endmodule