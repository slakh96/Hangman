module rate_divider(SW, LEDR, HEX0, KEY, CLOCK_50);
input[9:0] SW;
input[1:0] KEY;
input CLOCK_50;
output[6:0] HEX0;
output[9:0] LEDR;
wire [27:0] delay_value;
wire [3:0]output_of_counter;
wire toggle_enable_for_hex_counter;
reg[27:0] period_val;
//1011111010111100001000000000 is 200 000 000
//101111101011110000100000000 is 100 000 000
//10111110101111000010000000 is 50 000 000

//RESET is SW[9]

always @(*)
begin
	case (SW[1:0])
	2'b00:
		begin //assigns period to 1
			period_val <= 28'b0000000000000000000000000001; 
		end
	2'b01:
		begin //assigns period to 2
			period_val <= 28'b0000000000000000000000000010;
		end
	2'b10:
		begin //assigns period to 3
			period_val <= 28'b0000000000000000000000000011;
		end
	2'b11:
		begin //assigns period to 4
			period_val <= 28'b0000000000000000000000000100;
		end
	endcase
end

hexdecoder h0(
	.A(output_of_counter[3]),
	.B(output_of_counter[2]),
	.C(output_of_counter[1]),
	.D(output_of_counter[0]),
	.hex0(HEX0[0]),
	.hex1(HEX0[1]),
	.hex2(HEX0[2]),
	.hex3(HEX0[3]),
	.hex4(HEX0[4]),
	.hex5(HEX0[5]),
	.hex6(HEX0[6])
);

RateDelay r1(
	.d(period_val),//value of the period
	.clock(KEY[0]),
	.reset_n(SW[9]),
	.q(delay_value),
	.toggle_enable_for_hex_counter(toggle_enable_for_hex_counter)
	
);

counter_to_hex c1(
	.d(4'b0000),
	.clock(KEY[0]),
	.reset_n(SW[9]),
	.par_load(1'b0),
	.enable(toggle_enable_for_hex_counter),
	.q(output_of_counter)
);
assign LEDR[3:0] = output_of_counter[3:0];
assign LEDR[8:4] = 5'b00000;
assign LEDR[9] = toggle_enable_for_hex_counter;
//assign LEDR[3:0] = output_of_counter;

endmodule


module counter_to_hex(d, clock, reset_n, par_load, enable, q);
	input[3:0] d;//what to assign the counter to,, if par_load is high
	input clock;//timekeeping
	input reset_n;//to determine if we should reset q
	input par_load;//to determine whether we should load a new value or not
	input enable;//to enable this counter to increase
	//1011111010111100001000000000 is 200 000 000
	//101111101011110000100000000 is 100 000 000
	//10111110101111000010000000 is 50 000 000
	output reg[3:0] q;
	
	always @(posedge clock)//does stuff if enable and clock is up
	begin
	//q <= 4'b0000;
	if (reset_n == 1'b0)
				q <= 4'b0000;
	else if (enable == 1'b1)
		begin
			if (par_load == 1'b1)
				q <= d;
			else if (enable == 1'b1)
				begin
					if (q == 4'b1111)
						q <= 4'b0000;
					else
						q <= q + 4'b0001;
				end
		end
	end

endmodule

module RateDelay(d, clock, reset_n, q, toggle_enable_for_hex_counter);
	input[27:0] d;//what to assign the counter to,, if par_load is high
	input clock;//timekeeping
	input reset_n;//to determine if we should reset q
	output reg [27:0]q;
	output reg toggle_enable_for_hex_counter;
	//assign q = 1'b0;
	
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)//If we want to reset the countdown to zero
			begin
				q <= 28'b0000000000000000000000000000;
				toggle_enable_for_hex_counter <= 1'b0;
			end
		else
			//q <= 28'b0000000000000000000000000000;
			begin
				if (q == d)//If we have reached the max period
					begin
						q <= 28'b0000000000000000000000000000;
						toggle_enable_for_hex_counter <= 1'b1;
					end
				else //otherwise add one
					begin
						q <= q + 1'b1;
						toggle_enable_for_hex_counter <= 1'b0;
					end
			end
	end
	
	
endmodule

module hexdecoder(A,B,C,D, hex0, hex1, hex2, hex3, hex4, hex5, hex6);
	input A, B, C, D;
	output hex0, hex1, hex2, hex3, hex4, hex5, hex6;
	assign hex0 =  ~A & ~B & ~C & D |
	~A & B & ~C & ~D |
	A & ~B & C & D |
	A & B & ~C & D;
	assign hex1 = ~A & B & ~C & D |
	A & C & D |
	B & C & ~D |
	A & B & ~D;

	assign hex2 = A & B & ~D |
	~A & ~B & C & ~D |
	A & B & C;
	assign hex3 = ~A & B & ~C & ~D |
	~A & ~B & ~C & D |
	A & ~B & ~C & D |
	B & C & D |
	A & ~B & C & ~D;
	assign hex4 = ~A & B & ~C |
	~A & D |
	~B & ~C & D;
	assign hex5 = A & B & ~C & D |
	~A & ~B & D |
	~A & C & D |
	~A & ~B & C;
	assign hex6 = ~A & ~B & ~C|
	~A & B & C & D |
	A & B & ~C & ~D;

	
	
endmodule	
