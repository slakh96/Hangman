// Part 2 skeleton

module graphics
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire ld_x, ld_y, draw;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    datacontrol dc1 (
		.clock(CLOCK_50),
		.resetn(resetn),
		
		.data(SW[6:0]),
		.colour(SW[9:7]),
		.ld(~KEY[3]),
		.go(~KEY[1]),
		.out_x(x),
		.out_y(y),
		.out_colour(colour),
		.plot(writeEn)
	);

    
endmodule

module datacontrol (clock, resetn, data, colour, ld, go, x_out, y_out, out_colour, plot);
	input clock, resetn, ld, go;
	input [6:0] data;
	input [2:0] colour;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] out_colour;
	output plot;
	
	wire ld_x, ld_y, ld_r,  draw;

	datapath d0(
		.resetn(resetn),
		.clock(clock),
		.data(data),
		.colour(colour),
		
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_r(ld_r),
		.draw(draw),
		
		.x_out(x_out),
		.y_out(y_out),
		.out_colour(out_colour)
	);

   control c0(
		.clock(clock),
		.resetn(resetn),
		.ld(ld),
		.go(go),
		
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_r(ld_r),
		.draw(draw),
		.plot(plot)
		);
	
endmodule

module datapath(data, colour, resetn, clock, ld_x, ld_y, ld_r, draw, x_out, y_out, out_colour);
	input [6:0] data;
	input [2:0] colour;
	input resetn, clock;
	input ld_x, ld_y, ld_r, draw;
	
	output  [7:0] x_out;
	output  [6:0] y_out;
	output reg [2:0] out_colour;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [3:0] q;
	
	always @(posedge clock)
	begin: load
		if (!resetn) begin
			x <= 0;
			y <= 0;
			out_colour = 3'b111;
			end
		else 
			begin
				if (ld_x) begin
					x <= {1'b0, data};
					end
				else if (ld_y)
					y <= data;
				else if (ld_r)
					out_colour = colour;
			end
	end

	always @(posedge clock)
	begin: counter
		if (! resetn)
			q <= 4'b0000;
		else if (draw)
			begin
				if (q == 4'b1111)
					q <= 0;
				else
					q <= q + 1'b1;
			end
	end
	
	assign x_out = x + q[1:0];
	assign y_out = y + q[3:2];
	
endmodule

module control(clock, resetn, go, ld, ld_x, ld_y, ld_r, draw, plot);
	input resetn, clock, go, ld;
	output reg ld_x, ld_y, ld_r, draw, plot;

	reg [2:0] current_state, next_state;
	
	localparam Start = 3'd0,
					Load_x = 3'd1,
					Load_x_wait= 3'd2,
					Load_y = 3'd3,
					Load_y_wait = 3'd4,
					Load_colour = 3'd5,
					Draw = 3'd6;

	always @(*)
	begin: state_table
		case (current_state)
			Start: next_state = ld ? Load_x : Start;
			Load_x: next_state = ld ? Load_x : Load_x_wait;
			Load_x_wait: next_state = ld ? Load_y : Load_x_wait;
			Load_y: next_state = ld ? Load_y : Load_y_wait;
			Load_y_wait: next_state = Load_colour;
			Load_colour: next_state = go ? Draw : Load_colour;
			Draw: next_state = ld ? Load_x : Draw;
			default: next_state = Start;
		endcase
	end
	
	always @(*)
	begin: signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_r = 1'b0;
		draw = 1'b0;
		plot = 1'b0;
		
		case (current_state)
		Load_x: begin 
			ld_x = 1'b1;
			end
		Load_y: begin
			ld_y = 1'b1;
			end
		Load_colour : begin
			ld_r = 1'b1;
			end
		Draw: begin
			draw = 1'b1;
			plot = 1'b1;
			end
		endcase
	end
	
always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= Start;
        else
            current_state <= next_state;
    end
endmodule
