module Control
(
    input logic Clk,
    input logic Execute,
    input logic m,
    input logic div,
    output logic Load,
    output logic Shift,
    output logic Subtract,
    output logic clearAloadB,
    output logic ready
);
//NOTE, We are assumming Execute is active high
enum logic [4:0]
{
    IDLE,
    BEGIN,
    LOAD,
    SHIFT,
    DONE
} curr_state, next_state; 

logic [6:0] counter, nextCounter;

//updates flip flop, current state is the only one
always_ff @ (posedge Clk) begin
    curr_state <= next_state;
    counter <= nextCounter;
end

// Assign outputs based on state
always_comb begin
    next_state  = curr_state;
    nextCounter = counter;
    
    unique case (curr_state)
        BEGIN: next_state = LOAD;
    
        IDLE : if (Execute) begin
            next_state = BEGIN;
            if(div)
                nextCounter = 7'd34;
            else
                nextCounter = 7'd33;
        end
            
        LOAD: begin
            nextCounter = counter - 1'd1;
            //if(counter == 7'd0)
            //    next_state = DONE;
            //else
            //    next_state = SHIFT;
            next_state = SHIFT;
        end
        
        SHIFT : begin
            if(counter == 7'd0)
                next_state = DONE;
            else
                next_state = LOAD;
        end
        
        default: next_state = IDLE;
        
    endcase
    
    Shift = 1'd0;
    Load  = 1'd0;
    Subtract = 1'd0;
    clearAloadB = 1'b0;
    ready = 1'd0;
    
    // Assign outputs based on ‘state’
    case (curr_state)
        BEGIN: begin
            Load = 1'd1;
            clearAloadB = 1'd1;
        end
    
        LOAD: begin
            Subtract = !nextCounter & m;
            Load = 1'd1;
        end

        SHIFT: begin
            Subtract = !counter & m;
            Shift = 1'b1;
        end

        IDLE: begin
        end
        
        DONE: begin
            ready = 1'd1;
        end

       default: ; //default case, can also have default assignments for Ld_A and Ld_B before case

endcase
end

endmodule
