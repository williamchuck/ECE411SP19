module lru_manager #(
    parameter s_way = 2,
    parameter num_ways = 2**s_way
)
(
    input logic [num_ways-2:0] lru,
    input logic [num_ways-1:0] hits,
    output logic [num_ways-1:0] way,
    output logic [num_ways-2:0] new_lru
);

always_comb begin : LRU_logic
    new_lru = lru;
    way = hits;
end
    
endmodule