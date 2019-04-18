module cache_hierarchy #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask
)
(
    input clk,
    input imem_stall,
    input imem_read,
    input imem_write,
    input logic [31:0] imem_address,
    input logic [3:0] imem_byte_enable,
    input logic [31:0] imem_wdata,
    output logic imem_resp,
    output logic [31:0] imem_rdata,
    output logic imem_ready,

    input dmem_stall,
    input dmem_read,
    input dmem_write,
    input [31:0] dmem_address,
    input [3:0] dmem_byte_enable,
    input [31:0] dmem_wdata,
    output logic [31:0] dmem_rdata,
    output logic dmem_resp,
    output logic dmem_ready,

    input pmem_resp,
    input logic [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address,
    output logic pmem_read,
    output logic pmem_write
);

logic dpipe, ipipe;
assign dpipe = dmem_resp & ~dmem_stall;
assign ipipe = imem_resp & ~imem_stall;

logic [s_offset-1:0] imem_offset, dmem_offset;
assign imem_offset = {imem_address[s_offset-1:2], 2'd0};
assign dmem_offset = {dmem_address[s_offset-1:2], 2'd0};
logic [s_offset-1:0] imem_offset_ACT, dmem_offset_ACT;

logic [3:0] dmem_byte_enable_ACT;

logic dmem_write_ACT;

logic icache_read, dcache_read, dcache_write;
logic l2_icache_resp, l2_icache_read, l2_icache_write, l2_dcache_resp;
logic l2_dcache_read, l2_dcache_write, l2_read, l2_write, l2_resp;
logic l2_stall, l2_ready;
logic [31:0] imem_rdata_transformer_out, dmem_rdata_transformer_out, dmem_wdata_ACT;
logic [31:0] l2_icache_address, l2_dcache_address, l2_address;
logic [255:0] icache_rdata, l2_icache_rdata, l2_icache_wdata;
logic [255:0] l2_dcache_wdata, dcache_wdata, dcache_rdata;
logic [255:0] dcache_downstream_rdata_transformed, l2_wdata, l2_rdata, l2_dcache_rdata;
logic [255:0] pmem_rdata_sync;
logic pmem_resp_sync;

logic l2_icache_ready, l2_dcache_ready;
logic l2_icache_request_ongoing, l2_dcache_request_ongoing, l2_pmem_request_ongoing;

cache_core_pipelined #(.s_offset(s_offset), .s_index(s_index), .s_way(2)) icache_core
(
    .clk,
    .stall(imem_stall),
    .upstream_read(icache_read),
    .upstream_write(1'b0),
    .upstream_address(imem_address),
    .upstream_wdata({s_line{1'b0}}),
    .upstream_rdata(icache_rdata),
    .upstream_resp(imem_resp),
    .upstream_ready(imem_ready),

    .downstream_resp(l2_icache_resp),
    .downstream_ready(l2_icache_ready),
    .downstream_rdata(l2_icache_rdata),
    .downstream_wdata(l2_icache_wdata),
    .downstream_read(l2_icache_read),
    .downstream_write(l2_icache_write),
    .downstream_address(l2_icache_address),
    .downstream_request_ongoing(l2_icache_request_ongoing)
);

cache_core_pipelined #(.s_offset(s_offset), .s_index(s_index), .s_way(2)) dcache_core
(
    .clk,
    .stall(dmem_stall),
    .upstream_read(dcache_read),
    .upstream_write(dcache_write),
    .upstream_address(dmem_address),
    .upstream_wdata(dcache_wdata),
    .upstream_rdata(dcache_rdata),
    .upstream_resp(dmem_resp),
    .upstream_ready(dmem_ready),

    .downstream_resp(l2_dcache_resp),
    .downstream_ready(l2_dcache_ready),
    .downstream_rdata(dcache_downstream_rdata_transformed),
    .downstream_wdata(l2_dcache_wdata),
    .downstream_read(l2_dcache_read),
    .downstream_write(l2_dcache_write),
    .downstream_address(l2_dcache_address),
    .downstream_request_ongoing(l2_dcache_request_ongoing)
);

logic [255:0] l2_pmem_wdata;
logic l2_pmem_read, l2_pmem_write, pmem_ready;
logic [31:0] l2_pmem_address;

cache_core_pipelined #(.s_offset(s_offset), .s_index(s_index), .s_way(3)) l2_cache_core
(
    .clk,
    .stall(l2_stall),
    .upstream_read(l2_read),
    .upstream_write(l2_write),
    .upstream_address(l2_address),
    .upstream_wdata(l2_wdata),
    .upstream_rdata(l2_rdata),
    .upstream_resp(l2_resp),
    .upstream_ready(l2_ready),
    .downstream_resp(pmem_resp_sync),
    .downstream_ready(pmem_ready),
    .downstream_rdata(pmem_rdata_sync),
    .downstream_wdata(l2_pmem_wdata),
    .downstream_read(l2_pmem_read),
    .downstream_write(l2_pmem_write),
    .downstream_address(l2_pmem_address),
    .downstream_request_ongoing(l2_pmem_request_ongoing)
);

register #(256+32+1+1) l2_pmem_request_reg
(
    .clk,
    .load(pmem_resp_sync | (~pmem_read & ~pmem_write)),
    .in({l2_pmem_wdata, l2_pmem_read, l2_pmem_write, l2_pmem_address}),
    .out({pmem_wdata, pmem_read, pmem_write, pmem_address})
);

pmem_synchronizer pmem_intf
(
    .clk,
    .stall(l2_stall),
    .pmem_resp,
    .pmem_read,
    .pmem_write,
    .pmem_rdata,
    .pmem_ready,
    .pmem_resp_sync,
    .pmem_rdata_sync
);

// assign pmem_resp_sync = pmem_resp;
// assign pmem_rdata_sync = pmem_rdata;

cache_arbiter arbiter
(
    .clk,
    .l2_icache_request_ongoing,
    .l2_dcache_request_ongoing,
    .imem_read,
    .dmem_read,
    .dmem_write,
    .icache_read,
    .dcache_read,
    .dcache_write,

    .l2_icache_read,
    .l2_icache_write,
    .imem_stall,
    .l2_icache_address,
    .l2_icache_wdata,
    .l2_icache_resp,
    .l2_icache_rdata,
    .l2_icache_ready,

    .l2_dcache_read,
    .l2_dcache_write,
    .dmem_stall,
    .l2_dcache_address,
    .l2_dcache_wdata,
    .l2_dcache_resp,
    .l2_dcache_rdata,
    .l2_dcache_ready,

    .l2_ready,
    .l2_stall,
    .l2_resp,
    .l2_rdata,
    .l2_read,
    .l2_write,
    .l2_address,
    .l2_wdata
);

register #(s_offset) imem_pipeline_reg
(
    .clk,
    .load(ipipe),
    .in({imem_offset}),
    .out({imem_offset_ACT})
);

register #(s_offset+1+4+32) dmem_pipeline_reg
(
    .clk,
    .load(dpipe),
    .in({dmem_offset, dmem_write, dmem_byte_enable, dmem_wdata}),
    .out({dmem_offset_ACT, dmem_write_ACT, dmem_byte_enable_ACT, dmem_wdata_ACT})
);

input_transformer dcache_downstream_rdata_transformer
(
    .line_data(l2_dcache_rdata),
    .word_data(dmem_wdata_ACT),
    .enable(dmem_write_ACT),
    .offset(dmem_offset_ACT),
    .wmask(dmem_byte_enable_ACT),
    .dataout(dcache_downstream_rdata_transformed)
);

input_transformer dcache_upstream_wdata_transformer
(
    .line_data(dcache_rdata),
    .word_data(dmem_wdata_ACT),
    .enable(dmem_write_ACT),
    .offset(dmem_offset_ACT),
    .wmask(dmem_byte_enable_ACT),
    .dataout(dcache_wdata)
);

output_transformer icache_output_transformer
(
    .line_data(icache_rdata),
    .offset(imem_offset_ACT),
    .dataout(imem_rdata)
);

output_transformer dcache_output_transformer
(
    .line_data(dcache_rdata),
    .offset(dmem_offset_ACT),
    .dataout(dmem_rdata)
);

endmodule