import rv32i_types::*;

module ir_manager (
    input logic clk,
    input logic j,
    input logic ready,
    input logic [31:0] pc,
    input logic [31:0] imem_rdata,
    output logic [31:0] ir,
    output logic ir_stall
);

logic stall;
logic [15:0] half_instr, _half_instr, low_full_instr, _low_full_instr;
logic with_half, _with_half, with_low_full, _with_low_full;
logic load_low_full, load_half;

ir_high_sel_t irh_sel;
ir_low_sel_t irl_sel;

register #(17) low_full_reg
(
    .clk,
    .load(load_low_full & ready),
    .in({_with_low_full, _low_full_instr}),
    .out({with_low_full, low_full_instr})
);

register #(17) half_reg
(
    .clk,
    .load(load_half & ready),
    .in({_with_half, _half_instr}),
    .out({with_half, half_instr})
);

assign ir_stall = stall & ready;
assign _half_instr = imem_rdata[31:16];
assign _low_full_instr = imem_rdata[31:16];

always_comb begin
    case(irl_sel)
        irl_one: ir[15:0] = 16'hffff;
        irl_rdata_low: ir[15:0] = imem_rdata[15:0];
        irl_low_full: ir[15:0] = low_full_instr;
        irl_half: ir[15:0] = half_instr;
        default: ir[15:0] = 16'hffff;
    endcase

    case(irh_sel)
        irh_one: ir[31:16] = 16'hffff;
        irh_rdata_low: ir[31:16] = imem_rdata[15:0];
        irh_rdata_high: ir[31:16] = imem_rdata[31:16];
        default: ir[31:16] = 16'hffff;
    endcase
end

always_comb begin
    // Default buffer update values
    load_low_full = 1'b0;
    load_half = 1'b0;
    _with_half = 1'b0;
    _with_low_full = 1'b0;

    stall = 1'b0;
    irl_sel = irl_one;
    irh_sel = irh_one;

    if ((j & ~pc[1]) | (~with_half & ~with_low_full)) begin
        irl_sel = irl_rdata_low;
        if (imem_rdata[1:0] == 2'b11) begin
            stall = 1'b0;
            irh_sel = irh_rdata_high;
        end else if (imem_rdata[17:16] == 2'b11) begin
            stall = 1'b0;
            irh_sel = irh_one;
            load_low_full = 1'b1;
            _with_low_full = 1'b1;
        end else begin
            stall = 1'b1;
            load_half = 1'b1;
            _with_half = 1'b1;
            irh_sel = irh_one;
        end
    end else if (j & pc[1]) begin // jumped to half-word address
        stall = 1'b0;
        irh_sel = irh_one;
        if (imem_rdata[17:16] == 2'b11) begin
            irl_sel = irl_one;
            load_low_full = 1'b1;
            _with_low_full = 1'b1;
        end else begin
            irl_sel = irl_rdata_low;
        end
    end else if (with_half) begin
        stall = 1'b0;
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
            stall = 1'b0;
            _with_low_full = 1'b1;
            _with_half = 1'b0;
        end else begin
            stall = 1'b1;
            _with_low_full = 1'b0;
            _with_half = 1'b1;
        end
    end
end

endmodule