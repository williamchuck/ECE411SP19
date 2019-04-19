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
    input logic clk,

    // Datapath-Control interface
    input logic cache_read,
    input logic cache_load_en,
    input logic downstream_address_sel,
    input logic ld_wb,
    input logic ld_LRU,
    input logic new_dirty,
    input logic wb_required,
    output logic hit,
    output logic valid,
    output logic dirty,

    // Upstream interface
    input logic [31:0] upstream_address,
    input logic [s_line-1:0] upstream_wdata,
    output logic [s_line-1:0] upstream_rdata,

    // Downstream interface
    input downstream_resp,
    input [s_line-1:0] downstream_rdata,
    output logic [s_line-1:0] downstream_wdata,
    output logic [31:0] downstream_address
);

// Address parsing
logic [s_tag-1:0] tag;
logic [s_index-1:0] index, index_, index_WB;

logic [num_ways-1:0] way;
logic [num_ways-2:0] lru, new_lru;
logic [num_ways-1:0] equals, dirtys, valids, hits;
logic [s_tag-1:0] tags [num_ways];
logic [s_tag-1:0] tagmux_out, tagmux_out_, tagmux_out_WB;
logic [s_line-1:0] hitmux_out, wbmux_out, inmux_out, hit_data, miss_data;
logic [s_line-1:0] datas [num_ways];
logic [s_line-1:0] line_dataout;

logic [31:0] _address_, _address_WB;

register #(32) upstream_to_downstream_address_buffer
(
    .clk,
    .load(1'b1),
    .in(upstream_address),
    .out(_address_)
);

register #(s_tag) upstream_to_downstream_tagmuxout_buffer
(
    .clk,
    .load(1'b1),
    .in(tagmux_out),
    .out(tagmux_out_)
);

register #(s_tag) tag_wb_buffer
(
    .clk,
    .load(wb_required),
    .in(tagmux_out_),
    .out(tagmux_out_WB)
);

register #(32) address_wb_buffer
(
    .clk,
    .load(wb_required),
    .in(_address_),
    .out(_address_WB)
);

assign tag = _address_[31:s_offset+s_index];
assign index_ = _address_[s_offset+s_index-1:s_offset];
assign index = upstream_address[s_offset+s_index-1:s_offset];
assign index_WB = _address_WB[s_offset+s_index-1:s_offset];

// assign downstream_address = downstream_address_sel ? {tagmux_out_, index_, {s_offset{1'b0}}} : _address_;
assign downstream_address = downstream_address_sel ? {tagmux_out_WB, index_WB, {s_offset{1'b0}}} : _address_;
assign upstream_rdata = downstream_resp ? downstream_rdata : line_dataout;

onehot_mux #(s_way, s_tag) tagmux
(
    .sel(way),
    .datain(tags),
    .dataout(tagmux_out)
);

// MARK: - Storage units

lru_manager #(s_way) LRUM
(
    //inputs
    .lru,
    .hits,
    //outputs
    .way,
    .new_lru
);

array #(.s_index(s_index), .width(num_ways-1)) lru_store
(
    .clk,
    .rindex(index),
    .windex(index),
    .read(cache_read),
    .load(ld_LRU),
    .datain(new_lru),
    .dataout(lru)
);

genvar i;

generate begin: arrays

for (i = 0; i < num_ways; i++) begin : forloop
    array valid_array
    (
        .clk,
        .rindex(index),
        .windex(index),
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(1'b1),
        .dataout(valids[i])
    );
    
    array dirty_array
    (
        .clk,
        .rindex(index),
        .windex(index),
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(new_dirty),
        .dataout(dirtys[i])
    );
    
    array #(.s_index(s_index), .width(s_tag)) tag_array
    (
        .clk,
        .rindex(index),
        .windex(index),
        .read(cache_read),
        .load(cache_load_en & way[i]),
        .datain(tag),
        .dataout(tags[i])
    );
    
    data_array line
    (
        .clk,
        .read(1'b1),
        .write_en({s_mask{cache_load_en & way[i]}}),
        .rindex(index),
        .windex(index),
        .datain(inmux_out),
        .dataout(datas[i])
    );
    
    assign equals[i] = tags[i] == tag;
    assign hits[i] = equals[i] & valids[i];
end

// MARK: - Hit/Miss check
end
endgenerate

assign hit = hits != {num_ways{1'b0}};

onehot_mux_1b #(s_way) validmux
(
    .sel(way),
    .datain(valids),
    .dataout(valid)
);

onehot_mux_1b #(s_way) dirtymux
(
    .sel(way),
    .datain(dirtys),
    .dataout(dirty)
);

// MARK: - Data input

assign inmux_out = hit ? upstream_wdata : downstream_rdata;

// MARK: - Data output

onehot_mux #(s_way, s_line) hitmux
(
    .sel(way),
    .datain(datas),
    // .dataout(upstream_rdata)
    .dataout(line_dataout)
);

onehot_mux #(s_way, s_line) wbmux
(
    .sel(way),
    .datain(datas),
    .dataout(wbmux_out)
);

register #(s_line) wb_reg
(
    .clk,
    .load(ld_wb),
    .in(wbmux_out),
    .out(downstream_wdata)
);
    
endmodule