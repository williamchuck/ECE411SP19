import rv32i_types::*;

module ir_manager (
    input logic clk,
    input logic j,
    input logic ready,
    input logic hazard,
    input logic control_hazard_stall,
    input logic [31:0] pc,
    input logic [31:0] imem_rdata,
    output logic [31:0] true_pc,
    output logic [31:0] ir,
    output logic ir_stall
);

//Performance Metric Counter
logic [31:0] executed_ins_count;
logic addExecutedIns;

logic stall;
logic [15:0] half_instr, _half_instr, low_full_instr, _low_full_instr;
logic with_half, _with_half, with_low_full, _with_low_full;
logic [31:0] pc_;

ir_high_sel_t irh_sel;
ir_low_sel_t irl_sel;
true_pc_sel_t true_pc_sel;

register #(32) pc_buffer
(
    .clk,
    .load(ready & ~hazard),
    .in(pc),
    .out(pc_)
);

register #(17) low_full_reg
(
    .clk,
    .load(ready & ~hazard),
    .in({_with_low_full, _low_full_instr}),
    .out({with_low_full, low_full_instr})
);

register #(17) half_reg
(
    .clk,
    .load(ready & ~hazard),
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

    case(true_pc_sel)
        true_pc_0: true_pc = pc;
        true_pc_p2: true_pc = pc + 2;
        true_pc_m2: true_pc = pc - 2;
    endcase
end

always_comb begin
    //Performance Metric
    addExecutedIns = 1'd0;

    // Default buffer update values
    _with_half = 1'b0;
    _with_low_full = 1'b0;

    true_pc_sel = true_pc_0;
    stall = 1'b0;
    irl_sel = irl_one;
    irh_sel = irh_one;

    if (j & pc[1] & (pc != pc_)) begin // jumped to half-word address
        true_pc_sel = true_pc_0; // pc already misaligned here
        stall = 1'b0;
        irh_sel = irh_one;
        _with_half = 1'b0;
        if (imem_rdata[17:16] == 2'b11) begin
            irl_sel = irl_one;
            _with_low_full = 1'b1;
        end else begin

            addExecutedIns = 1'd1;

            irl_sel = irl_rdata_low;
            _with_low_full = 1'b0;
        end
    end else if ((j & ~pc[1] & (pc != pc_)) | (~with_half & ~with_low_full)) begin
        true_pc_sel = true_pc_0;
        irl_sel = irl_rdata_low;
        if (imem_rdata[1:0] == 2'b11) begin

            stall = 1'b0;
            irh_sel = irh_rdata_high;
            _with_low_full = 1'b0;
            _with_half = 1'b0;
        end else if (imem_rdata[17:16] == 2'b11) begin

            addExecutedIns = 1'd1;

            stall = 1'b0;
            irh_sel = irh_one;
            _with_low_full = 1'b1;
            _with_half = 1'b0;
        end else begin
            stall = 1'b1;
            _with_low_full = 1'b0;
            _with_half = 1'b1;
            irh_sel = irh_one;
        end
    end else if (with_half) begin

        addExecutedIns = 1'd1;

        true_pc_sel = true_pc_p2;
        stall = 1'b0;
        irh_sel = irh_one;
        irl_sel = irl_half;
        _with_half = 1'b0;
        _with_low_full = 1'b0;
    end else if (with_low_full) begin
        true_pc_sel = true_pc_m2;
        irh_sel = irh_rdata_low;
        irl_sel = irl_low_full;
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

register #(32) executed_ins_count_reg
(
    .clk,
    .load(ready & ~hazard & addExecutedIns & ~control_hazard_stall),
    .in(executed_ins_count + 1),
    .out(executed_ins_count)
);

endmodule