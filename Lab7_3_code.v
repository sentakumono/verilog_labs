
PART 3_1: 

module lab7_3_1(input clk_in,
                input reset,
                output locked,
                input enable,
                output [6:0]seg0,
                output reg [7:0]an
    );
    wire [3:0] m;
    wire clk_out;
    reg sec_clk, ten_clk, min_clk;
    wire[15:0] q;
    wire[3:0] thresh;
    
    clk_wiz_0 clk_gen(
       // Clock out ports
       .clk_out1(clk_out),     // output clk_out1
       // Status and control signals
       .reset(reset), // input reset
       .locked(locked),       // output locked
      // Clock in ports
       .clk_in1(clk_in));      // input clk_in1

    
    
    bin_count tenths (
      .CLK(sec_clk),          // input wire CLK
      .CE(enable),            // input wire CE
      .SCLR(reset),        // input wire SCLR
      .THRESH0(thresh[0]),  // output wire THRESH0
      .Q(q[3:0])              // output wire [3 : 0] Q
    );
    
    bin_count sec(
    .CLK(sec_clk),
    .CE(thresh[0]),
    .SCLR(reset),
    .THRESH0(thresh[1]),
    .Q(q[7:4])
    );
    
    bin_count_tens tens (
    .CLK(ten_clk),
    .CE(thresh[1]),
    .SCLR(reset),
    .THRESH0(thresh[2]),
    .Q(q[11:8])
    );
        
    bin_count_tens min(
    .CLK(min_clk),
    .CE(thresh[2]),
    .SCLR(reset),
    .THRESH0(thresh[3]),
    .Q(q[15:12])
    );
    
   
 reg[27:0] counter = 28'd0;
 reg[27:0] ten_count = 28'd0;
 reg[27:0] min_count = 28'd0;
 reg[27:0] seg_cycle =28'd0;
 
 
 parameter seg_DIV = 28'd10000;
 parameter DIV = 28'd500000;
 reg[3:0] temp = 4'b0000;
 bcdto7segment bcd7seg(temp, seg0);
 
 always @ (posedge clk_out or posedge reset) begin
       if(reset) begin
              sec_clk <= 0;
              counter <= 0;
              ten_count <= 0;
              seg_cycle <= 0;
         end
         else if (enable) begin  
             counter <= counter + 28'd1;
             ten_count <= ten_count + 28'd1;
             min_count <= min_count + 28'd1;
             seg_cycle <= seg_cycle + 28'd1;
             //reset counter if it is greate than DIV
             if (counter >= (DIV - 1))
                  counter <= 28'd0;
             if(ten_count >= ((10*DIV) - 1))
                  ten_count <= 28'd0;
             if(min_count >= ((60*DIV) - 1))
                  min_count <= 28'd0;
             if (seg_cycle >=(seg_DIV -1))
                  seg_cycle <= 28'd0;
                  
             sec_clk <= (counter < DIV/2)?1:0;
             ten_clk <= (ten_count < (10*DIV)/2)?1:0;
             min_clk <= (min_count < (60*DIV)/2)?1:0;
             
             if(seg_cycle < seg_DIV / 4) 
                 begin
                    temp = q[3:0];
                    an = 8'b11111110;                    
             end
             else if(seg_cycle >= seg_DIV / 4 && seg_cycle < seg_DIV / 2)
                begin
                    temp = q[7:4];
//                    if(thresh[0])
//                        temp = temp - 1'b1;
                    an = 8'b11111101;                 
             end
             else if(seg_cycle >= seg_DIV / 2 && seg_cycle < (3*seg_DIV / 4))
                begin
                   temp = q[11:8];
                   if(thresh[1])
                    temp = temp - 1'b1;
                   an = 8'b11111011;                  
             end
             else if(seg_cycle >= (3*seg_DIV / 4))
                 begin
                    temp = q[15:12];
                    if(thresh[2])
                        temp = temp - 1'b1;
                    an = 8'b11110111;       
             end
                        
//             case(counter[1:0])
//                2'b00: 
//                begin
//                    temp = q[3:0];
//                    an = 8'b11111110;                    
//                end
//                2'b01:
//                begin
//                    temp = q[7:4];
//                    an = 8'b11111101;
                    
//                end
//                2'b10:
//                begin
//                    temp = q[11:8];
//                    an = 8'b11111011;                  
//                end
//                2'b11:
//                begin
//                    temp = q[15:12];
//                    an = 8'b11110111;

//                end
//             endcase
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










PART 3_2: 

