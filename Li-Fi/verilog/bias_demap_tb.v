`timescale 1ns/100ps

module bias_demap_tb #(parameter M=8,parameter N=16,parameter logN=4);
	reg clk;
	
	integer i, fd, fdd, j;
	integer n = 100;
	integer correct = 1;
	reg [N*(M+logN)-1:0]u;
	reg valid;
	wire ready;
    wire [(N-1)*(M/4)-1:0]y;
	reg  [(N-1)*(M/4)-1:0]out;
	
	
	bias_demap bd(
		.clk(clk),
		.valid(valid),
		.u(u),
		.ready(ready),
		.y(y)
	);
	always begin
		clk = 1'b0;
		#10;
		clk = 1'b1;
		#10;
	end
	
	initial begin

		fd = $fopen("output_mult.mem","r");
		fdd = $fopen("output_pam.mem","r");
		for(i=0;i<100;i=i+1)begin
			$fscanf(fd,"%x\n", u);
			$fscanf(fdd,"%b\n", out);
			// ack
			@(posedge clk);
			valid = 1'b1;
			@(posedge clk);
			valid = 1'b0;
			// wait till ready becomes 1
			while (bd.ready != 1)  
			begin
				@(posedge clk);
			end
			// check fualt and compare to file
			if(bd.y!=out)begin
				$display("%x %x",bd.y,out);
				correct=0;
			end
			@(posedge clk);
		end
		if (correct)
			 $display("All test cases executed correctly!");
		else
			$display("Errors Found!");
		$fclose(fd);
		$fclose(fdd);
		$stop;
	end
	
endmodule

