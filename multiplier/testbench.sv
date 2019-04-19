module testbench();

timeunit 1ns;
timeprecision 1ns;

logic Clk, Run, X, ready;
logic [31:0] mulA;
logic [31:0] mulB;
logic [31:0] Aval;
logic [31:0] Bval;

Multiplier mul(.*);

logic [63:0] ans;
assign ans = {Aval, Bval};

always begin : CLOCK_GENERATION
#5 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: TEST_VECTORS
Run = 0;
mulA = -10;
mulB = 12;

#10
Run = 1;
end
endmodule
