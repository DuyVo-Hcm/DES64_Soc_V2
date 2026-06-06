module ControlUnit_Decrypt(
    input CLK,
    input Start,
    input Resetn,

    output reg S_Data,
    output reg [1:0] S_Key,

    output [4:0] n,

    output reg done,

    output reg WE_D,
    output reg WE_K
);

wire [2:0] State;

//================ FSM =================
FSM_Decrypt fsm (
    .CLK(CLK),
    .Start(Start),
    .Resetn(Resetn),
    .State(State),
    .n(n)
);

//================ CONTROL =================
always @(*) begin

    // default
    S_Data = 0;
    S_Key  = 2'b00;

    WE_D   = 0;
    WE_K   = 0;

    done   = 0;

    case(State)

    //================ S0 : IDLE =================
    3'b000: begin
    end

    //================ S1 : LOAD =================
    3'b001: begin
        S_Data = 0;
        S_Key  = 2'b00;

        WE_D = 1;
        WE_K = 1;
    end

    //================ S2 : SHIFT LEFT =================
    3'b010: begin
        S_Key = 2'b01;
        WE_K  = 1;
    end

    //================ S3 : CHECK LEFT =================
    3'b011: begin
    end

    //================ S4 : SHIFT RIGHT =================
    3'b100: begin
        S_Key = 2'b10;
        WE_K  = 1;
    end

    //================ S5 : ROUND =================
    3'b101: begin
        S_Data = 1;
        WE_D   = 1;
    end

    //================ S6 : CHECK ROUND =================
    3'b110: begin
    end

    //================ S7 : DONE =================
    3'b111: begin
        done = 1;
    end

    endcase
end

endmodule