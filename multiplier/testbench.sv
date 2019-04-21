module testbench();

timeunit 1ns;
timeprecision 1ns;

logic Clk, Run, X, ready;
logic [32:0] opA;
logic [32:0] opB;
logic [32:0] Aval;
logic [32:0] Bval;
logic div;
Multiplier mul(.*);

// logic [65:0] ans;
// assign ans = {Aval, Bval};

always begin : CLOCK_GENERATION
#5 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: TEST_VECTORS
Run = 0;
div = 0;
opA = 12;
opB = 4;

#10
Run = 1;
end
endmodule
