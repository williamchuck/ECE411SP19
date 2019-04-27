module Multiplier
(
    input logic Clk,
    input logic Run,
    input logic [32:0] opA, opB,
    input logic div,
    input logic stall,
    output logic [32:0] Aval, Bval, 
    output logic resp,
    output logic ready
 );
logic control_load, control_shift, control_subtract, control_clearALoadB;
logic X;
logic A_R_out, B_R_out, A_L_out, B_L_out;
logic flipsign;
logic [32:0] Sum;
logic [32:0] opA_Abs;
logic [32:0] opB_Abs;

logic _run;
logic [32:0] _opA;
logic [32:0] _opB;


logic [32:0] buffered_opA;
logic [32:0] buffered_opB;

initial begin
    _run = 1'd0;
end

always_ff @(posedge Clk) begin
    _run <= Run;
end

register #(66) opA_buff
(
    .clk(Clk),
    .load(Run & ~_run),
    .in({opA, opB}),
    .out({buffered_opA, buffered_opB})
);

assign _opA = _run ? buffered_opA : opA;
assign _opB = _run ? buffered_opB : opB;

assign opA_Abs = opA[32] ? -_opA : _opA;
assign opB_Abs = opB[32] ? -_opB : _opB;

Control control_unit
(
    .Clk,
    .Execute(Run),
    .m(B_R_out),
    .div,
    .differentSigns(_opA[32] != _opB[32]),
    .stall,
    //based on the above inputs, the control calculates the following for each state:
    .Load(control_load),
    .Shift(control_shift),
    .Subtract(control_subtract),
    .clearAloadB(control_clearALoadB),
    .flipsign,
    .resp,
    .ready,

    ._opA, ._opB,
    .Aval, .Bval
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
    .Load(control_clearALoadB | (flipsign & (_opB != 0))), //register B only loads from switches when ClearA_LoadB is high 
    .D((flipsign & (_opB != 0)) ? -Bval : (div ? opA_Abs : _opB)),
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
    .Switches(div ? opB_Abs : _opA),
    .A(Aval),
    .sub(div | control_subtract), //control_subtract is high when its the last shift and the multiplicand is <0 
    .outputEnable(div | (~div & B_R_out)), //when the LSB of B is zero, we should not add
    .x(X),
    .S(Sum)
);

//
endmodule 
