module Multiplier
(
    input logic Clk,
    input logic Run,
    input logic [32:0] opA, opB,
    input logic div,
    output logic [32:0] Aval, Bval, 
    output logic X,
    output logic ready
 );
logic control_load, control_shift, control_subtract, control_clearALoadB; //control unit outputs during each state
logic A_LSB, B_LSB;
logic [32:0] Sum;
logic [32:0] divisor;
logic a_sign;
assign a_sign = Sum[32];
assign a_sign_N = ~a_sign;

Control control_unit
(
    .Clk,
    .Execute(Run),
    .m(B_LSB),
    .div,
    //based on the above inputs, the control calculates the following for each state:
    .Load(control_load),
    .Shift(control_shift),
    .Subtract(control_subtract),
    .clearAloadB(control_clearALoadB),
    .ready
);

RegM_33 registerA
(
    .Clk,
    .Reset(control_clearALoadB), //rgister A is 0'd when Reset is pressed or ClearA_LoadB is pressed
    .Load( (~div & control_load) | (div & a_sign_N & control_load)), //register A loads when the output of the control unit (control load) is high 
    .D(div ? opA: Sum),
    .ShiftR_In(div ? 1'd0 : X), //registers A and B shift when the control unit tells them to, during the appropriate state
    .ShiftR_En(control_shift),
    .ShiftL_In(1'd0),
    .ShiftL_En(1'd0),
    //below are the outputs
    .Data_Out(Aval),
    .Shift_Out(A_LSB)
);

RegM_33 registerB
(
    .Clk,
    .Reset(1'd0),
    .Load(control_clearALoadB), //register B only loads from switches when ClearA_LoadB is high 
    .D(div ? opA : opB),
    .ShiftR_In(A_LSB), //digit in the LSB of A
    .ShiftR_En(~div & control_shift),
    .ShiftL_In(a_sign_N),
    .ShiftL_En(div & control_shift),
    //below are the outputs
    .Data_Out(Bval),
    .Shift_Out(B_LSB)
);

Adder34bit adder
(
    .Clk,
    .Switches(div ? divisor : opA),
    .A(Aval),
    .sub(div | control_subtract), //control_subtract is high when its the last shift and the multiplicand is <0 
    .outputEnable(div | (~div & B_LSB)), //when the LSB of B is zero, we should not add
    .x(X),
    .S(Sum)
);

register #(33) divisor_reg
(
    .clk(Clk),
    .load(control_clearALoadB | control_load),
    .in(control_clearALoadB ? opB : divisor << 1),
    .out(divisor)
);

//
endmodule 
