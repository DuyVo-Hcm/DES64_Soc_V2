`timescale 1ns / 1ps

module ControllUnit(
    input CLK,
    input Start,
    input Resetn,

    output reg S_Data, 
    output reg S_Key,
    output reg [4:0] n,

    output reg WE_D,
    output reg WE_K,

    output reg done
);

//================ FSM =================
wire [2:0] State;
reg [4:0] round;

FSM fsm (
    .CLK(CLK),
    .Start(Start),
    .Resetn(Resetn),
    .State(State)
);

//================ ROUND COUNTER =================
always @(posedge CLK or negedge Resetn) begin
    if (!Resetn)
        round <= 0;
    else if (State == 3'b000)   // IDLE
        round <= 0;
    else if (State == 3'b011)   // ? sau ROUND m?i t?ng
        round <= round + 1;
end

//================ SHIFT INPUT =================
always @(*) begin
    n = round + 1;  
    // ? vì:
    // SHIFT dùng round+1
    // ROUND dùng key ?ã register
end

//================ CONTROL SIGNAL =================
always @(*) begin
    // default
    S_Data = 0;
    S_Key  = 0;
    WE_D   = 0;
    WE_K   = 0;
    done   = 0;

    case (State)

        //========= IDLE =========
        3'b000: begin
        end

        //========= LOAD =========
        3'b001: begin
            S_Data = 0; // IP
            S_Key  = 0; // PC1

            WE_D = 1;
            WE_K = 1;

        end

        //========= SHIFT KEY =========
        3'b010: begin
            S_Key = 1;
            WE_K = 1;   
            WE_D = 0;
        end

        //========= ROUND =========
        3'b011: begin
            S_Data = 1;
            WE_D = 1;
            WE_K = 0;
   
        end

        //========= CHECK =========
        3'b100: begin
            WE_D = 0;
            WE_K = 0;
        end

        //========= DONE =========
        3'b101: begin
            done = 1;
        end

    endcase
end

endmodule