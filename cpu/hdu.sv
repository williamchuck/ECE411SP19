module hdu (
    input logic no_mem,
    input logic ir_out,

    output logic no_hazard,
    //TODO: Add forwarding signal to FWU
    output logic stall
);

assign no_hazard = 1'd1;
    
endmodule