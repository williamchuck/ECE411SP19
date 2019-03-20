module blocking_unit (
    input logic clk,
    input logic select,
    input logic resp,
    input logic [31:0] pc,
    output logic permit
);

logic _resp, _select;
logic [31:0] _pc;

initial begin
    _pc = 32'd0;
    _select = 1'b0;
    _resp = 1'b0;
end

always_ff @( posedge clk ) begin
    _pc <= pc;
    _select <= select;
    _resp <= resp;
end

always_comb begin
    if (pc != _pc) begin
        permit = 1'b1;
    end else if (_select & ~_resp) begin
        permit = 1'b1;
    end else begin
        permit = 1'b0;
    end
end

endmodule