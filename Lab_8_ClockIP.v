8.1.1 :
module lab8_1_1(input clk_in,
                output reg q, 
                output locked,
                input reset, 
                input enable);

wire clk_out;
clk_5MHz clock_gen
    (
      // Clock out ports
      .clk_out1(clk_out),     // output clk_out1
      // Status and control signals
      .reset(reset), // input reset
      .locked(locked),       // output locked
     // Clock in ports
      .clk_in1(clk_in));      // input clk_in1

reg[27:0] counter = 28'd0;
parameter DIV = 28'd50000000;      
always @ (posedge clk_out or posedge reset) begin
   if(reset) begin
        q <= 0;
   end
   else if (enable) begin  
       counter <= counter + 28'd1;
       if (counter >= (DIV - 1))
            counter <= 28'd0;
       q <= (counter < DIV/2)?1:0;
   end    
end
endmodule




8.1.2 :
module lab8_1_2(

    );
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2021 08:07:17 PM
// Design Name: 
// Module Name: lab2_2_1_partA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab2_2_1_partA(
   input[3:0]v,
   input clk_in,
   input reset,
   output locked,
   input enable,
   output z,
   output [6:0]seg0,
   output reg [7:0]an
   );
   wire clk_out;
   wire [3:0] m;
   wire [3:0]a_out;
   
   clk_5MHz clock_gen
       (
         // Clock out ports
         .clk_out1(clk_out),     // output clk_out1
         // Status and control signals
         .reset(reset), // input reset
         .locked(locked),       // output locked
        // Clock in ports
         .clk_in1(clk_in));      // input clk_in1

   comparator C1(v, z);
   BCD circuit_A(v, a_out);
   
   mux_2to1 m0(a_out[0], v[0], z, m[0]);
   mux_2to1 m1(a_out[1], v[1], z, m[1]);
   mux_2to1 m2(a_out[2], v[2], z, m[2]);
   mux_2to1 m3(0, v[3], z, m[3]);
   
 
   
   
   reg[27:0] counter = 28'd0;
   parameter DIV = 28'd10000;
   reg q;  
   reg[3:0] temp = 4'b0000;
   bcdto7segment bcd7seg(temp, seg0);
   always @ (posedge clk_out or posedge reset) begin
      if(reset) begin
           q <= 0;
      end
      else if (enable) begin  
          counter <= counter + 28'd1;
          if (counter >= (DIV - 1))
               counter <= 28'd0;
          q <= (counter < DIV/2)?1:0;
          
          if(q)begin
               an = 8'b11111110;
               temp = m;
          end
          else begin
               an = 8'b11111101;
               temp = 3'b0;
               temp[3] = z;
          end
      end    
    
   end
    
   
    
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
module bcdto7segment(input[3:0] a, output reg [6:0] seg);
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
  
endmodule




