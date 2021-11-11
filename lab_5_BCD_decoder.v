
part 2-2-1: 

module lab2_2_1_partA(
   input[3:0]v,
   output z,
   output [6:0]seg0,
   output [7:0]an
   );
   wire [3:0] m;
   wire [3:0]a_out;
   
   comparator C1(v, z);
   BCD circuit_A(v, a_out);
   
   mux_2to1 m0(a_out[0], v[0], z, m[0]);
   mux_2to1 m1(a_out[1], v[1], z, m[1]);
   mux_2to1 m2(a_out[2], v[2], z, m[2]);
   mux_2to1 m3(0, v[3], z, m[3]);
   
   bcdto7segment bcd7seg(m, seg0, an);
    
endmodule

//derives MSB of 2 digit BCD
module comparator(input [3:0]a, output b);
    assign b = a[3] & (a[2] | a[1]);
    
endmodule

//derives LSB of 2 digit BCD
module BCD(input [3:0]a, output [3:0] b);

    assign b[0] = a[0];
    assign b[1] = a[3]?(~a[1]):(a[1]);
    assign b[2] = a[3]?(a[1]&a[2]):(a[2]);

endmodule

//2 in 1 out multiplexer
module mux_2to1(X,Y,s,z);
    input X, Y;
    input s;
    output z;
    
    assign z = (X&s) | (!s&Y);
    
endmodule


//Converts BCD to seven segment display output
module bcdto7segment(input[3:0] a, output reg [6:0] seg, output [7:0]an);
    always@(a) begin
        seg = 7'b1111111;
        case(a) 
            4'b0000: seg = 7'b0000001;
            4'b0001: seg = 7'b1001111;
            4'b0010: seg = 7'b0010010;
            4'b0011: seg = 7'b0000110;
            4'b0100: seg = 7'b1001100;
            4'b0101: seg = 7'b0100100;
            4'b0110: seg = 7'b0100000;
            4'b0111: seg = 7'b0001111;
            4'b1000: seg = 7'b0000000;
            4'b1001: seg = 7'b0000100;
            default: seg = 7'b0000001;
     
        endcase
    end
    assign an = 8'b11111110;
endmodule



part 2-2-2: 

module Lab2_2_2_2(
    input [3:0] x,
    output reg[4:0] y
    );
                                 
    always@(x) begin
        case(x)
            4'b0000 : y = 5'b01100;
            4'b0001 : y = 5'b11000;
            4'b0010 : y = 5'b10100;
            4'b0011 : y = 5'b10010;
            4'b0100 : y = 5'b01010;
            4'b0101 : y = 5'b00110;
            4'b0110 : y = 5'b10001;
            4'b0111 : y = 5'b01001;
            4'b1000 : y = 5'b00101;
            4'b1001 : y = 5'b00011;
            default: y = 5'b00000;
       endcase
   end
endmodule



part 3-1-1:

module decoder_3to8_dataflow(
    input [2:0] x,
    output reg [7:0] y
    );

    always@(x) begin
        case(x)
            3'b000 : y = 8'b00000001;
            3'b001 : y = 8'b00000010;
            3'b010 : y = 8'b00000100;
            3'b011 : y = 8'b00001000;                  
            3'b100 : y = 8'b00010000;
            3'b101 : y = 8'b00100000;
            3'b110 : y = 8'b01000000;
            3'b111 : y = 8'b10000000;
       endcase;
    end                
    
endmodule



part 3-2-1: 

module Lab3_2_1(

    input [7:0] x,
    input en_in_n,
    output reg[2:0] y,
    output reg en_out,
    output reg gs
    );

           
     always@(x or en_in_n) begin
        case(en_in_n)
            1 : begin y = 3'b111; gs = 0; en_out = 1; end
            0 :
            begin
            casex(x)
                8'b11111111: begin y = 3'b111; gs = 1; en_out = 0; end
                8'bxxxxxxx0: begin y = 3'b000; gs = 0; en_out = 1; end
                8'bxxxxxx01: begin y = 3'b001; gs = 0; en_out = 1; end
                8'bxxxxx011: begin y = 3'b010; gs = 0; en_out = 1; end
                8'bxxxx0111: begin y = 3'b011; gs = 0; en_out = 1; end
                8'bxxx01111: begin y = 3'b100; gs = 0; en_out = 1; end
                8'bxx011111: begin y = 3'b101; gs = 0; en_out = 1; end
                8'bx0111111: begin y = 3'b110; gs = 0; en_out = 1; end
                8'b01111111: begin y = 3'b111; gs = 0; en_out = 1; end
            
            endcase  
            end         
        endcase
    end
endmodule          
        

