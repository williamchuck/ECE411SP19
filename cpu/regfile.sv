
module regfile
(
    input clk,
    input load,
    input [31:0] in,
    input [4:0] rs1, rs2, rd,
    output logic [31:0] rs1_out, rs2_out
);

logic [31:0] data [32] /* synthesis ramstyle = "logic" */;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 32'b0;
    end
end

always_ff @(posedge clk)
begin
    if (load && rd)
    begin
        data[rd] = in;
    end
end

always_comb
begin
    rs1_out = rs1 ? data[rs1] : 0;
    rs2_out = rs2 ? data[rs2] : 0;
end

endmodule : regfile
