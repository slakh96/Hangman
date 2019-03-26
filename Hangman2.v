//module Hangman2(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, CLOCK_50);
//		
//		localparam num_guesses_allowed = 8;
//		localparam word_length = 4;
//		input [9:0] SW;
//		input [3:0] KEY;
//		input CLOCK_50;
//		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
//		output [9:0] LEDR;
//		//Eventually need to randomize this
//		reg letter1 = 5'b10010;//S
//		reg letter2 = 5'b10011;//T
//		reg letter3 = 5'b00000;//A
//		reg letter4 = 5'b11000;//Y
//		reg letter5 = 5'b11111;//Dummy value which is not any of the letters, since this is a 4 letter word
//		wire enable_l1, enable_l2, enable_l3, enable_l4, enable_l5, correct, draw_hangman, unmask_letters, game_won, letter_display;
//		wire [5:0] num_guesses_left;
//		control_letter c1(
//			.guess(SW[4:0]), //User's input guess
//			.clk(CLOCK_50),
//			.resetn(SW[9]),
//			.go(KEY[3]),//To cycle through the states
//			.letter1(letter1),//Set once per game
//			.letter2(letter2), //Set once per game
//			.letter3(letter3), //Set once per game
//			.letter4(letter4), // Set once per game
//			.letter5(letter5), // Set once per game
//			.enable_l1(enable_l1), //If the user's guess matches the first letter of the word
//			.enable_l2(enable_l2), //If the user's guess matches the second letter of the word
//			.enable_l3(enable_l3), //If the user's guess matches the third letter of the word
//			.enable_l4(enable_l4), //If the user's guess matches the fourth letter of the word
//			.enable_l5(enable_l5), //If the user's guess matches the fifth letter of the word
//			.correct(correct)
//		);
//		datapath d0(
//			.clk(CLOCK_50),
//			.resetn(SW[9]),
//			.enable_l1(enable_l1),//Inputs from the control
//			.enable_l2(enable_l2),
//			.enable_l3(enable_l3),
//			.enable_l4(enable_l4),
//			.enable_l5(enable_l5),
//			.draw_hangman(draw_hangman),//Equal to the number of times the user has guessed wrong.
//			.game_won(game_won),
//			.letter_display(letter_display)//Bitwise representation of which letters we should be displaying on the hex, not additive
//		);
//		wire game_over;
//		wire [9:0] rate_divider_out;
//		wire [6:0] filler_wire;
//		assign game_over = game_won || draw_hangman == num_guesses_allowed || rate_divider_out = 0; //Game is over when user guesses too many wrong 
//		//(e.g. 8 wrong) or wins or time up
//		rate_divider r1(
//			.resetn(SW[9]),
//			.HEX0(filler_wire[6:0]),
//			.CLOCK_50(CLOCK_50),
//			.LEDR(rate_divider[9:0]),//Outputs the current value of the counter
//			.enable(~game_over) //if the game is not over and the timer should continue
//		);
//		assign num_guesses_left = num_guesses_allowed - draw_hangman;
//		assign LEDR[5:0] = num_guesses_left;
//		
//endmodule
//
//module control_letter(input [4:0] guess, input clk, input resetn, input go, input[4:0] letter1, input[4:0] letter2, input[4:0] letter3, 
//	input[4:0] letter4, input[4:0] letter5, output reg enable_l1, output reg enable_l2, output reg enable_l3, output reg enable_l4,
//	output reg enable_l5, output reg correct);
//	//Inputs letters of correct word so that we can compare and find out what state to go to, outputs the enable for each of the registers, 
//	//so that they can be loaded with ones (indicating that the specific letter position have been guessed right).
//	reg [4:0] current_state, next_state;
//
//    localparam  S_INCORRECT     = 4'd0,
//                S_INCORRECT_WAIT= 4'd1,
//                S_CORRECT       = 4'd2,
//                S_CORRECT_WAIT  = 4'd3;
//    always@(*)
//    begin: state_table
//		enable_l1 = 1'b0;
//		enable_l2 = 1'b0;
//		enable_l3 = 1'b0;
//		enable_l4 = 1'b0;
//		enable_l5 = 1'b0;
//		correct = 1'b0;
//            case (current_state)
//                S_INCORRECT: next_state = go ? S_INCORRECT_WAIT : S_INCORRECT; // Loop in current state until value is input
//                S_INCORRECT_WAIT: begin
//							if (go) next_state = S_INCORRECT_WAIT;
//							else
//								begin
//									if(guess == letter1)
//										begin
//											next_state = S_CORRECT;
//											enable_l1 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter2)
//										begin
//											next_state = S_CORRECT;
//											enable_l2 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter3)
//										begin
//											next_state = S_CORRECT;
//											enable_l3 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter4)
//										begin
//											next_state = S_CORRECT;
//											enable_l4 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter5)
//										begin
//											next_state = S_CORRECT;
//											enable_l5 = 1'b1;
//											correct = 1'b1;
//										end
//									if (correct == 1'b0)
//										next_state = S_INCORRECT;
//									
//								end
//							end
//					 S_CORRECT: next_state = go ? S_CORRECT_WAIT : S_CORRECT; // Loop in current state until value is input
//                S_CORRECT_WAIT: begin//next_state = go ? S_INCORRECT_WAIT : begin // Loop in current state until go signal goes low
//								if (go) 
//									next_state = S_CORRECT_WAIT;
//								else
//									begin
//									if(guess == letter1)
//										begin
//											next_state = S_CORRECT;
//											enable_l1 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter2)
//										begin
//											next_state = S_CORRECT;
//											enable_l2 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter3)
//										begin
//											next_state = S_CORRECT;
//											enable_l3 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter4)
//										begin
//											next_state = S_CORRECT;
//											enable_l4 = 1'b1;
//											correct = 1'b1;
//										end
//									if(guess == letter5)
//										begin
//											next_state = S_CORRECT;
//											enable_l5 = 1'b1;
//											correct = 1'b1;
//										end
//									if (correct == 1'b0)
//										next_state = S_INCORRECT;
//									
//								end
//							end
//            default:     next_state = S_INCORRECT;
//        endcase
//    end // state_table
//	
//    always@(posedge clk)
//    begin: state_FFs
//        if(!resetn)
//            current_state <= S_INCORRECT;
//        else
//            current_state <= next_state;
//    end // state_FFS
//endmodule
//
//module datapath(clk, resetn, enable_l1, enable_l2, enable_l3, enable_l4, enable_l5,
//					draw_hangman, letter_display, game_won);
//	input clk, resetn;
//	input enable_l1, enable_l2, enable_l3, enable_l4, enable_l5;
//	output [5:0] draw_hangman; // draws parts of hangman, 1 for head, 2 for head+hand
//	output reg game_won;
//	reg en_l1, en_l2, en_l3, en_l4, en_l5;
//	reg num_corrects; // number of corrects (due to enable signals)
//	reg [5:0] increment; // basically increments if all enables were 0; the guess was wrong
//	output [5:0] letter_display; // displays letters in binary rep
//	
//	always @(posedge clk)
//	begin: counter
//		if (!resetn)
//			begin
//			num_corrects <= 0;
//			increment <= 0;
//			en_l1 <= 0;
//			en_l2 <= 0;
//			en_l3 <= 0;
//			en_l4 <= 0;
//			en_l5 <= 0;
//			end
//		else
//			begin
//			if (num_corrects == 5'b1111)
//				begin
//				num_corrects <= 0;
//				increment <= 0;
//				end
//			else if (enable_l1 || enable_l2 || enable_l3 || enable_l4 || enable_l5)
//				begin
//				if (enable_l1)
//					en_l1 <= 1;
//					num_corrects <= num_corrects + 1'b1;
//				if (enable_l2)
//					en_l2 <= 1;
//					num_corrects <= num_corrects + 1'b1;
//				if (enable_l3)
//					en_l3 <= 1;
//					num_corrects <= num_corrects + 1'b1;
//				if (enable_l4)
//					en_l4 <= 1;
//					num_corrects <= num_corrects + 1'b1;
//				if (enable_l5)
//					en_l5 <= 1;
//					num_corrects <= num_corrects + 1'b1;
//				end
//			else 
//				increment <= increment + 1'b1;
//			if (num_corrects < word_length)//HARD CODED FOR FOUR RN
//				game_won <= 1'b0;
//			else
//				game_won <= 1'b1;
//		end
//	end
//	
//	assign draw_hangman = increment;
//	assign letter_display = {en_l1, en_l2, en_l3, en_l4, en_l5};
//		
//
//endmodule
//
//
//module hex_decoder(hex_digit, segments);
//    input [3:0] hex_digit;
//    output reg [6:0] segments;
//   
//    always @(*)
//        case (hex_digit)
//            4'h0: segments = 7'b100_0000;
//            4'h1: segments = 7'b111_1001;
//            4'h2: segments = 7'b010_0100;
//            4'h3: segments = 7'b011_0000;
//            4'h4: segments = 7'b001_1001;
//            4'h5: segments = 7'b001_0010;
//            4'h6: segments = 7'b000_0010;
//            4'h7: segments = 7'b111_1000;
//            4'h8: segments = 7'b000_0000;
//            4'h9: segments = 7'b001_1000;
//            4'hA: segments = 7'b000_1000;
//            4'hB: segments = 7'b000_0011;
//            4'hC: segments = 7'b100_0110;
//            4'hD: segments = 7'b010_0001;
//            4'hE: segments = 7'b000_0110;
//            4'hF: segments = 7'b000_1110;   
//            default: segments = 7'h7f;
//        endcase
//endmodule
