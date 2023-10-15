module plot
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		RX
	);

	input			CLOCK_50;				//	50 MHz
	input	[0:0]	KEY;					//	Button[3:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	input 			RX;

	wire resetn;
	assign resetn = KEY[0];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.
	wire [5:0] color;
	wire [5:0] newcolor;
	wire writeEn, plotinput, plotoutput;
    wire [8:0] x;
	wire [7:0] y;
    wire [8:0] xinput;
	wire [7:0] yinput;
    wire [8:0] xoutput;
	wire [7:0] youtput;
	wire [6:0] x0;
	wire [6:0] y0;

    assign xinput = 5;
    assign yinput = 10;
    assign xoutput = 85;
    assign youtput = 10;

	assign x = plotinput ? x0+xinput : x0+xoutput;
	assign y = plotinput ? y0+yinput : y0+youtput;

    assign writeEn = plotinput | plotoutput; 

	FSM fSM (
    	.clk(CLOCK_50),
		.reset(resetn),

		.RX(RX),

        .newcolor(newcolor),
		.colorOut(color),

		.x0(x0),
		.y0(y0),

		.plotinput(plotinput),
		.plotoutput(plotoutput)
	);
	
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(plot_input ? color : newcolor),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK)
		);
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "background";

endmodule


module FSM (

	inout wire clk,
	input  wire reset,

	input  wire RX,

	inout wire [5:0] newcolor,
	output wire [5:0] colorOut,

	output reg [6:0] x0,
	output reg [6:0] y0,

	output reg plotinput,
	output reg plotoutput

);
    wire valid;
	wire [7:0] data;

	reg [5:0] x1, x2, x3, x4, x5, x6, x7, x8, x9;
	reg [3:0] counter;

//////////////////////////////////////////////
	assign colorOut = x5;


///////////////////////////////////////////////
	always @(posedge clk) begin

		if (reset == 0) begin
			x0 <= 0;
			y0 <= 0;
			counter <= 0;
			plotinput <= 0;
			plotoutput <= 0;
		end

		else begin

			plotinput <= 0;
			plotoutput <= 0;

            if(counter == 9)begin
                counter <= 10;
                plotoutput <= 1;
            end
            if(counter == 10)begin
                counter <= 0;

                if(x0 == 69)begin
	                x0 <= 0;
                    if(y0 == 99)
                        y0 <= 0;
                    else 
                        y0 <= y0 + 1;
                end
                else
                    x0 <= x0 + 1;
                    
            end
            if(valid) begin

                counter <= counter + 1;

				if(x0 == 0)begin
					x1 <= 0;
					x4 <= 0;
					x7 <= 0;

					if(counter == 0)
                    	x2[5:2] <= data[7:4];
                	else if(counter == 1) begin
                    	x2[1:0] <= data[7:6];
                    	x3[5:4] <= data[5:4];
                	end
                	else if(counter == 2) 
                    	x3[3:0] <= data[7:4];

                	else if(counter == 3)
                    	x5[5:2] <= data[7:4];
                	else if(counter == 4) begin
                    	x5[1:0] <= data[7:6];
                    	x6[5:4] <= data[5:4];
                	end
                	else if(counter == 5) 
                    	x6[3:0] <= data[7:4];

					else if(counter == 6)
                    	x8[5:2] <= data[7:4];
                	else if(counter == 7) begin
                    	x8[1:0] <= data[7:6];
                    	x9[5:4] <= data[5:4];

						plotinput <= 1;
                	end
                	else if(counter == 8) 
                    	x9[3:0] <= data[7:4];
        
				end
				else begin

					if(counter == 0) begin
                    	x3[5:2] <= data[7:4];
						x1 <= x2;
						x4 <= x5;
						x7 <= x8;
						x2 <= x3;
						x5 <= x6;
						x8 <= x9;
					end
                	else if(counter == 1) begin
                    	x3[1:0] <= data[7:6];
                    	x6[5:4] <= data[5:4];
                    
                   		plotinput <= 1;
                	end
                	else if(counter == 2) begin
                    	x6[3:0] <= data[7:4];
                	end

                	else if(counter == 3)
                    	x9[5:2] <= data[7:4];
                	else if(counter == 4) begin
                    	x9[1:0] <= data[7:6];
						counter <= 9;
                	end
				end  


            end
        end
	end


UART_Receiver uart
(
	.clk(clk),
	.reset(reset),
	.RX(RX),
	.data(data),
	.valid(valid)
);

sobel sob
(	
	.out(newcolor),
	
	.in1(x1),
	.in2(x2),
	.in3(x3),
	.in4(x4),
	.in5(x5),
	.in6(x6),
	.in7(x7),
	.in8(x8),
	.in9(x9)
);

endmodule


module UART_Receiver(
	input wire clk,
	input wire reset,
	input wire RX,
	output reg [7:0] data, 
	output reg valid
);

