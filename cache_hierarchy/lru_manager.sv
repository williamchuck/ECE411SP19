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

logic [num_ways-1:0] branches [s_way+1];
logic [num_ways-1:0] reverse_branches [s_way+1];
assign way = (hits == {num_ways{1'b0}}) ? branches[s_way] : hits;
assign branches[0] = {num_ways{1'b1}};
assign reverse_branches[s_way] = way;
genvar i;
generate begin: LRU_parsing_layers
    for (i = 0; i < s_way; i++) begin: lru_layers
        lru_manager_layer #(i) layer
        (
            .lru(lru[2**i-1 +: 2**i]),
            .upstream(branches[i][2**i-1:0]),
            .downstream(branches[i+1][2**(i+1)-1:0])
        );
        lru_manager_reverse_layer #(i)
        (
            .lru(lru[2**i-1 +: 2**i]),
            .reverse_downstream(reverse_branches[i+1][2**(i+1)-1:0]),
            .new_lru(new_lru[2**i-1 +: 2**i]),
            .reverse_upstream(reverse_branches[i][2**i-1:0])
        );
    end
end
endgenerate
    
endmodule

module lru_manager_layer #(
    parameter level = 0
)
(
    input logic [2**level-1:0] lru,
    input logic [2**level-1:0] upstream,
    output logic [2**(level+1)-1:0] downstream
);

genvar i;
generate begin: layer_logic
    for (i = 0; i < 2**level; i++) begin: layer_logic
        assign downstream[2*i] = upstream[i] & ~lru[i];
        assign downstream[2*i+1] = upstream[i] & lru[i];
    end
end
endgenerate

endmodule

module lru_manager_reverse_layer #(
    parameter level = 0
)
(
    input logic [2**level-1:0] lru,
    input logic [2**(level+1)-1:0] reverse_downstream,
    output logic [2**level-1:0] new_lru,
    output logic [2**level-1:0] reverse_upstream
);

genvar i;
generate begin: reverse_layer_logic
    for (i = 0; i < 2**level; i++) begin: reverse_layer_logic
        assign new_lru[i] =
            (reverse_downstream[2*i] | reverse_downstream[2*i+1]) ?
                reverse_downstream[2*i] : lru[i];
        assign reverse_upstream[i] =
            reverse_downstream[2*i] | reverse_downstream[2*i+1];
    end
end
endgenerate

endmodule