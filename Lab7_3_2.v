`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 08:01:11 PM
// Design Name: 
// Module Name: lab7_3_2
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


module lab7_3_2(input clk_in,
                input enable,
                input reload,
                input reset,
                input[1:0] min_input,
                output locked,
                output [6:0]seg0,
                output reg [7:0]an
    );
    wire clk_out;
    reg sec_clk, min_clk;
    wire[5:0] sec_input = 6'd0; 
    wire[1:0] thresh;
//    reg[11:0] time_set;
    wire[11:0] q;
    
    reg count_enable_m, reload_m, manual_thresh;
      clk_5MHz clk_gen
       (
        // Clock out ports
        .clk_out1(clk_out),     // output clk_out1
        // Status and control signals
        .reset(reset), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_in));      // input clk_in1
        
        
    c_counter_binary_0 counter_s (
      .CLK(sec_clk),          // input wire CLK
      .CE(enable),            // input wire CE
      .SSET(thresh[0]),        // input wire SSET
      .LOAD(reload_m),        // input wire LOAD
      .L(sec_input),              // input wire [5 : 0] L
      .THRESH0(thresh[0]),  // output wire THRESH0
      .Q(q[5:0])              // output wire [5 : 0] Q
    );
    
    c_counter_binary_0 counter_m (
          .CLK(sec_clk),          // input wire CLK
          .CE(count_enable_m),            // input wire CE
          .SSET(reset),        // input wire SSET
          .LOAD(reload_m),        // input wire LOAD
          .L({4'd0, min_input}), // input wire [5 : 0] L
          .THRESH0(thresh[1]),  // output wire THRESH0
          .Q(q[11:6])              // output wire [5 : 0] Q
        );
    
    reg[27:0] seg_cycle = 28'd0;
    parameter seg_DIV = 28'd10000;
    reg[27:0] sec_count;
    reg[27:0] min_count;
    parameter DIV = 28'd5000000; //1Hz
    
    wire[7:0] sec_bcd, min_bcd;
    bintobcd bin_converter1(q[5:0] - 3'd4, sec_bcd);
    bintobcd bin_converter2(q[11:6], min_bcd);
    reg[3:0] temp;
    
    bcdto7segment seg_disp(temp, seg0);
    always@(posedge clk_out or posedge reload) begin
        seg_cycle <= (seg_cycle >=(seg_DIV -1))?0:seg_cycle + 28'd1;
        if (reload) begin
            count_enable_m <= 1;

            reload_m <= 1;
            
        end
        else if(enable) begin
            if(q[5:0] <= 3'd4)manual_thresh <= 1;
            else manual_thresh <= 0;
            
            sec_count <= (sec_count >= (DIV) -1)?0:sec_count + 28'd1;
            min_count <= (min_count >= ((60*DIV)-1))?0:min_count + 28'd1;
            sec_clk <= (sec_count < DIV/2)?1:0;
            min_clk <= (min_count < (60*DIV)/2)?1:0;
            if(sec_clk)begin
            #5;
                count_enable_m <= 0;
                reload_m <= 0;
            end
            if(manual_thresh) count_enable_m <= 1;
            else count_enable_m <= 0;
        end
    end
    
    always @ (seg_cycle)begin
          //seven segment display timing
                  
                   //cycle between seven segment displays
                  if(seg_cycle < seg_DIV / 4) 
                          begin
    //                      temp = sec_bcd[3:0] - sec_bcd_subt[3:0];
    //                      if(state == S10) temp = sec_bcd[3:0];
                             temp = sec_bcd[3:0];
                             an = 8'b11111110;                    
                  end
                  else if(seg_cycle >= seg_DIV / 4 && seg_cycle < seg_DIV / 2)
                         begin
    //                          temp = sec_bcd[7:4] - sec_bcd_subt[7:4];
    //                          if(state == S10) temp = sec_bcd[7:4];
                             temp = (sec_bcd[7:4] == 3'd6)?4'b0:sec_bcd[7:4];
                             an = 8'b11111101;
                      end
                  else if(seg_cycle >= seg_DIV / 2 && seg_cycle < (3*seg_DIV / 4))
                         begin
    //                         temp = min_bcd[3:0] - min_bcd_subt[3:0];
    //                         if(state == S10) temp = min_bcd[3:0];
                            temp = min_bcd[3:0];
                            an = 8'b11111011;                  
                      end
                  else if(seg_cycle >= (3*seg_DIV / 4))
                          begin
    //                      temp = min_bcd[7:4] - min_bcd_subt[7:4];
    //                      if(state == S10) temp = min_bcd[7:4];                     
                             temp = 4'b0;
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