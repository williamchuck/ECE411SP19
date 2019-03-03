module onehot_mux #(
    parameter s = 4,
    parameter width = 1
)
(
    input logic [s-1:0] sel,
    input logic [width-1:0] datain [s],
    output logic [width-1:0] dataout
);

always_comb begin
    dataout = {width{1'bX}};
    for(int i = 0; i < s; i++) begin
        if(sel == (1 << i)) begin
            dataout = datain[i];
        end
    end
endmodule

module mux2 (
    input logic sel,
    input logic a,
    input logic b,
    output logic f
);

assign f = sel ? b : a;

endmodule