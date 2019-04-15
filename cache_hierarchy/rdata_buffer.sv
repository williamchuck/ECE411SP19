module rdata_buffer (
    input logic clk,
    input logic resp,
    input logic busy,
    input logic [31:0] rdata,
    output logic [31:0] rdata_synchronized
);

assign synchronized_rdata = busy ? rdata : _rdata;

logic [31:0] _rdata;

initial begin
    _rdata = 32'd0;
end

always_ff @(posedge clk) begin
    if(resp) begin
        _rdata <= rdata;
    end
end

endmodule