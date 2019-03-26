module Hangman(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, KEY, LEDR, CLOCK_50);
		localparam num_wrong_guesses_allowed = 4;
		localparam word_length = 4;
		input [9:0] SW; // SW[5:0] is guess, SW[9] is reset
		input [3:0] KEY; // IDk why we need this but ok
		input CLOCK_50;
		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;
		output [9:0] LEDR; // LEDR[0] shows if it was correct, LEDR[1] shows if it was incorrect, LEDR[2] shows if game is over.

    // WORD LIST (Length 4):
    // 1) STAY 2) DARN 3) LEAF 4) HEAD 5) LIFE
		
		// Eventually need to randomize this
		reg [5:0] Dash = 6'h0;
		reg [5:0] letter1 = 6'h1C; // Letter S
		reg [5:0] letter2 = 6'h1D; // Letter T
		reg [5:0] letter3 = 6'hA; // Letter A
		reg [5:0] letter4 = 6'h22; // Letter Y
		reg [5:0] letter5 = 6'h21; //Dummy value which is not any of the letters, since this is a 4 letter word
		wire enable_l1, enable_l2, enable_l3, enable_l4, game_won, game_lost, correct_guess;
		wire [5:0] letter1display, letter2display, letter3display, letter4display;
		wire [1:0] random;
		
