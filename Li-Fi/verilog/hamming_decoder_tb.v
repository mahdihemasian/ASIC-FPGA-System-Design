`timescale 1ns/100ps

module hamming_decoder_tb;
	reg clk;
	
	integer i, fd, fdd, j;
	integer n = 100;
	integer correct = 1;
	reg valid;
	wire ready;

	reg  [6:0]out;
	wire [3:0] message;
	reg reset;
	wire [6:0] codeword;
	
	hamming_decoder hd(
		.clk(clk),
		.valid(valid),
		.reset(reset),
		.codeword(codeword),
		.ready(ready),
		.message(message)
	);
	always begin
		clk = 1'b0;
		#10;
		clk = 1'b1;
		#10;
	end
	
	initial begin

		@(posedge clk);
		reset = 1'b0;
		@(posedge clk);
		reset = 1'b1;
		@(posedge clk);
		reset = 1'b1;

		fd = $fopen("input_decoder.mem","r");
		fdd = $fopen("output.mem","r");
		for(i=0;i<100;i=i+1)begin
			$fscanf(fd,"%b\n", codeword);
			$fscanf(fdd,"%b\n", out);
			// ack
			@(posedge clk);
			valid = 1'b1;
			@(posedge clk);
			valid = 1'b0;
			// wait till ready becomes 1
			while (hd.ready != 1)  
			begin
				@(posedge clk);
			end
			// check fualt and compare to file
			if(hd.message!=out)begin
				$display("%x %x",hd.message,out);
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

