`define INSN 0
`define DATA 1

module cache_arbiter #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask
)
(
    input logic clk,
    input logic l2_icache_request_ongoing,
    input logic l2_dcache_request_ongoing,
    input logic imem_read,
    input logic dmem_read,
    input logic dmem_write,
    output logic icache_read,
    output logic dcache_read,
    output logic dcache_write,

    input logic l2_icache_read,
    input logic l2_icache_write,
    input logic imem_stall,
    input logic [31:0] l2_icache_address,
    input logic [s_line-1:0] l2_icache_wdata,
    output logic l2_icache_resp,
    output logic [s_line-1:0] l2_icache_rdata,
    output logic l2_icache_ready,

    input logic l2_dcache_read,
    input logic l2_dcache_write,
    input logic dmem_stall,
    input logic [31:0] l2_dcache_address,
    input logic [s_line-1:0] l2_dcache_wdata,
    output logic l2_dcache_resp,
    output logic [s_line-1:0] l2_dcache_rdata,
    output logic l2_dcache_ready,

    input logic l2_ready,
    output logic l2_stall,
    input logic l2_resp,
    input logic [s_line-1:0] l2_rdata,
    output logic l2_read,
    output logic l2_write,
    output logic [31:0] l2_address,
    output logic [s_line-1:0] l2_wdata
);

// logic [s_line-1:0] rdata_buffer_out;
// logic pending_resp, next_pending_resp;
logic icache_enable, dcache_enable;

enum integer { IDLE, ICACHE, DCACHE } downward_state, next_downward_state, upward_state;

assign icache_read = icache_enable & imem_read;
assign dcache_read = dcache_enable & dmem_read;
assign dcache_write = dcache_enable & dmem_write;

initial begin
    downward_state = IDLE;
    // pending_resp = 1'b0;
end

always_comb begin
    l2_read = 1'b0;
    l2_write = 1'b0;
    l2_address = 32'b0;
    l2_wdata = {s_line{1'bX}};
    l2_icache_rdata = {s_line{1'bX}};
    l2_dcache_rdata = {s_line{1'bX}};
    l2_icache_resp = 1'b0;
    l2_dcache_resp = 1'b0;
    l2_icache_ready = 1'd0;
    l2_dcache_ready = 1'd0;
    l2_stall = 1'd0;
    // next_pending_resp = 1'b0;
    icache_enable = 1'b1;
    dcache_enable = 1'b1;

    case(downward_state)
        IDLE: ;

        ICACHE: begin
            l2_read = l2_icache_read;
            l2_write = l2_icache_write;
            l2_address = l2_icache_address;
            l2_wdata = l2_icache_wdata;
            l2_stall = imem_stall;
        end

        DCACHE: begin
            l2_read = l2_dcache_read;
            l2_write = l2_dcache_write;
            l2_address = l2_dcache_address;
            l2_wdata = l2_dcache_wdata;
            l2_stall = dmem_stall;
        end
    endcase

    case(upward_state)
        IDLE: ;

        ICACHE: begin

            l2_icache_rdata = l2_rdata;
            if (l2_resp) begin
                l2_icache_resp = 1'b1;
                l2_icache_ready = l2_ready;
            end

            // if (l2_resp) begin
            //     if (pending_resp) begin
            //         l2_icache_resp = 1'b1;
            //         l2_icache_ready = l2_ready;
            //         l2_dcache_resp = 1'b1;
            //         l2_dcache_rdata = rdata_buffer_out;
            //         next_pending_resp = 1'b0;
            //     end else if (~l2_dcache_request_ongoing) begin
            //         l2_icache_resp = 1'b1;
            //         l2_icache_ready = l2_ready;
            //     end else begin
            //         next_pending_resp = 1'b1;
            //     end
            // end
        end

        DCACHE: begin
            l2_dcache_rdata = l2_rdata;
            if (l2_resp) begin
                l2_dcache_resp = 1'b1;
                l2_dcache_ready = l2_ready;
            end

            // if (l2_resp) begin
            //     if (pending_resp) begin
            //         l2_dcache_resp = 1'b1;
            //         l2_dcache_ready = l2_ready;
            //         l2_icache_resp = 1'b1;
            //         l2_icache_rdata = rdata_buffer_out;
            //         next_pending_resp = 1'b0;
            //     end else if (~l2_icache_request_ongoing) begin
            //         l2_dcache_resp = 1'b1;
            //         l2_dcache_ready = l2_ready;
            //     end else begin
            //         next_pending_resp = 1'b1;
            //     end
            // end
        end
    endcase
end

always_comb begin
    next_downward_state = downward_state;
    case(downward_state)
        IDLE:
            if (l2_icache_request_ongoing)
                next_downward_state = ICACHE;
            else if (l2_dcache_request_ongoing)
                next_downward_state = DCACHE;

        ICACHE:
            if (l2_resp & ~l2_dcache_request_ongoing)
                next_downward_state = IDLE;
            else if (l2_resp)
                next_downward_state = DCACHE;

        DCACHE:
            if (l2_resp & ~l2_icache_request_ongoing)
                next_downward_state = IDLE;
            else if (l2_resp)
                next_downward_state = ICACHE;
    endcase
end

always_ff @( posedge clk ) begin
    downward_state <= next_downward_state;
    upward_state <= downward_state;
    // if (l2_resp) begin
    //     rdata_buffer_out <= l2_rdata;
    // end
end

endmodule
