module ir_manager (
    input logic clk,
    input logic j,
    input logic [31:0] pc
    input logic [31:0] imem_rdata,
    output logic [31:0] ir_in,
    output logic ir_stall
);

logic [15:0] half_instr, _half_instr, low_full_instr, _low_full_instr;
logic with_half, _with_half, with_low_full, _with_low_full;
logic load_low_full, load_half;

register #(33) low_full_reg
(
    .clk,
    .load(load_low_full),
    .in({_with_low_full, _low_full_instr}),
    .out({with_low_full, low_full_instr})
);

register #(33) half_reg
(
    .clk,
    .load(load_half),
    .in({_with_half, _half_instr}),
    .out({with_half, half_instr})
);

always_comb begin
    // Default buffer update values
    load_low_full = 1'b0;
    load_half = 1'b0;
    _with_half = 1'b0;
    _with_low_full = 1'b0;

    if ((j & ~pc[1]) | (~with_half & ~with_low_full)) begin
        irl_sel = irl_rdata_low;
        if (imem_rdata[1:0] == 2'b11) begin
            ir_stall = 1'b0;
            irh_sel = irh_rdata_high;
        end else if (imem_rdata[17:16] == 2'b11) begin
            ir_stall = 1'b0;
            irh_sel = irh_one;
            load_low_full = 1'b1;
            _with_low_full = 1'b1;
        end else begin
            ir_stall = 1'b1;
            irh_sel = irh_one;
        end
    end else if (j & pc[1]) begin // jumped to half-word address
        ir_stall = 1'b0;
        irh_sel = irh_one;
        if (imem_rdata[17:16] == 2'b11) begin
            irl_sel = irl_one;
            load_low_full = 1'b1;
            _with_low_full = 1'b1;
        end else begin
            irl_sel = irl_rdata_low;
        end
    end else if (with_half) begin
        ir_stall = 1'b0;
        irh_sel = irh_one;
        irl_sel = irl_half;
        load_half = 1'b1;
        _with_half = 1'b0;
    end else if (with_low_full) begin
        irh_sel = irh_rdata_low;
        irl_sel = irl_low_full;
        load_low_full = 1'b1;
        load_half = 1'b1;
        if (imem_rdata[17:16] == 2'b11) begin
            ir_stall = 1'b0;
            _with_low_full = 1'b1;
            _with_half = 1'b0;
        end else begin
            ir_stall = 1'b1;
            _with_low_full = 1'b0;
            _with_half = 1'b1;
        end
    end
end

endmodule