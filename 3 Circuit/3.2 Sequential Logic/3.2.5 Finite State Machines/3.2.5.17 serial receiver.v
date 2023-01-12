module counter(input clk, en, reset, output done);
    reg [2:0] counter;
    always@(posedge clk) begin
        if (reset | ~en)
            counter = 0;
        else 
            counter = counter + 1'b1;
    end
    assign done = (counter == 4'd7);
endmodule
//using a 8bit counter.

module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output done
); 
	parameter start=0,stop=1,ok=2,idle=3,error=4;
    reg [2:0] state;
    wire [3:0] next;
    wire counter_done;
    counter bitcounter(clk,(state==start),reset,counter_done);
    
    always@(*) begin
        case (state)
               //5 states
            idle: next=in?idle:start;
            start: next = counter_done?stop:start;
            stop: next = in?ok:error;
            ok: next = in?idle:start;
            error: next = in?idle:error;
        endcase
    end
    
    always@(posedge clk) begin
        if (reset)
            state = idle;
        else
            state = next;
    end
    
    assign done = (state == ok);
endmodule
