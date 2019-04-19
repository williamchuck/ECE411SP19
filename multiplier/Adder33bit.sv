module Adder33bit
(
    input logic Clk,
	input logic [31:0] Switches, A,
	input logic sub, outputEnable,
	output logic [31:0] S,
	output logic x
);
logic [31:0] inA; //the thing that will be added with A to produce the value to be stored in A

logic _x;

logic [32:0] internalSum;
assign internalSum = A + inA;
//assign x = internalSum[32];
assign S = internalSum[31:0];

//four_bit_ra FRA0(.x (A[3:0]), .y (inA[3:0]), .cin (sub & outputEnable), .s (S[3:0]), .cout (internalCout[0]));
//four_bit_ra FRA1(.x (A[7:4]), .y (inA[7:4]), .cin (internalCout[0]), .s(S[7:4]), .cout (internalCout[1]));
//carry out unused
//full_adder FA2(.x (A[7]), .y (inA[7]), .cin(internalCout[1]), .s(x), .cout());

initial begin
    _x = 0;
end

always_ff @ (posedge Clk) begin
    _x <= x;
end

always_comb begin
    if(outputEnable == 1)
        begin
            inA = {32{sub}} ^ Switches;
            x = internalSum[32];
        end
    else
        begin
            inA = 32'd0;
            x = _x;
        end
end


endmodule