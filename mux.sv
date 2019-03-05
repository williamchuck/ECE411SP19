module onehot_mux #(
    parameter s = 2,
    parameter width = 1
)
(
    input logic [2**s-1:0] sel,
    input logic [width-1:0] datain [2**s],
    output logic [width-1:0] dataout
);

always_comb begin
    dataout = {width{1'bX}};
    for(int i = 0; i < 2**s; i++) begin
        if(sel == (1 << i)) begin
            dataout = datain[i];
        end
    end
end
endmodule

module onehot_mux_1b #(
    parameter s = 2
)
(
    input logic [2**s-1:0] sel,
    input logic [2**s-1:0] datain,
    output logic dataout
);

always_comb begin
    dataout = 1'bX;
    for(int i = 0; i < 2**s; i++) begin
        if(sel == (1 << i)) begin
            dataout = datain[i];
        end
    end
end
endmodule
