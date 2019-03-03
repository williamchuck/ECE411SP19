module cache_datapath_core #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter num_ways = 4
)
(
    input clk,

    // Datapath-Control interface
    input logic cache_read,
    input logic cache_load_en,
    input logic inmux_sel,
    input logic downstream_address_sel,
    input logic ld_wb,
    input logic ld_LRU,
    input logic new_dirty,
    output logic hit,
    output logic valid,
    output logic dirty,

    // Upstream interface
    input logic [31:0] upstream_address,
    input logic [s_line-1:0] upstream_wdata,
    output logic [s_line-1:0] upstream_rdata,

    // Downstream interface
    input [s_line-1:0] downstream_rdata,
    output logic [s_line-1:0] downstream_wdata,
    output logic [31:0] downstream_address
);

// Address parsing
logic [s_tag-1:0] tag;
logic [s_index-1:0] index;
logic [s_offset-1:0] offset;

logic [num_ways-1:0] way;
logic [num_ways-2:0] lru, new_lru;
logic [num_ways-1:0] equals, dirtys, valids, hits;
logic [s_tag-1:0] tags [num_ways];
logic [s_tag-1:0] tagmux_out;
logic [s_line-1:0] data1, data0, hitmux_out, wbmux_out, inmux_out,
                   hit_data, miss_data;

assign tag = upstream_address[31:s_offset+s_index];
assign index = upstream_address[s_offset+s_index-1:s_offset];
assign offset = upstream_address[s_offset-1:0];

mux2 #(32) downstream_address_mux
(
    .sel(downstream_address_sel),
    .a(upstream_address),
    .b({tagmux_out, index, {s_offset{1'b0}}}),
    .f(downstream_address)
);

onehot_mux #(num_ways, s_tag) tagmux
(
    .sel(way),
    .datain(tags),
    .dataout(tagmux_out)
);

// MARK: - Storage units

lru_manager #(num_ways) LRUM
(
    .*
);

array #(.s_index(s_index), .width(num_ways-1)) lru_store
(
    .*,
    .read(cache_read),
    .load(ld_LRU),
    .datain(new_lru),
    .dataout(lru)
);

for (int i = 0; i < num_ways; i++) begin
    array valid_array_i
    (
        .*,
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(1'b1),
        .dataout(valids[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    array dirty_array_i
    (
        .*,
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(new_dirty),
        .dataout(dirtys[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    array #(.s_index(s_index), .width(s_tag)) tag_array_i
    (
        .*,
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(tag),
        .dataout(tags[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    data_array line_i
    (
        .*,
        .read(1'b1),
        .write_en({s_mask{cache_load_en & way[i]}}),
        .datain(upstream_wdata),
        .dataout(datas[i])
    );
end

// MARK: - Hit/Miss check

for (int i = 0; i < num_ways; i++) begin
    equals[i] = tags[i] == tag;
    hits = equals & valids;
    hit = hits != {num_ways{1'b0}};
end

onehot_mux #(num_ways, 1) validmux
(
    .sel(way),
    .datain(valids),
    .dataout(valid)
);

onehot_mux #(num_ways, 1) dirtymux
(
    .sel(way),
    .datain(dirtys),
    .dataout(dirty)
);

// MARK: - Data input

mux2 #(s_line) inmux
(
    .sel(hit),
    .a(downstream_rdata),
    .b(upstream_wdata),
    .f(inmux_out)
);

// MARK: - Data output

onehot_mux #(num_ways, s_line) hitmux
(
    .sel(way),
    .datain(datas),
    .dataout(upstream_rdata)
);

onehot_mux #(num_ways, s_line) wbmux
(
    .sel(way),
    .datain(datas),
    .dataout(wbmux_out)
);

register #(s_line) wb_reg
(
    .*,
    .load(ld_wb),
    .in(wbmux_out),
    .out(downstream_wdata)
);
    
endmodule