wire crc;
reg state = 0;
reg [2:0] i;
reg [9:0] counter; //determines Transmitting Rate ( in this code : 115200)

always @(posedge clk)begin

	valid <= 0;

    if(reset == 0)begin
        state <= 0;
    end
	
    else begin
	    if(!RX && !state) begin
		    state <= 1;
            counter <= 0;
            i <= 0;
		    valid <= 0;
        end

	    if(state)begin

		    counter <= counter + 1;
		
		    if(counter == 634 && i == 0)begin
			    i <= i + 1 ;
			    data [i] <= RX;
			    counter <= 0;
		    end
		    else if(counter == 434 && i != 0)begin
			    i <= i + 1 ;
				if(i != 8)
			    	data [i] <= RX;
			    counter <= 0;
			    if( i == 7)begin
				    valid <= crc;
			    end
				else if( i == 8)begin
				    state <= 0;
				    i <= 0;
			    end
			
		    end
		
	    end
    end

end

crc_check check(
	.in({RX, data[6:0]}),
	.out(crc)
);

endmodule

module crc_check(
	input wire [7:0] in,
	output wire out
	);
	
	//polynomial = x^4 + x + 1
	
	parameter poly = 5'b10011;
	parameter zero = 5'b00000;
	
	
	wire [4:0] r1, r2, r3, r4, m1, m2, m3;
	
	
	
	assign r1 = (in[7]) ? (in[7:3] ^ poly) : in[7:3];
	assign m1 = {r1[3:0], in[2]};
	
	assign r2 = (m1[4]) ? (m1 ^ poly) : m1;
	assign m2 = {r2[3:0], in[1]};
	
	assign r3 = (m2[4]) ? (m2 ^ poly) : m2;
	assign m3 = {r3[3:0], in[0]};
	
	assign r4 = (m3[4]) ? (m3 ^ poly) : m3;
	
	assign out = (r4 == 0) ? 1 : 0;
	
endmodule



module sobel(
	input wire [5:0] in1,
	input wire [5:0] in2,
	input wire [5:0] in3,
	input wire [5:0] in4,
	input wire [5:0] in5,
	input wire [5:0] in6,
	input wire [5:0] in7,
	input wire [5:0] in8,
	input wire [5:0] in9,

	output wire out
	);
	
	//parameter width = 100;
	//parameter height = 100;
	parameter threshold = 12;
	
	//reg sobeled [0:height - 1][0:width - 1];
	reg [6:0] counterCol, counterRow;
	
	
	wire [3:0] g [1:9];
	//reg process;
	
	
	//gray-scaling
	assign g[1] = {2'h0,in1[5:4]} + {2'h0,in1[3:2]} + {2'h0,in1[1:0]} + {2'h0,in1[1:0]}; //r+b+2*g
	assign g[2] = {2'h0,in2[5:4]} + {2'h0,in2[3:2]} + {2'h0,in2[1:0]} + {2'h0,in2[1:0]};
	assign g[3] = {2'h0,in3[5:4]} + {2'h0,in3[3:2]} + {2'h0,in3[1:0]} + {2'h0,in3[1:0]};
	assign g[4] = {2'h0,in4[5:4]} + {2'h0,in4[3:2]} + {2'h0,in4[1:0]} + {2'h0,in4[1:0]};
	assign g[5] = {2'h0,in5[5:4]} + {2'h0,in5[3:2]} + {2'h0,in5[1:0]} + {2'h0,in5[1:0]};
	assign g[6] = {2'h0,in6[5:4]} + {2'h0,in6[3:2]} + {2'h0,in6[1:0]} + {2'h0,in6[1:0]};
	assign g[7] = {2'h0,in7[5:4]} + {2'h0,in7[3:2]} + {2'h0,in7[1:0]} + {2'h0,in7[1:0]};
	assign g[8] = {2'h0,in8[5:4]} + {2'h0,in8[3:2]} + {2'h0,in8[1:0]} + {2'h0,in8[1:0]};
	assign g[9] = {2'h0,in9[5:4]} + {2'h0,in9[3:2]} + {2'h0,in9[1:0]} + {2'h0,in9[1:0]};
	
	
	integer i,j;
	wire [7:0] Gx, Gy, Gx_abs, Gy_abs, Total;
	
	//Gx=((2*g8+g7+g9)-(2*g2+g1+g3));
	assign Gx = ((2 * g[8] + g[7] + g[9]) - (2 * g[2] + g[1] + g[3]));
	//Gy=((2*g6+g3+g9)-(2*g4+g1+g7));
	assign Gy = ((2 * g[6] + g[3] + g[9]) - (2 * g[4] + g[1] + g[7]));
	
	assign Gx_abs = (Gx[7]) ? -Gx : Gx;
	assign Gy_abs = (Gy[7]) ? -Gy : Gy;
	assign Total = Gx_abs + Gy_abs;
	
	
	assign out = (Total > threshold) ? 1 : 0;
	
endmodule


	
