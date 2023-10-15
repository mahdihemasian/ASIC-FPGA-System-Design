



module CORDIC #(parameter integer W = 32)
(
    input wire clk,
    input wire start,
    input wire signed [31:0] x,
    input wire signed [31:0] y,
    output wire signed [W-1:0]phi 
);

//port declearation
wire sigma;
wire signed [31:0] x_shift;
wire signed [31:0] y_shift;

reg [5:0] counter;

reg signed [31:0] x_reg;
reg signed [31:0] y_reg;
reg signed [31:0] z;

//Creat Look up table for tan^-1
wire signed [31:0] atan_table [0:27];
                          
assign atan_table[00] = 32'h3243f6a9; 
assign atan_table[01] = 32'h1dac6705;
assign atan_table[02] = 32'h0fadbafd;
assign atan_table[03] = 32'h07f56ea7;
assign atan_table[04] = 32'h03feab77;
assign atan_table[05] = 32'h01ffd55c;
assign atan_table[06] = 32'h00fffaab;
assign atan_table[07] = 32'h007fff55;
assign atan_table[08] = 32'h003fffeb;
assign atan_table[09] = 32'h001ffffd;
assign atan_table[10] = 32'h00100000;
assign atan_table[11] = 32'h00080000;
assign atan_table[12] = 32'h00040000;
assign atan_table[13] = 32'h00020000;
assign atan_table[14] = 32'h00010000;
assign atan_table[15] = 32'h00008000;
assign atan_table[16] = 32'h00004000;
assign atan_table[17] = 32'h00002000;
assign atan_table[18] = 32'h00001000;
assign atan_table[19] = 32'h00000800;
assign atan_table[20] = 32'h00000400;
assign atan_table[21] = 32'h00000200;
assign atan_table[22] = 32'h00000100;
assign atan_table[23] = 32'h00000080;
assign atan_table[24] = 32'h00000040;
assign atan_table[25] = 32'h00000020;
assign atan_table[26] = 32'h00000010;
assign atan_table[27] = 32'h00000008;

//assign
assign sigma = y_reg[31];
assign x_shift = y_reg >>> counter; 
assign y_shift = x_reg >>> counter; 
assign phi = z[31:31-W+1];

//always block
always @(posedge clk) begin

    if(start)begin
        x_reg <= x;
        y_reg <= y;
        z <= 0;
        counter <= 0;
    end
    else begin
        if(counter == 28) begin
            x_reg <= x_reg;
            y_reg <= y_reg;
            z <= z;
            counter <= counter;
        end
        else begin
            x_reg <= sigma ? (x_reg - x_shift) : (x_reg + x_shift);
            y_reg <= sigma ? (y_reg + y_shift) : (y_reg - y_shift);
            z <= sigma ? (z - atan_table[counter]) : (z + atan_table[counter]);
            counter <= counter + 1;
        end
    end

end


    
endmodule