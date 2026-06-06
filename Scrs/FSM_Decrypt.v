module FSM_Decrypt(
    input CLK,
    input Start,
    input Resetn,

    output reg [2:0] State,
    output reg [4:0] n
);


localparam
    S0 = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    S3 = 3'b011,
    S4 = 3'b100,
    S5 = 3'b101,
    S6 = 3'b110,
    S7 = 3'b111;

always @(posedge CLK or negedge Resetn)
begin
    if(!Resetn)
    begin
        n <= 0;
        State <= S0;
    end
    else
    begin
        case(State)

        //================ IDLE =================
        S0:
        begin
            n <= 0;

            if(Start)
                State <= S1;
        end

        //================ LOAD =================
        S1:
        begin
            State <= S2;
        end

        //================ SHIFT LEFT =================
        S2:
        begin
            n <= n + 1;
            State <= S3;
        end

        //================ CHECK LEFT =================
        S3:
        begin
            if(n < 16)
                State <= S2;
            else
            begin
                n <= 16;
                State <= S4;
            end
        end

        //================ SHIFT RIGHT =================
        S4:
        begin
            n <= n - 1;
            State <= S5;
        end

        //================ DES ROUND =================
        S5:
        begin
            State <= S6;
        end

        //================ CHECK ROUND =================
        S6:
        begin
            if(n > 0)
                State <= S4;
            else
                State <= S7;
        end

        //================ DONE =================
        S7:
        begin
            if(!Start)
                State <= S0;
        end

        endcase
    end
end

endmodule