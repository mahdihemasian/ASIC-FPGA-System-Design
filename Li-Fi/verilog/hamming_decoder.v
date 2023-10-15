module hamming_decoder(
  input wire [6:0] codeword,
  input wire clk,
  input wire valid,
  input wire reset,
  output reg ready,
  output wire [3:0] message
);
  wire [2:0] syndrome;
  reg [3:0] decoded_message;
  reg error_detected;
  reg [1:0] state;
  reg [2:0] next_state;
  
  // State definitions
  parameter IDLE = 2'b00;
  parameter DECODE = 2'b01;
  
  // Calculate the syndrome by XORing the received codeword with each parity bit
  assign syndrome[0] = codeword[0] ^ codeword[2] ^ codeword[4] ^ codeword[6];
  assign syndrome[1] = codeword[1] ^ codeword[2] ^ codeword[5] ^ codeword[6];
  assign syndrome[2] = codeword[3] ^ codeword[4] ^ codeword[5] ^ codeword[6];
  
  // State machine to decode the codeword
  always @(posedge clk or negedge reset) begin
    if (~reset) begin
      state <= IDLE;
      decoded_message <= 4'bxxxx;
      error_detected <= 0;
    end 
	else begin
      state <= next_state;
      case (state)
        IDLE: 
		begin
			ready <= 0;
          if (valid) begin
            next_state <= DECODE;
          end else begin
            next_state <= IDLE;
          end
        end
        DECODE: 
		begin	
		  ready <= 1;
          error_detected <= 0;
		  decoded_message <= {codeword[3], codeword[2], codeword[1], codeword[0]};
          if (syndrome[2] && syndrome[1] && syndrome[0]) begin
            // Three errors occurred, unable to correct
            decoded_message <= 4'bxxxx;
            error_detected <= 1;
          end else if (syndrome[2] && syndrome[1]) begin
            // Error in parity bit P2
            error_detected <= 1;
          end else if (syndrome[2] && syndrome[0]) begin
            // Error in parity bit P1
            error_detected <= 1;
          end else if (syndrome[1] && syndrome[0]) begin
            // Error in data bit D2
            decoded_message <= {codeword[3], ~codeword[2], codeword[1], codeword[0]};
            error_detected <= 1;
          end else if (syndrome[2]) begin
            // Error in data bit D3
            decoded_message <= {~codeword[3], codeword[2], codeword[1], codeword[0]};
            error_detected <= 1;
          end else if (syndrome[1]) begin
            // Error in data bit D1
            decoded_message <= {codeword[3], codeword[2], ~codeword[1], codeword[0]};
            error_detected <= 1;
          end else if (syndrome[0]) begin
            // Error in data bit D0
            decoded_message <= {codeword[3], codeword[2], codeword[1], ~codeword[0]};
            error_detected <= 1;
          end
          next_state <= IDLE;
        end
      endcase
    end
  end  
  // Assign output signals
  assign message = decoded_message;
endmodule