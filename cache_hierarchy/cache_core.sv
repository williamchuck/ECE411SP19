module cache_core #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter s_way    = 2
)
(
    input clk,
    output hit,
    output valid,

    input upstream_read,
    input upstream_write,
    input [31:0] upstream_address,
    input [s_line-1:0] upstream_wdata,
    output logic [s_line-1:0] upstream_rdata,
    output logic upstream_resp,

    input downstream_resp,
    input logic [s_line-1:0] downstream_rdata,
    output logic [s_line-1:0] downstream_wdata,
    output logic [31:0] downstream_address,
    output logic downstream_read,
    output logic downstream_write
);

logic dirty, cache_read, cache_load_en;
logic downstream_address_sel, ld_wb, ld_LRU, new_dirty;

cache_datapath_core #(
    .s_offset(s_offset), .s_index(s_index), .s_way(s_way)) datapath
(
    .clk,

    // Datapath-Control interface
    .cache_read,
    .cache_load_en,
    .downstream_address_sel,
    .ld_wb,
    .ld_LRU,
    .new_dirty,
    .hit,
    .valid,
    .dirty,

    // Upstream interface
    .upstream_address,
    .upstream_wdata,
    .upstream_rdata,

    // Downstream interface
    .downstream_resp,
    .downstream_rdata,
    .downstream_wdata,
    .downstream_address
);

cache_control control
(
    .clk,

    // Control-Datapath interface
    .hit,
    .valid,
    .dirty,
    .cache_read,
    .cache_load_en,
    .downstream_address_sel,
    .ld_wb,
    .ld_LRU,
    .new_dirty,

    // Cache-CPU interface
    .upstream_read,
    .upstream_write,
    .upstream_resp,

    // Cache-Memory interface
    .downstream_resp,
    .downstream_read,
    .downstream_write
);
    
endmodule