

module mul #(parameter M=8,parameter N=16,parameter logN=4)
(
	input wire clk,
	input wire valid,
	input wire [M*N-1:0]u,
	output reg ready,
	output reg [N*(M+logN)-1:0]y
);


///assign hamadard matrix
wire signed [0:15]hamadard[15:0];
assign hamadard[0]  = 16'b1111111111111111;
assign hamadard[1]  = 16'b1010101010101010;
assign hamadard[2]  = 16'b1100110011001100;
assign hamadard[3]  = 16'b1001100110011001;
assign hamadard[4]  = 16'b1111000011110000;
assign hamadard[5]  = 16'b1010010110100101;
assign hamadard[6]  = 16'b1100001111000011;
assign hamadard[7]  = 16'b1001011010010110;
assign hamadard[8]  = 16'b1111111100000000;
assign hamadard[9]  = 16'b1010101001010101;
assign hamadard[10] = 16'b1100110000110011;
assign hamadard[11] = 16'b1001100101100110;
assign hamadard[12] = 16'b1111000000001111;
assign hamadard[13] = 16'b1010010101011010;
assign hamadard[14] = 16'b1100001100111100;
assign hamadard[15] = 16'b1001011001101001;

//////
reg [2:0] counter;
reg signed [M-1:0] a,b;

wire signed [M+logN-1:0] plusPlus;
wire signed [M+logN-1:0] plusMinus;
wire signed [M+logN-1:0] minusPlus;
wire signed [M+logN-1:0] minusMinus;


////////
assign plusPlus = a + b;
assign plusMinus = a - b;
assign minusPlus = ~plusMinus + 1;
assign minusMinus = ~plusPlus + 1;


/////
always@(*) begin
	case(counter)
		0: begin a = u[M-1:0]      ;  b = u[2*M-1:M]    ; end
		1: begin a = u[3*M-1:2*M]  ;  b = u[4*M-1:3*M]  ; end
		2: begin a = u[5*M-1:4*M]  ;  b = u[6*M-1:5*M]  ; end
		3: begin a = u[7*M-1:6*M]  ;  b = u[8*M-1:7*M]  ; end
		4: begin a = u[9*M-1:8*M]  ;  b = u[10*M-1:9*M] ; end
		5: begin a = u[11*M-1:10*M];  b = u[12*M-1:11*M]; end
		6: begin a = u[13*M-1:12*M];  b = u[14*M-1:13*M]; end
		7: begin a = u[15*M-1:14*M];  b = u[16*M-1:15*M]; end
	endcase
end

always@(posedge clk) begin
	if(valid)begin
		counter <= 0;
		ready <= 0;
	end
	else if(counter+1 == N/2)
		ready <= 1;
	else
		counter <= counter + 1;
end

genvar k;
generate 
	for (k = 0; k < N; k=k+1) begin
		always@(posedge clk) begin
			if(valid)
				y[(k+1)*(M+logN+1)-1:k*(M+logN+1)] <= 0;
			else if(!ready)
				y[(k+1)*(M+logN)-1:k*(M+logN)] <= (y[(k+1)*(M+logN)-1:k*(M+logN)] + (hamadard[2*counter][k] ? hamadard[2*counter+1][k]?plusPlus:plusMinus : hamadard[2*counter+1][k]?minusPlus:minusMinus));
		end
	end
endgenerate



endmodule