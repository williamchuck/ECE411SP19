module cache_core_pipelined #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter s_way    = 2,
    parameter num_ways = 2**s_way
)
(
    // TODO: 1. Dual port
    // TODO: 2. Forwarding ACT->IDX
    input clk,
    input stall,

    // Upstream interface
    input logic upstream_read,
    input logic upstream_write,
    input logic [31:0] upstream_address,
    input logic [s_line-1:0] upstream_wdata,
    output logic upstream_resp,
    output logic upstream_ready,
    output logic [s_line-1:0] upstream_rdata,

    // Downstream interface
    input downstream_resp,
    input [s_line-1:0] downstream_rdata,
    output logic downstream_read,
    output logic downstream_write,
    output logic [s_line-1:0] downstream_wdata,
    output logic [31:0] downstream_address
);

/// MARK: - Logics for INDEX stage
logic [s_index-1:0] index_IDX;
logic read, load_cache, pipe;
logic request_IDX;

assign index_IDX = upstream_address[s_offset+s_index-1:s_offset];
assign request_IDX = upstream_read | upstream_write;

/// MARK: - Logics for ACTION stage
logic [s_index-1:0] index_WB;
logic [31:0] address_ACT;
logic [s_tag-1:0] tag_ACT;
logic [s_index-1:0] index_ACT;
logic [num_ways-1:0] way;
logic [num_ways-1:0] equals, dirtys, valids, hits;
logic [s_tag-1:0] tags [num_ways];
logic [s_tag-1:0] tagwb_ACT;
logic [s_line-1:0] datas [num_ways];
logic [s_line-1:0] line_out, line_in;
logic [num_ways-2:0] lru, new_lru;
logic downstream_resp_ACT, hit, dirty, new_dirty;
logic request_ACT, write_ACT, do_wb_ACT, read_ACT;

assign tag_ACT = address_ACT[31:s_offset+s_index];
assign index_ACT = address_ACT[s_offset+s_index-1:s_offset];

// `read` indicates exactly when the pipeline moves
assign upstream_ready = downstream_resp_ACT | hit;
assign pipe = upstream_resp & ~stall;

// `load` when pipeline moves, but only if write is required
assign load_cache = upstream_ready & (~hit | write_ACT) & ~stall;

/// MARK: - Logics for WB stage
logic [s_tag-1:0] tagwb_WB;
logic [s_line-1:0] line_out_WB;
logic do_wb;

/// MARK: - INDEX stage

array #(.s_index(s_index), .width(num_ways-1)) lru_store
(
    .clk,
    .rindex(index_IDX),
    .windex(index_ACT),
    .read(pipe),
    .load(1'd1),
    .datain(new_lru),
    .dataout(lru)
);

genvar i;

generate begin: arrays

for (i = 0; i < num_ways; i++) begin : forloop
    array valid_array
    (
        .clk,
        .rindex(index_IDX),
        .windex(index_ACT),
        .read(pipe),
        .load(load_cache & way[i]),
        .datain(1'b1),
        .dataout(valids[i])
    );

    array dirty_array
    (
        .clk,
        .rindex(index_IDX),
        .windex(index_ACT),
        .read(pipe),
        .load(load_cache & way[i]),
        .datain(new_dirty),
        .dataout(dirtys[i])
    );

    array #(.s_index(s_index), .width(s_tag)) tag_array
    (
        .clk,
        .rindex(index_IDX),
        .windex(index_ACT),
        .read(pipe),
        .load(load_cache & way[i]),
        .datain(tag_ACT),
        .dataout(tags[i])
    );

    data_array line
    (
        .clk,
        .read(pipe),
        .write_en({s_mask{load_cache & way[i]}}),
        .rindex(index_IDX),
        .windex(index_ACT),
        .datain(line_in),
        .dataout(datas[i])
    );
    assign equals[i] = tags[i] == tag_ACT;
    assign hits[i] = equals[i] & valids[i];
end

end
endgenerate

/// MARK: - ACTION stage

assign hit = hits != {num_ways{1'b0}};
assign line_in = hit ? upstream_wdata : downstream_rdata;
assign do_wb_ACT = ~hit & dirty & downstream_resp_ACT;
assign new_dirty = write_ACT;

logic dirtymux_out;
onehot_mux_1b #(s_way) dirtymux
(
    .sel(way),
    .datain(dirtys),
    .dataout(dirtymux_out)
);
assign dirty = dirtymux_out;

logic [255:0] linemux_out;
onehot_mux #(s_way, s_line) linemux
(
    .sel(way),
    .datain(datas),
    .dataout(linemux_out)
);
assign line_out = linemux_out;

// Tag for the selected cache line; used for write-back
logic [23:0] tagmux_out;
onehot_mux #(s_way, s_tag) tagmux
(
    .sel(way),
    .datain(tags),
    .dataout(tagmux_out)
);
assign tagwb_ACT = tagmux_out;

lru_manager #(s_way) LRU_manager
(
    .lru,
    .hits,
    .way,
    .new_lru
);

/// MARK: - INDEX/ACTION pipeline register

register #(1) IDX_ACT_request
(
    .clk,
    .load(pipe),
    .in(request_IDX),
    .out(request_ACT)
);

register #(1) IDX_ACT_read
(
    .clk,
    .load(pipe),
    .in(upstream_read),
    .out(read_ACT)
);

register IDX_ACT_address
(
    .clk,
    .load(pipe),
    .in(upstream_address),
    .out(address_ACT)
);

register #(1) IDX_ACT_write
(
    .clk,
    .load(pipe),
    .in(upstream_write),
    .out(write_ACT)
);

/// MARK: - ACTION/WB pipeline register

register #(s_index) ACT_WB_index
(
    .clk,
    .load(pipe & ~hit),
    .in(index_ACT),
    .out(index_WB)
);

register #(s_tag) ACT_WB_tagwb
(
    .clk,
    .load(pipe & ~hit),
    .in(tagwb_ACT),
    .out(tagwb_WB)
);

register #(s_line) ACT_WB_data
(
    .clk,
    .load(pipe & ~hit),
    .in(line_out),
    .out(line_out_WB)
);

register #(1) ACT_WB_do_wb
(
    .clk,
    .load(pipe & ~hit),
    .in(do_wb_ACT),
    .out(do_wb)
);

/// MARK: - downstream interface

assign downstream_address =
    do_wb ? {tagwb_WB, index_WB, {s_offset{1'b0}}} : address_ACT;
assign downstream_read = ~hit & ~do_wb & (read_ACT | write_ACT);
assign downstream_write = do_wb;
assign downstream_wdata = line_out_WB;
assign downstream_resp_ACT = downstream_resp & ~do_wb;

assign upstream_resp = upstream_ready | !request_ACT;
assign upstream_rdata = downstream_resp_ACT ? downstream_rdata : line_out;

endmodule