//		lfsr ls1 (
//      .out(random),
//      .clk(clock),
//      .rst(reset)
//      );
		
		
		wire [5:0] l1, l2, l3, l4, counter_val;
		
		rate_divider rate0(
			.resetn(SW[9]),
			.CLOCK_50(CLOCK_50),
			.enable(1'b1), //Eventually change this to when the user starts the game
			.counter_val(counter_val)
			
		);
		
//		randomizer rand0(
//			.clock(CLOCK_50),
//			.reset(SW[9]),
//			.num(random),
//			.letter1(l1),
//			.letter2(l2),
//			.letter3(l3),
//			.letter4(l4)
//			);
		
		controller c0(
			.clk(CLOCK_50),
			.resetn(SW[9]),
			.go(KEY[3]),
			.guess(SW[5:0]),
			.start_new_game(KEY[0]),
			.letter1(letter1),
			.letter2(letter2),
			.letter3(letter3),
			.letter4(letter4),
			.timer(counter_val),
			.enable_l1(enable_l1),
			.enable_l2(enable_l2),
			.enable_l3(enable_l3),
			.enable_l4(enable_l4),
			.game_lost(game_lost),
			.game_won(game_won),
			.correct_guess(correct_guess)
		);
		
		datapath d0(
			.clk(CLOCK_50),
			.resetn(SW[9]),
			.enable_l1(enable_l1),
			.enable_l2(enable_l2),
			.enable_l3(enable_l3),
			.enable_l4(enable_l4),
			.game_won(game_won),
			.game_lost(game_lost),
			.dash(Dash),
			.letter1(letter1),
			.letter2(letter2),
			.letter3(letter3),
			.letter4(letter4),
			.letter1display(letter1display),
			.letter2display(letter2display),
			.letter3display(letter3display),
			.letter4display(letter4display)
		);
		assign LEDR[0] = correct_guess;
		assign LEDR[1] = ~correct_guess;
		assign LEDR[2] = game_lost;
		assign LEDR[3] = game_won;
		assign LEDR[9:4] = counter_val;
		
		hangman_hex H3(
       .hex_digit(letter1display),
       .segments(HEX3)
       );

		hangman_hex H2(
       .hex_digit(letter2display),
       .segments(HEX2)
       );

		hangman_hex H1(
       .hex_digit(letter3display),
       .segments(HEX1)
       );

		hangman_hex H0(
       .hex_digit(letter4display),
       .segments(HEX0)
       );
		hexdecoder H4(//GAZI PLS CHECK THIS I DON'T THINK THIS WILL WORK PROPERLY
			.A(counter_val[3]),
			.B(counter_val[2]),
			.C(counter_val[1]),
			.D(counter_val[0]),
			.hex0(HEX4[0]),
			.hex1(HEX4[1]),
			.hex2(HEX4[2]),
			.hex3(HEX4[3]),
			.hex4(HEX4[4]),
			.hex5(HEX4[5]),
			.hex6(HEX4[6])
		);

endmodule

module controller(
	input clk,
	input resetn, 
	input go,
	input [5:0] guess,
	input start_new_game,
	input [5:0] letter1,
	input [5:0] letter2,
	input [5:0] letter3,
	input [5:0] letter4,
	input [5:0] timer,
	output reg enable_l1,
	output reg enable_l2,
	output reg enable_l3,
	output reg enable_l4,
	output reg game_lost,
	output reg game_won,
	output correct_guess
	);
	parameter max_num_wrongs = 4;
	 reg [3:0] current_state, next_state, num_wrongs;
	
    localparam  S_START         = 4'd0,
                S_START_WAIT    = 4'd1,
                S_CORRECT       = 4'd2,
                S_CORRECT_WAIT  = 4'd3,
                S_INCORRECT     = 4'd4,
                S_INCORRECT_WAIT= 4'd5,
                S_WIN           = 4'd6,
                S_LOSE          = 4'd7,
					 S_WIN_WAIT      = 4'd8,
					 S_LOSE_WAIT     = 4'd9;
    always@(*)
    begin: state_table 
            case (current_state)
					S_START: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (go)
							next_state = S_START_WAIT;
						else
							next_state = S_START;
						end
					
					
					S_START_WAIT: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (go)
							next_state = S_START_WAIT;
						else begin
							if ((letter1 == guess) | (letter2 == guess) | (letter3 == guess) | (letter4 == guess))
								next_state = S_CORRECT;
							else
								next_state = S_INCORRECT;
						end
					end
					
					
					S_CORRECT: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (enable_l1 && enable_l2 && enable_l3 && enable_l4)
							next_state = S_WIN;
						else if (go)
							next_state = S_CORRECT_WAIT;
						else
							next_state = S_CORRECT;
					end
					
					
					S_CORRECT_WAIT: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (go)
							next_state = S_CORRECT_WAIT;
						else begin
							if ((letter1 == guess) | (letter2 == guess) | (letter3 == guess) | (letter4 == guess))
								next_state = S_CORRECT;
							else
								next_state = S_INCORRECT;
						end
					end
					
					
					S_INCORRECT: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (num_wrongs >= max_num_wrongs)
							next_state = S_LOSE;
						else if (go)
							next_state = S_INCORRECT_WAIT;
						else
							next_state = S_INCORRECT;
					end
					
					
					S_INCORRECT_WAIT: begin
						if (timer == 0)
							next_state = S_LOSE;
						else if (go)
							next_state = S_INCORRECT_WAIT;
						else begin
							if ((letter1 == guess) | (letter2 == guess) | (letter3 == guess) | (letter4 == guess))
								next_state = S_CORRECT;
							else
								next_state = S_INCORRECT;
						end
					end
					
					
					S_WIN: begin
						if (start_new_game)
							next_state = S_WIN_WAIT;
						else
							next_state = S_WIN;
					end
					
					S_WIN_WAIT: begin
						if (!start_new_game)
							next_state = S_START;
						else
							next_state = S_WIN_WAIT;
					end
					
					
					S_LOSE: begin
						if (start_new_game)
							next_state = S_LOSE_WAIT;
						else
							next_state = S_LOSE;
					end
					
					S_LOSE_WAIT: begin
						if (!start_new_game)
							next_state = S_START;
						else
							next_state = S_LOSE_WAIT;
					end
	
            default:     next_state = S_START;
        endcase
    end // state_table

	always @(*)
	begin: enable_signals
		case (current_state)
			S_START: begin
				num_wrongs = 0;
				enable_l1 = 0;
				enable_l2 = 0;
				enable_l3 = 0;
				enable_l4 = 0;
				game_won = 0;
				game_lost = 0;
			end
			S_CORRECT: begin
				if (guess == letter1)
					enable_l1 = 1;
				if (guess == letter2)
					enable_l2 = 1;
				if (guess == letter3)
					enable_l3 = 1;
				if (guess == letter4)
					enable_l4 = 1;
			end
			S_INCORRECT: begin
				num_wrongs = num_wrongs + 1'b1;
			end
			
			S_WIN:
				game_won = 1;
			S_LOSE:
				game_lost = 1;
			
		endcase
	end // enable_signals
	
    always @(posedge clk)
	 begin
		if (!resetn)
			current_state <= S_START;
		else
			current_state <= next_state;
	 
	 end
	 assign correct_guess = (letter1 == guess) | (letter2 == guess) | (letter3 == guess) | (letter4 == guess);

endmodule

module datapath(
	input clk,
	input resetn,
	input enable_l1,
	input enable_l2,
	input enable_l3,
	input enable_l4,
	input game_lost,
	input game_won,
	input [5:0] dash,
	input [5:0] letter1,
	input [5:0] letter2,
	input [5:0] letter3,
	input [5:0] letter4,
	output reg [5:0] letter1display,
	output reg [5:0] letter2display,
	output reg [5:0] letter3display,
	output reg [5:0] letter4display
	);
	
	always @(posedge clk)
	begin
		if (enable_l1)
			letter1display = letter1;
		else
			letter1display = dash;
			
		if (enable_l2)
			letter2display = letter2;
		else
			letter2display = dash;
			
		if (enable_l3)
			letter3display = letter3;
		else
			letter3display = dash;
			
		if (enable_l4)
			letter4display = letter4;
		else
			letter4display = dash;
	end
	
	

endmodule

module hangman_hex(hex_digit, segments);
    input [5:0] hex_digit;
    output reg [6:0] segments;
    // No letter K, Z,M, V, W, X
    always @(*)
        case (hex_digit)
	    6'h0: segments = 7'b111_0111; // The dash line
            6'hA: segments = 7'b000_1000; // Letter A
            6'hB: segments = 7'b110_0011; // Letter B
            6'hC: segments = 7'b100_0110; // Letter C
            6'hD: segments = 7'b010_0001; // Letter D
            6'hE: segments = 7'b000_0110; // Letter E
            6'hF: segments = 7'b000_1110; // Letter F
            6'h10: segments = 7'b1000010; // Letter G
            6'h11: segments = 7'b0001001; // Letter H
            6'h12: segments = 7'b1001111; // Letter I
            6'h13: segments = 7'b1100001; // Letter J
            6'h15: segments = 7'b1000111; // Letter L
            6'h17: segments = 7'b0101001; // Letter N
            6'h18: segments = 7'b1000_000; // Letter O
            6'h19: segments = 7'b0001100; // Letter P
            6'h1A: segments = 7'b0011000; // Letter Q
            6'h1B: segments = 7'b0101111; // Letter R
            6'h1C: segments = 7'b0010010; // Letter S
            6'h1D: segments = 7'b0000111; // Letter T
            6'h1E: segments = 7'b1000001; // Letter U
            6'h22: segments = 7'b0010001; // Letter Y
            default: segments = 7'h7f;
        endcase
endmodule

module randomizer(clock, reset, num, letter1, letter2, letter3, letter4);
    input clock, reset;
    input [1:0] num;
    output reg [5:0] letter1, letter2, letter3, letter4;
    
      
always @(posedge clock, posedge reset)
        case (num)
	          2'd0: // STAY
              begin
              letter1 = 6'h1C;
              letter2 = 6'h1D;
              letter3 = 6'hA;
              letter4 = 6'h22;
              end
            2'd1: // DARN
              begin
              letter1 = 6'hD;
              letter2 = 6'hA;
              letter3 = 6'h1B;
              letter4 = 6'h17;
              end
            2'd2: // LIFE
              begin
              letter1 = 6'h15;
              letter2 = 6'h12;
              letter3 = 6'hF;
              letter4 = 6'hE;
              end
            2'd3: // HEAD
              begin
              letter1 = 6'h11;
              letter2 = 6'hE;
              letter3 = 6'hA;
              letter4 = 6'hD;
              end
            default:
              begin
              letter1 = 6'hA;
              letter2 = 6'hB;
              letter3 = 6'hC;
              letter4 = 6'hD;
              end
        endcase
endmodule

module lfsr (out, clk, rst);
  output reg [1:0] out;
  input clk,
  rst;
  wire feedback;

  assign feedback = ~(out[1] ^ out[0]);

  always @(posedge clk, posedge rst)
    begin
      if (rst)
        out = 2'b0;
      else
        out = {out[0],feedback};
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