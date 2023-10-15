
module cordic_tb();

//generate clock
reg clk = 1;
always @(clk) begin
    clk <= #5 ~clk;
end

//read from file
reg [31:0] num [0:21];
initial begin
    $readmemh("hex.txt", num);
end

//initialize
reg start;
reg [31:0] x; 
reg [31:0] y; 
initial begin
	x = num[0];
	y = num[1];
	start = 1;
	@(posedge clk);
	@(posedge clk);
	#1;
	start = 0;
end

//do
reg [31:0] ans [0:10];
reg [5:0] flag = 0;
reg [5:0] flag2 = 0;
always @(posedge clk) begin
	if(start == 1)
		start = 0;
	else if(cordic.counter == 28) begin
		flag2 = flag;
		ans[flag2] = cordic.phi;
		x = num[flag2*2+2];
		y = num[flag2*2+3];
		flag = flag + 1;
		start = 1;

		if(flag == 11) begin
			$writememh("verilog_ans.txt", ans);
			$stop;
		end
	end

end




CORDIC cordic(
    .clk(clk),
    .start(start),
    .x(x),
    .y(y) 
);
    
endmodule