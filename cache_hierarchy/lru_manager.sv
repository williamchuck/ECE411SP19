module manager #(
    parameter num_ways = 4,
    parameter s_way = $clog(num_ways)
)
(
    input logic [num_ways-2:0] lru,
    input logic [num_ways-1:0] hits,
    output logic [num_ways-1:0] way,
    output logic [num_ways-2:0] new_lru
);

always_comb begin : LRU_logic
    new_lru = lru;
    // Logic for calculating way
    if (hits == {num_ways{0}}) begin
        for (int j = 0, k = 0; j < s_way; j++) begin
            new_lru[k] = ~lru[k];
            way[j] = 2*k+1+lru[k];
            k = k*2+1+lru[k];
        end
    end else begin
        way = hits;
        for (logic [s_way-1:0] i = 0; i < num_ways; i++) begin
            if (hits == (1 << i)) begin
                for (int j = 0; j < s_way; j++) begin
                    new_lru[k] = ~i[j];
                    k = k*2+1+i[k];
                end
            end
        end
    end
end
    
endmodule