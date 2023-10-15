module bias_demap #(parameter M=8,parameter N=16,parameter logN=4)
(
	input wire clk,
	input wire valid,
	input wire [N*(M+logN)-1:0]u,
	output reg ready,
	output reg [M/4*(N-1)-1:0]y
);

wire signed [(M+logN)-1:0] psum;
assign psum = 0 | (1 << (logN-1));
reg signed [(M+logN):0]ad[N-1:0];
reg signed [12:0]test;
always@(posedge clk) begin
			if(valid)
				test <= psum + u[(M+logN)-1:0];
			else
				test <= 0;
		end
reg signed [12:0]testt;
always@(posedge clk) begin
			if(valid)
				testt <= psum + u[2*(M+logN)-1:(M+logN)];
			else
				testt <= 0;
		end
genvar k;
generate 
	for (k = 0; k < N; k=k+1) begin
		always@(posedge clk) begin
			if(valid)
				ad[k] <= psum + u[(k+1)*(M+logN)-1:k*(M+logN)];
			else
				ad[k] <= 0;
		end
	end
endgenerate

///assign hamadard matrix
wire [0:2]pamthreshhold[2:0];
assign pamthreshhold[0]  = 3'b001;
assign pamthreshhold[1]  = 3'b011;
assign pamthreshhold[2]  = 3'b101;


genvar p;
generate 
	for (p = 1; p < N; p=p+1) begin
		always @(*) begin
			if(ad[N-p]<=$signed({1'b0,pamthreshhold[0],3'b000}))begin
				y[p*M/4-1:(p-1)*M/4] <= 2'b00;
			end
			else if (ad[N-p]<=$signed({1'b0,pamthreshhold[1],3'b000})) begin
				y[p*M/4-1:(p-1)*M/4] <= 2'b01;
			end
			else if (ad[N-p]<=$signed({1'b0,pamthreshhold[2],3'b000})) begin
				y[p*M/4-1:(p-1)*M/4] <= 2'b10;
			end
			else begin
				y[p*M/4-1:(p-1)*M/4] <= 2'b11;
			end
			
		end
		
		
	end
endgenerate

reg [1:0] counter;
always@(posedge clk) begin
	if(valid)begin
		counter <= 0;
		ready <= 1;
	end
	// else if(counter[1] == 1)begin
	// 	ready <= 1;
	// 	counter <= counter;
	// end
	else begin
		ready <= 0;
		counter <= counter + 1;
	end
end

endmodule