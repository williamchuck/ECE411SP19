module RegM_33 (
     input  logic Clk, Reset, Load,
     input  logic ShiftR_In, ShiftR_En,
     input  logic ShiftL_In, ShiftL_En,
     input  logic [32:0]  D,
     output logic ShiftR_Out,
     output logic ShiftL_Out,
     output logic [32:0]  Data_Out);

initial begin
    Data_Out = 33'd0;
end
              
always_ff @ (posedge Clk)
begin
     if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
          Data_Out <= 33'd0;
     else if (Load)
          Data_Out <= D;
     else if (ShiftR_En)
          Data_Out <= { ShiftR_In, Data_Out[32:1] };
     else if (ShiftL_En)
          Data_Out <= { Data_Out[31:0], ShiftL_In };
end
	
assign ShiftR_Out = Data_Out[0];
assign ShiftL_Out = Data_Out[32];

endmodule