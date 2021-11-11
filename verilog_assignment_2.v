//1. Finite State Machine
module FSM1 (clk, x, y, z, reset)
input clk, x, y, reset;
output z;

reg[1:0] state, nxtst;

parameter S00=0, S01=1, S10=2, S11=3;

//state logic to determine next state
always @ (state or x or y) begin
    case(state)
    S00 : nxtst = S01;

    S01 : if (x) nxtst = S01;
            else nxtst = S11;

    S10 : if (!x) nxtst = S00;
            elseif(y) nxtst = S01;
            else nxtst = S10;

    S11 : if (y) nxtst = S01;
            else nxtst = S10;
    default: nxtst = S01;
    endcase
end

//asynch reset flip flop
always @ (posedge clk or negedge reset) begin
    if (!reset) state <= S01;
    else state <= nxtst;
end

assign z = (state==S01 or state==S10);
endmodule



//2. 5 to 1 MUX
module five_mux(sig_five, select_five, y)
wire[4:0] sig_five;
wire[2:0] select_five;
reg y;

input[4:0] sig_five;
input[2:0] select_five;
output y;

always @ (select_five or sig_five) begin
    y=0;
    case(select_five)
        3'b000 : y = sig_five[0];
        3'b001 : y = sig_five[1];
        3'b010 : y = sig_five[2];
        3'b011 : y = sig_five[3];
        3'b100 : y = sig_five[4];
        default: y = 0;
    endcase;
end
endmodule

// 20 to 1 MUX
module twenty_mux(signals, select, z)
wire[4:0] select;
wire[19:0] signals;
reg z;

input[4:0] select;
input[19:0] signals;
output z;

reg[4:0] w;
//use first 3 select bits to reduce to 4 intermediate input signals. Uses 4 5 to 1 MUX gates
generate
    for (i=0; i<=3; i=i+1) begin : lsb
        five_mux mux_0(.sig_five(signals[(5*i + 4):(5*i)]), .select_five(select[2:0]), .y(w[i]));
    end
endgenerate

//use last 2 select bits to MUX between 4 intermediate inputs using 5 to 1 MUX.;
five_mux mux_1(.sig_five(w), .select_five({0,select[4:3]}), .y(y));

endmodule


//3. Equivalent strucural code
/*
000 -> 0 0 1 1
001 -> 0 1 0 1
010 -> 0 1 1 1
011 -> 1 0 0 1 
100 -> 1 0 1 1
101 -> 1 1 0 1
110 -> 1 1 1 1
111 -> 0 0 0 0
*/
module structural(a, y) 
input[2:0] a;
output[3:0] y;
wire[2:0] a;
wire[3:0] y;

assign 
    y[0] = !&a, //reduction NAND
    y[1] = !a[0], 
    y[2] = ^a[1:0], //reduction XOR
    y[3] = (a[0] && a[1]) || (a[1] && a[2]) || (a[2] && a[0]); //majority function

endmodule
