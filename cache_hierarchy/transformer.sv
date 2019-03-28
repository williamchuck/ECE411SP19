module input_transformer #(
    parameter s_offset = 5,
    parameter s_mask = 2**s_offset,
    parameter s_line = 8*s_mask
)
(
    input [s_line-1:0] line_data,
    input [31:0] word_data,
    input enable,
    input [s_offset-1:0] offset,
    input [3:0] wmask,
    output [s_line-1:0] dataout
);

logic [31:0] word_mask;
logic [s_line-1:0] line_mask, line_mask_n;
logic [s_line-1:0] _dataout;
assign word_mask = {{8{wmask[3]}}, {8{wmask[2]}}, {8{wmask[1]}}, {8{wmask[0]}}};
assign line_mask = {{(s_line-32){1'b0}}, word_mask} << (offset*8);
assign line_mask_n = ~line_mask;
assign _dataout = (line_mask & {8{word_data}}) | (line_mask_n & line_data);
assign dataout = enable ? _dataout : line_data;

endmodule : input_transformer

module output_transformer #(
    parameter s_offset = 5,
    parameter s_mask = 2**s_offset,
    parameter s_line = 8*s_mask
)
(
    input [s_line-1:0] line_data,
    input [s_offset-1:0] offset,
    output [31:0] dataout
);

assign dataout = line_data[(8*offset) +: 32];

endmodule : output_transformer