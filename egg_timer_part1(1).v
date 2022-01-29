`timescale 1ns / 1ps

//MAIN egg timer module
module egg_timer(input clk_in,
                input reset,
                output locked,
                output reg enable_LED,
                output reg start_LED,
//                output reg cook_LED,
                input enable,
                input [3:0] state_input,
//                input increment_sec,
//                input increment_min,
                output [6:0]seg0,
                output reg [7:0]an,
                output reg [2:0]LED
    );
      wire [3:0] m;
      wire clk_out;
      reg sec_clk, min_clk, fin_clk;
      wire[11:0] q; // 4 digit BCD for MM:SS time
      
      wire[1:0] thresh; //counter thresold outputs
      reg count_reset1, count_reset2;
      reg count_enable_m;


//IP INSTANTIATION
//5MHz clock signal
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

 //minute counter
down_count min (
      .CLK(sec_clk),          // input wire CLK
      .CE(count_enable_m),            // input wire CE
      .SCLR(count_reset2),        // input wire SSET
      .THRESH0(thresh[1]),  // output wire THRESH0
      .Q(q[11:6])              
   );


//INPUT DEBOUNCING
wire [3:0] db_state_input;

reg db_clk;
reg[3:0] Q0, Q1, Q2;
reg[24:0] db_counter;
parameter db_DIV = 7'd5;
//debounce cook_time and start_timer
always @ (posedge clk_out) begin
   Q0[1:0] <= state_input[1:0];
   Q1[1:0] <= Q0[1:0];
   Q2[1:0] <= Q1[1:0];
end
//debounce increment buttons
always @(posedge clk_in) begin
   db_counter <= db_counter + 1;
   if(db_counter >=(db_DIV -1)) db_counter <= 0;
   db_clk <= (db_counter > db_DIV / 2)?1:0;
end
always @ (posedge db_clk) begin
   Q0[3:2] <= state_input[3:2];
   Q1[3:2] <= Q0[3:2];
   Q2[3:2] <= Q1[3:2];
end

assign db_state_input = Q1 & ~Q2;
  
//counters for clock division
reg[27:0] sec_count = 28'd0;
reg[27:0] min_count = 28'd0;
reg[27:0] seg_cycle =28'd0;
reg[27:0] fin_cycle = 28'd0;
   
parameter seg_DIV = 28'd10000; //50Hz
parameter DIV = 28'd5000000; //1Hz
reg[3:0] temp = 4'b0000;//seven segment display variable

reg[5:0] time_set_m, time_set_s, time_set_m_prev, time_set_s_prev, temp_time_m, temp_time_s; // timing variables

//convert binary clock outputs to BCD
wire[7:0]sec_bcd_subt, min_bcd_subt, sec_bcd, min_bcd;

reg[1:0] state, nxtst;
parameter S00 = 0, S01 = 1, S10 = 2, S11 = 3;

bintobcd bin_converter3((state==S10)?time_set_s:(temp_time_s-q[5:0]), sec_bcd);
bintobcd bin_converter4((state==S10)?time_set_m:(temp_time_m-q[11:6]), min_bcd);

bcdto7segment bcd7seg(temp, seg0); 
       //STATE MACHINE BLOCK
      always@(state or db_state_input) begin
      
            case(state)          
            S00 : begin // No start state
                      LED = 4'b0001;
                      case(db_state_input)
                          2'b00 : nxtst = S00; //stay on no input
                          2'b01 : nxtst = S01; //go to start state
                          2'b10 : nxtst = S10; //go to cook_time state
                          default : nxtst = S00;
                      endcase
                  end
            S01 : begin //Counting state
                      LED = 4'b0010;
                      case(db_state_input)
                          2'b00 : nxtst = S01;
                          2'b01 : nxtst = S00;
                          2'b10 : nxtst = S10;
                          default : nxtst = S01;
                      endcase
                      //if clock reaches 00 00, go to finish state
                      if(~|sec_bcd && ~|min_bcd) nxtst = S11;

                  end
            S10 : begin //cooktime state
                      LED = 4'b0100;
                       case(db_state_input)
                           2'b00 : nxtst = S10;
                           2'b01 : nxtst = S01;
                           2'b10 : nxtst = S00;
                           default : nxtst = S10;
                       endcase

                      if(db_state_input[2]) begin
                          time_set_s = time_set_s_prev + 1; //add to seconds
                         
                      end
                      if(db_state_input[3]) begin
                          time_set_m = time_set_m_prev + 1; //add to minutes
                          
                      end
                      
                  end
            S11: begin //finish state
                    LED = 4'b1000;
                    case(db_state_input)
                          2'b00 : nxtst = S11;
                          2'b01 : nxtst = S00;
                          2'b10 : nxtst = S10;
                          default : nxtst = S11;
                    endcase
                 end
            default: nxtst = S00;
            endcase

     
      end
     
    //MAIN CONTROL BLOCK
    always @ (posedge clk_out or posedge reset) begin 
            seg_cycle <= (seg_cycle >=(seg_DIV -1))?0:seg_cycle + 28'd1;
            fin_cycle <= (fin_cycle >= (DIV) -1)?0:fin_cycle + 28'd1;
            fin_clk <= (fin_cycle < DIV/2)?1:0;
            
            if(reset) begin
                state <= S00;
                
                sec_clk <= 0;
                min_count <= 0;
                sec_count <= 0;
                seg_cycle <= 0;
                count_reset1 <= 1;
                count_reset2 <= 1;
                enable_LED <= 0;

                temp_time_s <= time_set_s;
                temp_time_m <= time_set_m;

            end    
            else if (enable) begin  
               state <= nxtst;
               start_LED <= 0;
               enable_LED <= 1;
               if (state == S01) begin
                    count_reset1 <= 0;
                    count_reset2 <= 0;
                //timing for 1 second clock
                    sec_count <= (sec_count >= (DIV) -1)?0:sec_count + 28'd1;

                    sec_clk <= (sec_count < DIV/2)?1:0;
                    
                    if(sec_clk && state == S01) start_LED <= 1;
                    count_enable_m <= (~|sec_bcd)?1:0;
                    
                    if(sec_bcd[7:4] == 6) temp_time_s <= temp_time_s - (sec_bcd[3:0]+1);
                    if(min_bcd[7:4] == 6) temp_time_m <= temp_time_m - (sec_bcd[3:0]+1); 
                    
                    count_reset1 <= thresh[0]?1:0;
                    count_reset2 <= thresh[1]?1:0;               
                end 
             else if(~enable) enable_LED <= 0;   
             
             if(state == S10) begin
                temp_time_s <= time_set_s;
                temp_time_m <= time_set_m;
                if(time_set_s_prev != time_set_s) count_reset1 <= 1;
                if(time_set_m_prev != time_set_m) count_reset2 <= 1;
                
                time_set_s_prev <= time_set_s;
                time_set_m_prev <= time_set_m;            
             end
            end
         end
    always @ (seg_cycle)begin
      //seven segment display timing
             
               //cycle between seven segment displays
              if(seg_cycle < seg_DIV / 4) 
                      begin
                         temp = sec_bcd[3:0];
                         an =(state == S11 && fin_clk)?8'b11111111: 8'b11111110;                    
              end
              else if(seg_cycle >= seg_DIV / 4 && seg_cycle < seg_DIV / 2)
                     begin
                         temp = sec_bcd[7:4];
                         an =(state == S11 && fin_clk)?8'b11111111: 8'b11111101;
                  end
              else if(seg_cycle >= seg_DIV / 2 && seg_cycle < (3*seg_DIV / 4))
                     begin
                        temp = min_bcd[3:0];
                        an =(state == S11 && fin_clk)?8'b11111111: 8'b11111011;                  
                  end
              else if(seg_cycle >= (3*seg_DIV / 4))
                      begin                    
                         temp = min_bcd[7:4];
                         an =(state == S11 && fin_clk)?8'b11111111: 8'b11110111;     
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
      
       
