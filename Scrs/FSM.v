module FSM(
    input CLK,
    input Start,
    input Resetn,
    output reg [2:0] State
);

reg [3:0] n;

always @(posedge CLK or negedge Resetn)
begin
    if(!Resetn)
    begin
        State <= 3'b000;
        n <= 4'd0;
    end
    else
    begin

        case(State)

        // IDLE
        3'b000:
        begin
            n <= 4'd0;

            if(Start)
                State <= 3'b001;
        end

        // LOAD
        3'b001:
            State <= 3'b010;

        // SHIFT
        3'b010:
            State <= 3'b011;

        // ROUND
        3'b011:
            State <= 3'b100;

        // CHECK
        3'b100:
        begin
            if(n < 15)
            begin
                n <= n + 1'b1;
                State <= 3'b010;
            end
            else
                State <= 3'b101;
        end

        // DONE
        3'b101:
            State <= 3'b000;

        default:
            State <= 3'b000;

        endcase
    end
end

endmodule