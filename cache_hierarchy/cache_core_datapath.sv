module cache_datapath_core #(
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
    output logic [s_line-1:0] upstream_rdata,

    // Downstream interface
    input downstream_resp,
    input [s_line-1:0] downstream_rdata,
    output logic downstream_read,
    output logic downstream_write,
    output logic [s_line-1:0] downstream_wdata,
    output logic [31:0] downstream_address
);

logic cache_started;

/// MARK: - Logics for INDEX stage
logic [s_index-1:0] index_IDX;
logic read, load_cache;

assign index_IDX = upstream_address[s_offset+s_index-1:s_offset];

/// MARK: - Logics for ACTION stage
logic [num_ways-1:0] fw, _fw;
logic [31:0] address_ACT;
logic [s_tag-1:0] tag_ACT;
logic [s_index-1:0] index_ACT;
logic [num_ways-1:0] way;
logic dirty_fw, valid_fw;
logic [num_ways-1:0] equals, dirtys, valids, hits;
logic [s_tag-1:0] tags [num_ways];
logic [s_tag-1:0] tag_fw;
logic [s_tag-1:0] tagwb_ACT;
logic [s_line-1:0] datas [num_ways];
logic [s_line-1:0] data_fw;
logic [s_line-1:0] line_out, line_in;
logic [num_ways-2:0] lru, new_lru, lru_fw;
logic resp, downstream_resp_ACT, hit, dirty, new_dirty;

assign tag_ACT = address_ACT[31:s_offset+s_index];
assign index_ACT = address_ACT[s_offset+s_index-1:s_offset];

// `read` indicates exactly when the pipeline moves
assign resp = downstream_resp_ACT | hit;
assign pipe = (resp & ~stall) | ~cache_started;

// `load` when pipeline moves, but only if write is required
assign load_cache = resp & (~hit | write_ACT) & ~stall;

/// MARK: - Logics for WB stage
logic [s_tag-1:0] tagwb_WB;
logic [s_line-1:0] line_out_WB;
logic do_wb;

/// MARK: - INDEX stage

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
end

end
endgenerate

/// MARK: - ACTION stage

logic use_forward = (fw & way != 0);

always_comb begin
    for (int i = 0; i < num_ways; i++) begin
        if (fw[i]) begin
            equals[i] = tag_fw == tag_ACT;
            hits[i] = equals[i] & valid_fw;
        end else begin
            equals[i] = tags[i] == tag_ACT;
            hits[i] = equals[i] & valids[i];
        end
    end
end

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
assign dirty = use_forward ? dirty_fw : dirtymux_out;

logic linemux_out;
onehot_mux #(s_way, s_line) linemux
(
    .sel(way),
    .datain(datas),
    .dataout(linemux_out)
);
assign line_out = use_forward ? data_fw : linemux_out;

// Tag for the selected cache line; used for write-back
logic tagmux_out;
onehot_mux #(s_way, s_tag) tagmux
(
    .sel(way),
    .datain(tags),
    .dataout(tagmux_out)
);
assign tagwb_ACT = use_forward ? tag_fw : tagmux_out;

lru_manager #(s_way) LRU_manager
(
    .lru((fw != 0) ? lru_fw : lru),
    .hits,
    .way,
    .new_lru
);

/// MARK: - INDEX/ACTION pipeline register

register #(1) IDX_ACT_read
(
    .clk,
    .load(pipe),
    .in(upstream_read),
    .out(read_ACT),
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

assign upstream_resp = resp;
assign upstream_rdata = downstream_resp_ACT ? downstream_rdata : line_out;

/// MARK: - initialization signal

register #(1) init_bit
(
    .clk,
    .load(~cache_started),
    .in(upstream_read | upstream_write),
    .out(cache_started)
);

/// MARK: - forwarding

register #(1) fw_dirty_reg
(
    .clk,
    .load(pipe),
    .in(new_dirty),
    .out(dirty_fw)
);

register #(1) fw_valid_reg
(
    .clk,
    .load(pipe),
    .in(1'b1),
    .out(valid_fw)
);

register #(s_tag) fw_tag_reg
(
    .clk,
    .load(pipe),
    .in(tag_ACT),
    .out(tag_fw)
);

register #(s_line) fw_data_reg
(
    .clk,
    .load(pipe),
    .in(line_in),
    .out(data_fw)
);

register #(num_ways) fw_reg
(
    .clk,
    .load(pipe),
    .in(_fw),
    .out(fw)
);

always_comb begin
    if (index_IDX == index_ACT && load_cache) begin
        _fw = way;
    end else begin
        _fw = 0;
    end
end

endmodule