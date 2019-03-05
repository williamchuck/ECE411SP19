module mux2 #(parameter width = 32)
(
    input sel,
    input [width-1:0] a, b,
    output logic [width-1:0] f
);

always_comb begin
    if (sel == 0)
        f = a;
    else
        f = b;
end

endmodule : mux2

module mux4 #(parameter width = 32)
(
    input logic [1:0] sel,
    input logic [width-1:0] a, b, c, d,
    output logic [width-1:0] f
);

always_comb begin
    if (sel == 2'b00)
        f = a;
    else if (sel == 2'b01)
        f = b;
    else if (sel == 2'b10)
        f = c;
    else
        f = d;
end

endmodule : mux4

module mux8 #(parameter width = 32)
(
    input logic [2:0] sel,
    input logic [width-1:0] a0,a1,a2,a3,a4,a5,a6,a7,
    output logic [width-1:0] f
);

always_comb begin
    if (sel == 3'b000)
        f = a0;
    else if (sel == 3'b001)
        f = a1;
    else if (sel == 3'b010)
        f = a2;
    else if (sel == 3'b011)
        f = a3;
    else if (sel == 3'b100)
        f = a4;
    else if (sel == 3'b101)
        f = a5;
    else if (sel == 3'b110)
        f = a6;
    else
        f = a7;
end

endmodule : mux8
