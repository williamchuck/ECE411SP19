module Control
(
    input logic Clk,
    input logic Execute,
    input logic m,
    input logic div,
    input logic differentSigns,
    input logic stall,
    output logic Load,
    output logic Shift,
    output logic Subtract,
    output logic clearAloadB,
    output logic flipsign,
    output logic resp,
    output logic ready,

    //for printing

    input logic [32:0] _opA, _opB,
    input logic [32:0] Aval, Bval
);
//NOTE, We are assumming Execute is active high
enum logic [4:0]
{
    IDLE,
    LOAD,
    SHIFT,
    LASTLOADDIV,
    FLIPSIGN,
    DONE
} curr_state, next_state; 

//Performance metric
logic [31:0] executed_ins_count;

initial begin
    executed_ins_count = 0;
end

logic [6:0] counter, nextCounter;

//updates flip flop, current state is the only one
always_ff @ (posedge Clk) begin
    curr_state <= next_state;
    counter <= nextCounter;
    if(curr_state == IDLE & next_state != IDLE)
        executed_ins_count <= executed_ins_count + 1;
end

// Assign outputs based on state
always_comb begin
    next_state  = curr_state;
    nextCounter = counter;
    
    unique case (curr_state)
    
        IDLE: begin
            if (Execute)
                next_state = LOAD;
            nextCounter = 7'd33;
        end

        DONE: begin
            if(~stall)
                next_state = IDLE;
        end
            
        LOAD: begin
            nextCounter = counter - 1'd1;
            next_state = SHIFT;
        end
        
        SHIFT : begin
            if(counter == 7'd0)
                if(div)
                    next_state = LASTLOADDIV;
                else
                    next_state = DONE;
            else
                next_state = LOAD;
        end

        LASTLOADDIV: begin
            if(differentSigns)
                next_state = FLIPSIGN;
            else
                next_state = DONE;
        end

        FLIPSIGN : begin
            next_state = DONE;
        end
        
        default: next_state = IDLE;
        
    endcase
    
    Shift = 1'd0;
    Load  = 1'd0;
    Subtract = 1'd0;
    clearAloadB = 1'b0;
    flipsign = 1'd0;
    ready = 1'd0;
    resp = 1'd0;
    
    // Assign outputs based on ‘state’
    case (curr_state)
    
        LOAD, LASTLOADDIV: begin
            Subtract = !nextCounter & m;
            Load = 1'd1;
        end

        FLIPSIGN: begin
            flipsign = 1'd1;
        end

        SHIFT: begin
            Subtract = !counter & m;
            Shift = 1'b1;
        end

        IDLE: begin
            Load = 1'd1;
            clearAloadB = 1'd1;
            resp = ~Execute;
        end
        
        DONE: begin
            ready = 1'd1;
            resp = 1'd1;
        end

       default: ; //default case, can also have default assignments for Ld_A and Ld_B before case

endcase
end

//DEBUGGING USE ONLY

// logic [32:0] _opA, _opB;

// always_ff @(posedge Clk) begin
//     _opA <= opA;
//     _opB <= opB;
// end

always @(posedge Clk) begin
    if (curr_state == DONE) begin
//         // $display("%0t Done. div: %b opA: %d opB: %d Aval: %d, Bval: %d, AvalBval: %d", $time, div, opA, opB, Aval, Bval, {Aval, Bval});

//         if(!div && opA * opB != {Aval, Bval}) begin
//             $display("Error incorrect result! Expected product: %h, found: %h", opA * opB, {Aval, Bval});
//         end

        if(div && (Aval != _opA % _opB || Bval != _opA / _opB)) begin
            $display("%0t Error incorrect result! Expected quotient: %d, found: %d Expected Remainder: %d, found: %d", $time, _opA / _opB, Bval, _opA % _opB, Aval);
        end
    end

    // if(curr_state != IDLE) begin
    //     if(_opA != opA)
    //         $display("%0t Change in A! From %h to %h", $time, _opA, opA);
    //     if(_opB != opB)
    //         $display("%0t Change in B! From %h to %h", $time, _opB, opB);
    // end
end

endmodule
