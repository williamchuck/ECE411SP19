import rv32i_types::*;

module cache_datapath #(
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
    input logic dirty_read,
    input logic [num_ways-1:0] cache_load,
    input logic [num_ways-1:0] dirty_load,
    input logic inmux_sel,
    input logic pmem_address_sel,
    input logic ld_wb,
    input logic ld_LRU,
    input logic new_dirty,
    output logic hit,
    output logic valid,
    output logic dirty,
    output logic [num_ways-1:0] way,

    // Cache-CPU interface
    input mem_write,
    input rv32i_mem_wmask mem_byte_enable,
    input rv32i_word mem_address,
    input rv32i_word mem_wdata,
    output rv32i_word mem_rdata,

    // Cache-Memory interface
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address
);

// Address parsing
logic [s_tag-1:0] tag;
logic [s_index-1:0] index;
logic [s_offset-1:0] offset;

logic [num_ways-2:0] lru, new_lru;
logic [num_ways-1:0] equals, dirtys, valids, hits;
logic [s_tag-1:0] tags [num_ways];
logic [s_tag-1:0] tagmux_out;
logic [s_line-1:0] data1, data0, hitmux_out, wbmux_out, inmux_out,
                   hit_data, miss_data;

assign tag = mem_address[31:s_offset+s_index];
assign index = mem_address[s_offset+s_index-1:s_offset];
assign offset = mem_address[s_offset-1:0];

mux2 #(32) pmem_address_mux
(
    .sel(pmem_address_sel),
    .a(mem_address),
    .b({tagmux_out, index, {s_offset{1'b0}}}),
    .f(pmem_address)
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
    array valid_arrays
    (
        .*,
        .read(cache_read),
        .load(cache_load[i]),
        .datain(1'b1),
        .dataout(valids[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    array dirty_arrays
    (
        .*,
        .read(dirty_read),
        .load(dirty_load[i]),
        .datain(new_dirty),
        .dataout(dirtys[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    array #(.s_index(s_index), .width(s_tag)) tag_array_i
    (
        .*,
        .read(cache_read),
        .load(cache_load[i]),
        .datain(tag),
        .dataout(tags[i])
    );
end

for (int i = 0; i < num_ways; i++) begin
    data_array line_i
    (
        .*,
        .read(1'b1),
        .write_en(cache_load[i] ? {s_mask{1'b1}} : {s_mask{1'b0}}),
        .datain(inmux_out),
        .dataout({datas[i]})
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

input_transformer hit_in_transformer
(
    .line_data(hitmux_out),
    .word_data(mem_wdata),
    .enable(mem_write),
    .offset(offset),
    .wmask(mem_byte_enable),
    .dataout(hit_data)
);

input_transformer miss_in_transformer
(
    .line_data(pmem_rdata),
    .word_data(mem_wdata),
    .enable(mem_write),
    .offset(offset),
    .wmask(mem_byte_enable),
    .dataout(miss_data)
);

mux2 #(s_line) inmux
(
    .sel(inmux_sel),
    .a(miss_data),
    .b(hit_data),
    .f(inmux_out)
);

// MARK: - Data output

onehot_mux #(num_ways, s_line) hitmux
(
    .sel(way),
    .datain(datas),
    .dataout(hitmux_out)
);

output_transformer hit_out_transformer
(
    .line_data(hitmux_out),
    .offset(offset),
    .dataout(mem_rdata)
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
    .out(pmem_wdata)
);

endmodule : cache_datapath
