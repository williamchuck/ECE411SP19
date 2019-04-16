import rv32i_types::*;

module cache_control (
    input clk,

    // Control-Datapath interface
    input hit,
    input valid,
    input dirty,
    output logic cache_read,
    output logic cache_load_en,
    output logic downstream_address_sel,
    output logic ld_wb,
    output logic ld_LRU,
    output logic new_dirty,

    // Cache-CPU interface
    input logic upstream_read,
    input logic upstream_write,
    output logic upstream_resp,

    // Cache-Memory interface
    input logic downstream_resp,
    output logic downstream_read,
    output logic downstream_write
);

logic wb_required;
assign wb_required = ~hit & dirty;

enum int unsigned { 
    IDLE, ACTION, WRITEBACK
} state, next_state;

always_comb begin : state_based_action
    cache_read = 0;
    cache_load_en = 0;
    downstream_address_sel = 0;
    ld_wb = 0;
    ld_LRU = 0;
    new_dirty = 0;

    upstream_resp = 0;
    downstream_read = 0;
    downstream_write = 0;

    case(state)

        IDLE: begin
            cache_read = 1'b1;
            // upstream_resp = (upstream_read | upstream_write) & hit;
        end

        ACTION: begin
            // downstream_read = ~(hit | downstream_resp);
            downstream_read = ~hit;
            new_dirty = upstream_write;
            if (hit | downstream_resp) begin
                // upstream_resp = ~wb_required;
                upstream_resp = 1'b1;
                cache_load_en = (~hit | upstream_write);
                ld_wb = 1'b1;
                ld_LRU = 1'b1;
                cache_read = hit | ~wb_required;
            end
        end

        WRITEBACK: begin
            // upstream_resp = downstream_resp;
            downstream_address_sel = 1'b1;
            downstream_write = 1'b1;
            cache_read = 1'b0;
        end
        
        default: ;
    endcase
end

always_comb begin : state_transition_logic
    next_state = state;
    case(state)
        IDLE: next_state = (upstream_read | upstream_write) ? ACTION : IDLE;
        ACTION: next_state = hit ? IDLE : (downstream_resp ? (wb_required ? WRITEBACK : IDLE) : ACTION);
        WRITEBACK: next_state = downstream_resp ? IDLE : WRITEBACK;
        default: ;
    endcase
end

always_ff @( posedge clk ) begin : state_update
    state <= next_state;
end

endmodule : cache_control
