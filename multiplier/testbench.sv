module testbench();

timeunit 1ns;
timeprecision 1ns;

logic Clk, Run, X, ready;
logic [32:0] opA;
logic [32:0] opB;
logic [32:0] Aval;
logic [32:0] Bval;
logic [65:0] multAns;
assign multAns = {Aval, Bval};
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
Run = 1;
div = 0;
opA = 0;
opB = 500;

end
endmodule
