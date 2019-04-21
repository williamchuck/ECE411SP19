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
logic A_R_out, B_R_out, A_L_out, B_L_out;
logic flipsign;
logic [32:0] Sum;
logic [32:0] opA_Abs;
logic [32:0] opB_Abs;

assign opA_Abs = opA[32] ? -opA : opA;
assign opB_Abs = opB[32] ? -opB : opB;

Control control_unit
(
    .Clk,
    .Execute(Run),
    .m(B_R_out),
    .div,
    .differentSigns(opA[32] != opB[32]),
    //based on the above inputs, the control calculates the following for each state:
    .Load(control_load),
    .Shift(control_shift),
    .Subtract(control_subtract),
    .clearAloadB(control_clearALoadB),
    .flipsign,
    .ready
);

RegM_33 registerA
(
    .Clk,
    .Reset(control_clearALoadB), //rgister A is 0'd when Reset is pressed or ClearA_LoadB is pressed
    .Load( (~div & control_load) | (div & ~Sum[32] & control_load) | flipsign), //register A loads when the output of the control unit (control load) is high 
    .D(flipsign ? -Aval : Sum),
    .ShiftR_In(X), //registers A and B shift when the control unit tells them to, during the appropriate state
    .ShiftR_En(~div & control_shift),
    .ShiftL_In(B_L_out),
    .ShiftL_En(div & control_shift),
    //below are the outputs
    .Data_Out(Aval),
    .ShiftR_Out(A_R_out),
    .ShiftL_Out(A_L_out)
);

RegM_33 registerB
(
    .Clk,
    .Reset(1'd0),
    .Load(control_clearALoadB | (flipsign & (opB != 0))), //register B only loads from switches when ClearA_LoadB is high 
    .D((flipsign & (opB != 0)) ? -Bval : (div ? opA_Abs : opB)),
    .ShiftR_In(A_R_out), //digit in the LSB of A
    .ShiftR_En(~div & control_shift),
    .ShiftL_In({Aval[31:0], Bval[32]} >= opB_Abs),
    .ShiftL_En(div & control_shift),
    //below are the outputs
    .Data_Out(Bval),
    .ShiftR_Out(B_R_out),
    .ShiftL_Out(B_L_out)
);

Adder34bit adder
(
    .Clk,
    .Switches(div ? opB_Abs : opA),
    .A(Aval),
    .sub(div | control_subtract), //control_subtract is high when its the last shift and the multiplicand is <0 
    .outputEnable(div | (~div & B_R_out)), //when the LSB of B is zero, we should not add
    .x(X),
    .S(Sum)
);

//
endmodule 