module lab7_3_2(input clk_in,
                input reset,
                output locked,
                input enable,
                input[1:0]sset,
                output [6:0]seg0,
                output reg [7:0]an
    );
    wire [3:0] m;
    wire clk_out;
    reg sec_clk, ten_clk, min_clk, tenmin_clk;
    wire[15:0] q;
    wire[3:0] thresh;
    reg[3:0] sset_min;
    
    clk_wiz_0 clk_gen(
       // Clock out ports
       .clk_out1(clk_out),     // output clk_out1
       // Status and control signals
       .reset(reset), // input reset
       .locked(locked),       // output locked
      // Clock in ports
       .clk_in1(clk_in));      // input clk_in1

    
    
    bin_count sec (
      .CLK(sec_clk),          // input wire CLK
      .CE(thresh[2]),            // input wire CE
      .SCLR(reset),        // input wire SCLR
      .THRESH0(thresh[3]),  // output wire THRESH0
      .SSET(),
      .Q(q[3:0])              // output wire [3 : 0] Q
    );
    
    bin_count tens(
    .CLK(ten_clk),
    .CE(thresh[1]),
    .SCLR(reset),
    .THRESH0(thresh[2]),
    .SSET(),
    .Q(q[7:4])
    );
    
    bin_count min(
    .CLK(min_clk),
    .CE(thresh[0]),
    .SCLR(reset),
    .THRESH0(thresh[1]),
    .SSET(sset_min[1:0]),
    .Q(q[11:8])
    );
        
    bin_count tenmin(
    .CLK(min_clk),
    .CE(enable),
    .SCLR(reset),
    .THRESH0(thresh[0]),
    .SSET(sset_min[3:2]),
    .Q(q[15:12])
    );
    
   
 reg[27:0] counter = 28'd0;
 reg[27:0] ten_count = 28'd0;
 reg[27:0] min_count = 28'd0;
 reg[37:0] tenmin_count = 28'd0;
 reg[27:0] seg_cycle =28'd0;
 
 
 parameter seg_DIV = 28'd10000;
 parameter DIV = 28'd500000;
 reg[3:0] temp = 4'b0000;
 bcdto7segment bcd7seg(temp, seg0);
 
 always @ (posedge clk_out or posedge reset) begin
       if(reset) begin
              sec_clk <= 0;
              counter <= 0;
              ten_count <= 0;
              seg_cycle <= 0;
         end
         else if (enable) begin  
             counter <= counter + 28'd1;
             ten_count <= ten_count + 28'd1;
             min_count <= min_count + 28'd1;
             tenmin_count <= tenmin_count + 28'd1;
             seg_cycle <= seg_cycle + 28'd1;
             //reset counter if it is greate than DIV
             if (counter >= (DIV - 1))
                  counter <= 28'd0;
             if(ten_count >= ((10*DIV) - 1))
                  ten_count <= 28'd0;
             if(min_count >= ((60*DIV) - 1))
                  min_count <= 28'd0;
             if(tenmin_count >= ((600*DIV) -1))
                  tenmin_count <= 28'd0;
             if (seg_cycle >=(seg_DIV -1))
                  seg_cycle <= 28'd0;
                  
             sec_clk <= (counter < DIV/2)?1:0;
             ten_clk <= (ten_count < (10*DIV)/2)?1:0;
             min_clk <= (min_count < (60*DIV)/2)?1:0;
             tenmin_clk <= (tenmin_count < (600*DIV)/2)?1:0;
             
             case(sset) 
             2'b00: sset_min = 4'b0000;
             2'b01: sset_min = 4'b0001;
             2'b10: sset_min = 4'b0010;
             2'b11: sset_min = 4'b0011;
             endcase
             
             if(seg_cycle < seg_DIV / 4) 
                 begin
                    temp = q[3:0];
                    an = 8'b11111110;                    
             end
             else if(seg_cycle >= seg_DIV / 4 && seg_cycle < seg_DIV / 2)
                begin
                    temp = q[7:4];
                    if(thresh[0])
                        temp = temp - 1'b1;
                    an = 8'b11111101;                 
             end
             else if(seg_cycle >= seg_DIV / 2 && seg_cycle < (3*seg_DIV / 4))
                begin
                   temp = q[11:8];
                   if(thresh[1])
                    temp = temp - 1'b1;
                   an = 8'b11111011;                  
             end
             else if(seg_cycle >= (3*seg_DIV / 4))
                 begin
                    temp = q[15:12];
                    if(thresh[2])
                        temp = temp - 1'b1;
                    an = 8'b11110111;       
             end
                        
//             case(counter[1:0])
//                2'b00: 
//                begin
//                    temp = q[3:0];
//                    an = 8'b11111110;                    
//                end
//                2'b01:
//                begin
//                    temp = q[7:4];
//                    an = 8'b11111101;
                    
//                end
//                2'b10:
//                begin
//                    temp = q[11:8];
//                    an = 8'b11111011;                  
//                end
//                2'b11:
//                begin
//                    temp = q[15:12];
//                    an = 8'b11110111;

//                end
//             endcase
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



