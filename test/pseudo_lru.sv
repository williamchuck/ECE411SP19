module pseudo_lru_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
int count;

initial begin
    clk = 0;
end

always #5 clk = ~clk;
always #5 count = count + 1;

logic [3:0] two_way_way [16];
logic 

always @(posedge clk) begin
    if (result != answer[count]) begin
        $display("Halting with error");
        $finish;
    end

    if (count > 10) begin
        $display("Successful");
        $finish;
    end
end