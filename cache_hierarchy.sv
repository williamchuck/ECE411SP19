module cache_hierarchy #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask
)
(
    input clk,
    input imem_read,
    input imem_write,
    input logic [31:0] imem_address,
    input logic [3:0] imem_byte_enable,
    input logic [31:0] imem_wdata,
    output logic imem_resp,
    output logic [31:0] imem_rdata,

    input dmem_read,
    input dmem_write,
    input [31:0] dmem_address,
    input [3:0] dmem_byte_enable,
    input [31:0] dmem_wdata,
    output logic [31:0] dmem_rdata,
    output logic dmem_resp,

    input pmem_resp,
    input logic [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address,
    output logic pmem_read,
    output logic pmem_write
);

logic [s_offset-1:0] imem_offset, dmem_offset;
assign imem_offset = {imem_address[s_offset-1:2], 2'd0};
assign dmem_offset = {dmem_address[s_offset-1:2], 2'd0};

logic icache_read, dcache_read, dcache_write;
logic l2_icache_resp, l2_icache_read, l2_icache_write, l2_dcache_resp;
logic l2_dcache_read, l2_dcache_write, l2_read, l2_write, l2_resp;
logic icache_hit, dcache_hit, l2_hit;
logic [31:0] imem_rdata_transformer_out, dmem_rdata_transformer_out;
logic [31:0] l2_icache_address, l2_dcache_address, l2_address;
logic [255:0] icache_rdata, l2_icache_rdata, l2_icache_wdata;
logic [255:0] l2_dcache_wdata, dcache_wdata, dcache_rdata;
logic [255:0] l2_dcache_rdata_transformed, l2_wdata, l2_rdata, l2_dcache_rdata;
logic [255:0] dmem_rdatamux_out, imem_rdatamux_out, new_imem_rdatamux_out;
logic [255:0] pmem_rdata_reg_out;

register #(256) pmem_rdata_reg
(
    .clk,
    .load(pmem_resp),
    .in(pmem_rdata),
    .out(pmem_rdata_reg_out)
);

cache_core #(.s_offset(s_offset), .s_index(s_index), .s_way(2)) icache_core
(
    .clk,
    .hit(icache_hit),
    .upstream_read(icache_read),
    .upstream_write(1'b0),
    .upstream_address(imem_address),
    .upstream_wdata({s_line{1'b0}}),
    .upstream_rdata(icache_rdata),
    .upstream_resp(imem_resp),
    .downstream_resp(l2_icache_resp),
    .downstream_rdata(l2_icache_rdata),
    .downstream_wdata(l2_icache_wdata),
    .downstream_read(l2_icache_read),
    .downstream_write(l2_icache_write),
    .downstream_address(l2_icache_address)
);

cache_core #(.s_offset(s_offset), .s_index(s_index), .s_way(2)) dcache_core
(
    .clk,
    .hit(dcache_hit),
    .upstream_read(dcache_read),
    .upstream_write(dcache_write),
    .upstream_address(dmem_address),
    .upstream_wdata(dcache_wdata),
    .upstream_rdata(dcache_rdata),
    .upstream_resp(dmem_resp),
    .downstream_resp(l2_dcache_resp),
    .downstream_rdata(l2_dcache_rdata_transformed),
    .downstream_wdata(l2_dcache_wdata),
    .downstream_read(l2_dcache_read),
    .downstream_write(l2_dcache_write),
    .downstream_address(l2_dcache_address)
);

cache_core #(.s_offset(s_offset), .s_index(s_index), .s_way(3)) l2_cache_core
(
    .clk,
    .hit(l2_hit),
    .upstream_read(l2_read),
    .upstream_write(l2_write),
    .upstream_address(l2_address),
    .upstream_wdata(l2_wdata),
    .upstream_rdata(l2_rdata),
    .upstream_resp(l2_resp),
    .downstream_resp(pmem_resp),
    .downstream_rdata(pmem_rdata),
    .downstream_wdata(pmem_wdata),
    .downstream_read(pmem_read),
    .downstream_write(pmem_write),
    .downstream_address(pmem_address)
);

cache_arbiter arbiter
(
    .*
);

input_transformer dcache_downstream_rdata_transformer
(
    .line_data(dmem_rdatamux_out),
    .word_data(dmem_wdata),
    .enable(dmem_write),
    .offset(dmem_offset),
    .wmask(dmem_byte_enable),
    .dataout(l2_dcache_rdata_transformed)
);

input_transformer dcache_upstream_wdata_transformer
(
    .line_data(dcache_rdata),
    .word_data(dmem_wdata),
    .enable(dmem_write),
    .offset(dmem_offset),
    .wmask(dmem_byte_enable),
    .dataout(dcache_wdata)
);

always_comb begin : dmem_rdata_selection
    if (dcache_hit) begin
        dmem_rdatamux_out = dcache_rdata;
    end else if (l2_hit & l2_read) begin
        dmem_rdatamux_out = l2_rdata;
    end else begin
        dmem_rdatamux_out = pmem_rdata;
    end
end

logic [255:0] imem_rdatamux_out_prev, dmem_rdatamux_out_prev;

always_comb begin : imem_rdata_selection
    // new_imem_rdatamux_out = imem_rdatamux_out;
    if (icache_hit) begin
        imem_rdatamux_out = icache_rdata;
    end else if (l2_hit & l2_read) begin
        imem_rdatamux_out = l2_rdata;
    end else begin
        imem_rdatamux_out = pmem_rdata;
    end
end

always_ff @(posedge clk) begin
    if (pmem_resp) begin
        imem_rdatamux_out_prev <= imem_rdatamux_out;
        dmem_rdatamux_out_prev <= dmem_rdatamux_out;
    end
end

output_transformer icache_output_transformer
(
    .line_data(pmem_resp ? imem_rdatamux_out : imem_rdatamux_out_prev),
    .offset(imem_offset),
    .dataout(imem_rdata_transformer_out)
);

output_transformer dcache_output_transformer
(
    .line_data(pmem_resp ? dmem_rdatamux_out : dmem_rdatamux_out_prev),
    .offset(dmem_offset),
    .dataout(dmem_rdata_transformer_out)
);

// Pipeline register

always_ff @( posedge clk ) begin
    if (imem_resp) begin
        imem_rdata <= imem_rdata_transformer_out;
    end

    if (dmem_resp) begin
        dmem_rdata <= dmem_rdata_transformer_out;
    end
end
    
endmodule