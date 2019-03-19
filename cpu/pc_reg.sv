module pc_register #(parameter width = 32)
(
    input clk,
    input load,
    input [width-1:0] in,
    output logic [width-1:0] out,
    output logic fresh
);

logic [width-1:0] data;
logic _fresh;

/*
* PC needs to start at 0x60
 */
initial
begin
    data = 32'h00000060;
    _fresh = 1'b1;
end

always_ff @(posedge clk)
begin
    if (load) begin
        data <= in;
        _fresh <= 1'b1;
    end else begin
        _fresh <= 1'b0;
    end
end

always_comb
begin
    out = data;
    fresh = _fresh;
end

endmodule : pc_register
