module testbench();

timeunit 1ns;
timeprecision 1ns;

logic Clk, Run, X, ready;
logic [32:0] mulA;
logic [32:0] mulB;
logic [32:0] Aval;
logic [32:0] Bval;

Multiplier mul(.*);

logic [65:0] ans;
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
mulB = -22;

#10
Run = 1;
end
endmodule
