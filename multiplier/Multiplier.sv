module Multiplier
(
    input logic Clk,
    input logic Run,
    input logic [31:0] mulA, mulB,
    output logic [31:0] Aval, Bval, 
    output logic X,
    output logic ready
 );
logic control_load, control_shift, control_subtract, control_clearALoadB; //control unit outputs during each state
logic A_LSB, B_LSB;
logic [31:0] Sum;

Control control_unit
(
    .Clk,
    .Execute(Run),
    .m(B_LSB),
    //based on the above inputs, the control calculates the following for each state:
    .Load(control_load),
    .Shift(control_shift),
    .Subtract(control_subtract),
    .clearAloadB(control_clearALoadB),
    .ready
);

RegM_32 registerA
(
    .Clk(Clk),
    .Reset(control_clearALoadB | init), //rgister A is 0'd when Reset is pressed or ClearA_LoadB is pressed
    .Load(control_load), //register A loads when the output of the control unit (control load) is high 
    .D(Sum),
    .Shift_In(X), //registers A and B shift when the control unit tells them to, during the appropriate state
    .Shift_En(control_shift),
    //below are the outputs
    .Data_Out(Aval),
    .Shift_Out(A_LSB)
);

RegM_32 registerB
(
    .Clk(Clk),
    .Reset(init),
    .Load(control_clearALoadB), //register B only loads from switches when ClearA_LoadB is high 
    .D(mulB),
    .Shift_In(A_LSB), //digit in the LSB of A
    .Shift_En(control_shift),
    //below are the outputs
    .Data_Out(Bval),
    .Shift_Out(B_LSB)
);

Adder33bit adder
(
    .Clk,
    .Switches(mulA),
    .A(Aval),
    .sub(control_subtract), //control_subtract is high when its the last shift and the multiplicand is <0 
    .outputEnable(B_LSB), //when the LSB of B is zero, we should not add
    .x(X),
    .S(Sum)
);

//
endmodule 
