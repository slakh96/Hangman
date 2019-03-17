module shifter(LEDR, SW, KEY);
	input[9:0] SW;
	input[3:0] KEY;
	output[9:0] LEDR;
	//output[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	//SW 7-0 are the loadvalue bits, starting from the most significant
	//SW 9 is the low reset
	//KEY[1] is the load_n
	//KEY[2] is the shift right input
	//KEY[3] is the ASR input;
	//KEY[0] is the clock;
	//Q[7:0] outputs go to the LEDR[7:0];
	//leftest_shifterbit(load_value, ASR, noASR, shift, load_n, clk, reset_n, out);
	//general_shifterbit(load_value, in, shift, load_n, clk, reset_n, out);
	
	wire dig7output;
	leftest_shifterbit dig7(
		.load_value(SW[7]),
		.ASR(KEY[3]),
		.noASR(1'b0),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig7output)
	);
	assign LEDR[7] = dig7output;
	wire dig6output;
	general_shifterbit dig6(
		.load_value(SW[6]),
		.in(dig7output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig6output)
	);
	assign LEDR[6] = dig6output;
	wire dig5output;
	general_shifterbit dig5(
		.load_value(SW[5]),
		.in(dig6output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig5output)
	);
	assign LEDR[5] = dig5output;
	wire dig4output;
	general_shifterbit dig4(
		.load_value(SW[4]),
		.in(dig5output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig4output)
	);
	assign LEDR[4] = dig4output;
	wire dig3output;
	general_shifterbit dig3(
		.load_value(SW[3]),
		.in(dig4output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig3output)
	);
	assign LEDR[3] = dig3output;
	wire dig2output;
	general_shifterbit dig2(
		.load_value(SW[2]),
		.in(dig3output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig2output)
	);
	assign LEDR[2] = dig2output;
	wire dig1output;
	general_shifterbit dig1(
		.load_value(SW[1]),
		.in(dig2output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig1output)
	);
	assign LEDR[1] = dig1output;
	wire dig0output;
	general_shifterbit dig0(
		.load_value(SW[0]),
		.in(dig1output),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(dig0output)
	);
	assign LEDR[0] = dig0output;
endmodule

module leftest_shifterbit(load_value, ASR, noASR, shift, load_n, clk, reset_n, out);
	input load_value, ASR, noASR, shift, load_n, clk, reset_n;
	output out;
	wire ASRresultwire;
	mux2to1 ASRmux(
		.x(noASR),
		.y(out),
		.s(ASR),
		.m(ASRresultwire)
	);
	wire shiftmuxoutput;
	mux2to1 shiftmux(
		.x(ASRresultwire),
		.y(out),//possibly undefined to start therefore red lines
		.s(shift),
		.m(shiftmuxoutput)
	);
	wire loadmuxoutput;
	mux2to1 loadmux(
		.x(shiftmuxoutput),
		.y(load_value),
		.s(load_n),
		.m(loadmuxoutput)
	);
	wire justbeforeoutput;
	register flipflop(
		.clock(clk),
		.reset_n(reset_n),
		.d(loadmuxoutput),
		.q(out)
	);
	//assign out = justbeforeoutput;
	
	
endmodule

module general_shifterbit(load_value, in, shift, load_n, clk, reset_n, out);
	//Load value in here is a single bit, that corresponds with which shifterbit is
	//calling it
	input load_value, in, shift, load_n, clk, reset_n;
	output out;
	wire shiftmuxoutput;
	mux2to1 shiftmux(
		.x(out),
		.y(in),//possibly undefined to start therefore red lines
		.s(shift),
		.m(shiftmuxoutput)
	);
	wire loadmuxoutput;
	mux2to1 loadmux(
		.x(load_value),
		.y(shiftmuxoutput),
		.s(load_n),
		.m(loadmuxoutput)
	);
	wire justbeforeoutput;
	register flipflop(
		.clock(clk),
		.reset_n(reset_n),
		.d(loadmuxoutput),
		.q(out)
	);
	//assign out = justbeforeoutput;
	
	
endmodule

module mux2to1(x, y, s, m);
	input x, y, s;
	output m;
	assign m = s & y | -s & x;
endmodule

module register(clock, reset_n, d, q);
	input clock, reset_n;
	input  d;
	output reg q;
	//reg[7:0] q; 
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else
			q <= d;
	end
endmodule
	
	