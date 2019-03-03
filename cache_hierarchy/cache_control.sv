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

assign wb_required = ~hit & dirty;

enum int unsigned { 
    IDLE, ACTION, PACTION, WRITEBACK
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
        IDLE: cache_read = upstream_read | upstream_write;

        ACTION: begin
            downstream_read = ~(hit | downstream_resp);
            new_dirty = upstream_write;
            if (hit | downstream_resp) begin
                upstream_resp = hit;
                cache_load_en = (~hit | upstream_write);
                ld_wb = 1;
                ld_LRU = 1;
            end
        end

        PACTION: ;

        WRITEBACK: begin
            upstream_resp = ~wb_required | (wb_required & downstream_resp);
            downstream_address_sel = 1;
            downstream_write = wb_required & ~downstream_resp;
        end
        
        default: ;
    endcase
end

always_comb begin : state_transition_logic
    next_state = state;
    case(state)
        IDLE: next_state = (upstream_read | upstream_write) ? ACTION : IDLE;
        ACTION: next_state = hit ? IDLE : (downstream_resp ? PACTION : ACTION);
        PACTION: next_state = WRITEBACK;
        WRITEBACK: next_state = upstream_resp ? IDLE : WRITEBACK;
        default: ;
    endcase
end

always_ff @( posedge clk ) begin : state_update
    state <= next_state;
end

endmodule : cache_control
