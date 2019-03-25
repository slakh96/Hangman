module rate_divider(resetn, LEDR, HEX0, CLOCK_50, enable);
input resetn;
input CLOCK_50;
input enable;
output[6:0] HEX0;
output[9:0] LEDR;
wire [27:0] delay_value;
wire [5:0]output_of_counter;
wire toggle_enable_for_hex_counter;
wire[27:0] period_val;
//1011111010111100001000000000 is 200 000 000
//101111101011110000100000000 is 100 000 000
//10111110101111000010000000 is 50 000 000
//assign period_val = 28'b10111110101111000010000000;//one second
assign period_val = 28'b0000000000000000000000000101;//5, for testing purposes
//hexdecoder h0(
//	.A(output_of_counter[3]),
//	.B(output_of_counter[2]),
//	.C(output_of_counter[1]),
//	.D(output_of_counter[0]),
//	.hex0(HEX0[0]),
//	.hex1(HEX0[1]),
//	.hex2(HEX0[2]),
//	.hex3(HEX0[3]),
//	.hex4(HEX0[4]),
//	.hex5(HEX0[5]),
//	.hex6(HEX0[6])
//);

RateDelay r1(
	.d(period_val),//value of the period, which is one second
	.clock(CLOCK_50),
	.reset_n(resetn),
	.q(delay_value),//Not really used, since I used the toggle_enable to see when to increment
	.toggle_enable_for_hex_counter(toggle_enable_for_hex_counter)
	
);

counter_to_hex c1(
	.d(6'b100000),//What we should load, i.e. 32 seconds which is the period
	.clock(CLOCK_50),
	.reset_n(resetn),
	.par_load(1'b0),//If we should load a new value or not...eventually need to turn this to 1 whenever a new round starts
	.second_passed(toggle_enable_for_hex_counter),//Rate delay enables this every 1 second
	.time_limit(6'b100000), //Hangman's time limit...rn it is 16 seconds
	.enable(1'b1),//To enable this counter, e.g. when the game started being played
	.q(output_of_counter)
);
assign LEDR[3:0] = output_of_counter[3:0];
assign LEDR[8:4] = 5'b00000;
assign LEDR[9] = toggle_enable_for_hex_counter;
//assign LEDR[3:0] = output_of_counter;

endmodule


module counter_to_hex(d, clock, reset_n, par_load, enable, time_limit, second_passed, q);
	input[5:0] d;//what to assign the counter to,, if par_load is high
	input clock;//timekeeping
	input reset_n;//to determine if we should reset q
	input par_load;//to determine whether we should load a new value or not
	input second_passed;//to enable this counter to increase
	input [5:0] time_limit;
	input enable;
	//1011111010111100001000000000 is 200 000 000
	//101111101011110000100000000 is 100 000 000
	//10111110101111000010000000 is 50 000 000
	output reg[5:0] q;
	
	always @(posedge clock)//does stuff if enable and clock is up
	begin
	//q <= 4'b0000;
	if (reset_n == 1'b0)
				q <= time_limit;
	else if (enable == 1'b1)
		begin
			if (par_load == 1'b1)
				q <= d;
			else if (second_passed == 1'b1)
				begin
					if (q == 6'b000000)
						q <= time_limit;
					else
						q <= q - 6'b000001;
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
