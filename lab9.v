`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2021 02:41:58 PM
// Design Name: 
// Module Name: egg_timer
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

module control_module(output reg[11:0] initial_time, output reg start);
      wire increment_sec, increment_min, start_timer;
      
      always@(start_timer || increment_sec || increment_min) begin
        if (start_timer)
            start = ~start;
        if(increment_sec) begin
            start = 0;
            initial_time[5:0] = initial_time[5:0] + 1;
        end
        if(increment_min) begin
            start = 0;
            initial_time[11:6] = initial_time[11:6] + 1;
        end  
      end
endmodule


//MAIN egg timer module
module egg_timer(input clk_in,
                input reset,
                output locked,
                input enable,
                output [6:0]seg0,
                output reg [7:0]an
    );
      wire [3:0] m;
      wire clk_out;
      reg sec_clk, min_clk;
      wire[11:0] q; // 4 digit BCD for MM:SS time
      wire[1:0] thresh; //counter thresold outputs
      
      wire[11:0] time_set = 12'b111011111011; // initial timer value, set manually 
      wire start_toggle;
      reg count_reset1, count_reset2;
//      control_module control(.initial_time(time_set), .start(start_toggle));
      
       
clk_5MHz clk1
   (
    // Clock out ports
    .clk_out1(clk_out),     // output clk_out1
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_in));      // input clk_in1

//seconds counter
down_count sec (
      .CLK(sec_clk),          // input wire CLK
      .CE(enable),            // input wire CE
      .SCLR(count_reset1),            // input wire SSET
      .THRESH0(thresh[0]),  // output wire THRESH0
      .Q(q[5:0])            
    );
//ten second counter

 //minute counter
down_count min (
      .CLK(min_clk),          // input wire CLK
      .CE(enable),            // input wire CE
      .SCLR(count_reset2),        // input wire SSET
      .THRESH0(thresh[1]),  // output wire THRESH0
      .Q(q[11:6])              
   );
   
   
reg[27:0] sec_count = 28'd0;
reg[27:0] min_count = 28'd0;
reg[27:0] seg_cycle =28'd0;
    

parameter seg_DIV = 28'd10000; //50Hz
parameter DIV = 28'd500000; //1Hz
reg[3:0] temp = 4'b0000;//seven segment display variable

//convert binary clock outputs to BCD
wire[7:0]sec_bcd_subt, min_bcd_subt, sec_bcd, min_bcd;
bintobcd bin_converter1(q[5:0], sec_bcd_subt);
bintobcd bin_converter2(q[11:6], min_bcd_subt);
bintobcd bin_converter3(time_set[5:0], sec_bcd);
bintobcd bin_converter4(time_set[11:6], min_bcd);

bcdto7segment bcd7seg(temp, seg0); 
    
             
    always @ (posedge clk_out or posedge reset) begin
            seg_cycle <= seg_cycle + 28'd1;
                if (seg_cycle >=(seg_DIV -1)) begin
                    seg_cycle <= 28'd0;
                end
            if(reset) begin
                sec_clk <= 0;
                min_count <= 0;
                sec_count <= 0;
                seg_cycle <= 0;
            end    
            else if (enable) begin  
                //timing clocks for 1 second and 1 minute clocks
                sec_count <= sec_count + 28'd1;
                min_count <= min_count + 28'd1;
          
                //reset counter if it is greate than DIV
                if (sec_count >= (DIV)-1)
                     sec_count <= 28'd0;
                if(min_count >= ((60*DIV))-1)
                     min_count <= 28'd0;
                     
                sec_clk <= (sec_count < DIV/2)?1:0;
                min_clk <= (min_count < (60*DIV)/2)?1:0;
                
                count_reset1 <= thresh[0]?1:0;
                count_reset2 <= thresh[1]?1:0;
            end 
         end
    always @ (seg_cycle)begin
      //seven segment display timing
              
               //cycle between seven segment displays
              if(seg_cycle < seg_DIV / 4) 
                      begin
                         temp = sec_bcd[3:0] - sec_bcd_subt[3:0];
//                         temp = sec_bcd_subt[3:0];
                         an = 8'b11111110;                    
              end
              else if(seg_cycle >= seg_DIV / 4 && seg_cycle < seg_DIV / 2)
                     begin
                         temp = sec_bcd[7:4] - sec_bcd_subt[7:4];
//                         temp = sec_bcd_subt[7:4];
                         an = 8'b11111101;                 
                  end
              else if(seg_cycle >= seg_DIV / 2 && seg_cycle < (3*seg_DIV / 4))
                     begin
                        temp = min_bcd[3:0] - min_bcd_subt[3:0];
//                        temp = min_bcd_subt[3:0];
                        an = 8'b11111011;                  
                  end
              else if(seg_cycle >= (3*seg_DIV / 4))
                      begin
                         temp = min_bcd[7:4] - min_bcd_subt[7:4];
//                         temp = min_bcd_subt[7:4];
                         an = 8'b11110111;       
                  end
                          
      end    
      endmodule
      
      
      //double dabble algorithm to convert binary to bcd
      module bintobcd(input[5:0] a, output reg[7:0] b);
      integer i;
      always@(a) begin
            b = 8'b0;
            for(i = 0; i<6; i=i+1) begin
                if (b[3:0]>= 3'b101) 
                    b[3:0] = b[3:0] + 3;
                else if(b[7:4]>= 3'b101)
                    b[7:4] = b[7:4] + 3;
                b = b<<1;
                b[0] = a[5-i];
            end
        end
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

       
       
