module counter(input clk, en, reset,in, output done, output [7:0] out_byte);//by adding the assignment logic to counter.
    reg [3:0] counter;
    always@(posedge clk) begin
        if (reset | ~en)
            counter = 0;
        else begin
            out_byte[counter] = in;
            counter = counter + 1'b1;
        end
    end
    assign done = (counter == 4'd7);
endmodule


module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
); //

    // Use FSM from Fsm_serial

    // New: Datapath to latch input bits.
	parameter start=0,stop=1,ok=2,idle=3,error=4;
    reg [2:0] state;
    wire [3:0] next;
    wire counter_done;
    counter bitcounter(clk,(state==start),reset,in,counter_done,out_byte);
    
    always@(*) begin
        case (state)
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
