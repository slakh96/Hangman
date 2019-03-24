module Hangman(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, KEY, LEDR, CLOCK_50);
    // Words should start with the first letter already given.
		localparam num_guesses_allowed = 3;
		localparam word_length = 4;
		input [9:0] SW; // SW[5:0] is guess, SW[9] is reset
		input [3:0] KEY; // IDk why we need this but ok
		input CLOCK_50;
		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;
		output [2:0] LEDR; // LEDR[0] shows if it was correct, LEDR[1] shows if it was incorrect, LEDR[2] shows if game is over.

    // WORD LIST (Length 4):
    // 1) STAY 2) DARN 3) LEAF 4) HEAD 5) LIFE

		// Eventually need to randomize this
		reg [5:0] Dash = 6'h0;
		reg [5:0] letter1 = 6'h1C; // Letter S
		reg [5:0] letter2 = 6'h1D; // Letter T
		reg [5:0] letter3 = 6'hA; // Letter A
		reg [5:0] letter4 = 6'h22; // Letter Y
		reg [5:0] letter5 = 6'h21; //Dummy value which is not any of the letters, since this is a 4 letter word

		wire [2:0] WrongGuesses;
		wire Valid, Invalid;
		wire [5:0] LetterDisplay1, LetterDisplay2, LetterDisplay3, LetterDisplay4;
		wire [1:0] GameStatus;

		control_unit c1(
			.guess(SW[5:0]), // User's input guess
			.clk(CLOCK_50),
			.resetn(SW[9]),
			.dash(Dash),
			.letter1(letter1), //First letter of the answer
			.letter2(letter2), //Second letter of the answer
			.letter3(letter3), //third letter of the answer
			.letter4(letter4), //fourth letter of the answer
			.wrong_guesses(WrongGuesses), //This wire holds the number of incorrect guesses of the user
			.valid(Valid), //Says if the current guess is valid I think
			.invalid(Invalid),
			.letter_display1(LetterDisplay1),//What to send to the hex displays
			.letter_display2(LetterDisplay2),
			.letter_display3(LetterDisplay3),
			.letter_display4(LetterDisplay4),
			.game_status(GameStatus), //If we are in PLAY (midgame), LOSE or WIN
			.go(KEY[3])
		);

    assign LEDR[0] = Valid; //If the guess was right
    assign LEDR[1] = Invalid; //If the guess was wrong
	assign LEDR[2] = GameStatus[0]; //Lights up only if you lose

    hangman_hex H0(
       .hex_digit(LetterDisplay1),
       .segments(HEX0)
       );

  hangman_hex H1(
       .hex_digit(LetterDisplay2),
       .segments(HEX1)
       );

  hangman_hex H2(
       .hex_digit(LetterDisplay3),
       .segments(HEX2)
       );

  hangman_hex H3(
       .hex_digit(LetterDisplay4),
       .segments(HEX3)
       );


endmodule

module control_unit(clk, resetn, dash, letter1, letter2, letter3, letter4,
                    guess, wrong_guesses, game_status, valid, invalid,
                    letter_display1, letter_display2, letter_display3, letter_display4, go);
    input clk, resetn;
    input [5:0] guess; //What the user guessed on their current guess
    input [5:0] letter1, letter2, letter3, letter4; //Letters of the correct word
    input [5:0] dash; //What to print to the hex if the letter is not yet revealed
	 input go;

    output [2:0] wrong_guesses; //How many wrong guesses the user made over the whole game
    output valid, invalid;
    output [1:0] game_status; //WIN, LOSE or PLAY
    output [5:0] letter_display1, letter_display2, letter_display3, letter_display4; //What to display to the hex, either dash or the actual letter

    parameter PLAY=2'd0;
    parameter LOSE=2'd1;
    parameter WIN=2'd2;

    reg[3:0] correct_guess;
    wire [3:0] next_guess;
	 reg[2:0] number_of_incorrect_guesses;
	 reg flag;

    parameter state_zero = 4'b0000;
    parameter win_state = 4'b1111;

    reg[2:0] wrong_status;
    wire[2:0] next_wrong_state;
    // Parameters for wrong states
    parameter wrong0 = 3'b000;
    parameter wrong1 = 3'b001;
    parameter wrong2 = 3'b010;
    parameter wrong3 = 3'b011;
    parameter wrong4 = 3'b100;

    always @(posedge clk, posedge go, posedge resetn)//Might need to fix this!
        begin
            if(~resetn)
                begin
                correct_guess <= state_zero;
                wrong_status <= wrong0; //Wrong status: to show the number of wrong guesses
					 number_of_incorrect_guesses <= 0;
					 flag <= 1;
                end

            else if (go && flag)
                begin
                correct_guess <= next_guess;
                //if(correct_guess != win_state & wrong_status != wrong4) // If game not over yet
						//correct_guess <= next_guess; ////Go to the next state, where the next_guess variable is a bitwise representation of which 
					 //letter positions have been guessed correctly so far
                if(correct_guess != win_state & wrong_status != wrong4)
                    wrong_status <= next_wrong_state;//Assigns the next number of wrong guesses correctly
					 if (~((guess == letter1) | (guess == letter2) | (guess == letter3) | (guess == letter4)))
							begin
							number_of_incorrect_guesses <= number_of_incorrect_guesses + 1'b1;
							flag <= 0;
							end
                end
				else if (!go)
					flag <= 1;
        end

    assign next_guess[0] = (guess == letter1 & ~correct_guess[0] ? 1'b1 : correct_guess[0]);//Might be overcomplicating things, but I think it works
    assign next_guess[1] = (guess == letter2 & ~correct_guess[1] ? 1'b1 : correct_guess[1]);//These are signals for which letters should be white
    assign next_guess[2] = (guess == letter3 & ~correct_guess[2] ? 1'b1 : correct_guess[2]);//Unnecessary overcomplication?
    assign next_guess[3] = (guess == letter4 & ~correct_guess[3] ? 1'b1 : correct_guess[3]);

	 
	 
    // if ok state, do nothing, otherwise go to the 'next' wrong state
    assign next_wrong_state =
        ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
        | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3])) ? wrong_status :
            (wrong_status == wrong0 ? wrong1 :
                (wrong_status == wrong1 ? wrong2 :
                    (wrong_status == wrong2 ? wrong3 :
                        wrong4)));//wrong state advances when you got a guess wrong...might be overcomplicating things

    //assign wrong_guesses = wrong_status;//Assigns the number of wrong guesses to the output
	 assign wrong_guesses = number_of_incorrect_guesses;

    assign invalid =  ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3]) ? 1'b0 :
                1'b1);

    assign valid =  ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3]) ? 1'b1 :
                1'b0); //Invalid = ~valid

    // Make the rules
    assign game_status = (wrong_status == wrong4 ? LOSE : (correct_guess == win_state ? WIN : PLAY));//Sets the gamestate correctly
    assign letter_display1 = ((correct_guess[0] == 1'b1) ? letter1 : dash);
    assign letter_display2 = ((correct_guess[1] == 1'b1) ? letter2 : dash);//display dash unless the user guessed this particular letter right
    assign letter_display3 = ((correct_guess[2] == 1'b1) ? letter3 : dash);
    assign letter_display4 = ((correct_guess[3] == 1'b1) ? letter4 : dash);

endmodule

module hangman_hex(hex_digit, segments);
    input [5:0] hex_digit;
    output reg [6:0] segments;
    // No letter K, Z,M, V, W, X
    always @(*)
        case (hex_digit)
	    6'h0: segments = 7'b111_0111; // The dash line
            6'hA: segments = 7'b000_1000; // Letter A
            6'hB: segments = 7'b000_0011; // Letter B
            6'hC: segments = 7'b100_0110; // Letter C
            6'hD: segments = 7'b010_0001; // Letter D
            6'hE: segments = 7'b000_0110; // Letter E
            6'hF: segments = 7'b000_1110; // Letter F
            6'h10: segments = 7'b010_0001; // Letter G
            6'h11: segments = 7'b100_1000; // Letter H
            6'h12: segments = 7'b111_1001; // Letter I
            6'h13: segments = 7'b100_0011; // Letter J
            6'h15: segments = 7'b111_0001; // Letter L
            6'h17: segments = 7'b110_1010; // Letter N
            6'h18: segments = 7'b000_0001; // Letter O
            6'h19: segments = 7'b001_1000; // Letter P
            6'h1A: segments = 7'b000_1100; // Letter Q
            6'h1B: segments = 7'b111_1010; // Letter R
            6'h1C: segments = 7'b010_0100; // Letter S
            6'h1D: segments = 7'b111_0000; // Letter T
            6'h1E: segments = 7'b100_0001; // Letter U
            6'h22: segments = 7'b100_0100; // Letter Y
            default: segments = 7'h7f;
        endcase
endmodule

//module Hangman(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, CLOCK_50);
//		
//		//TODO: Hangman drawing stuff
//		//TODO: Letter, hangman, and background images
//		//TODO: What happens when the game is over
//		//TODO: Scoreboard
//		//TODO: How to un-draw stuff?
//		//TODO: TESTING :(
//		
//		
//		//Ask about unmasking a letter if we have a binary representation of where it is
//		//Ask how to unmask multiple letters together
//		//Ask about images,,, how to put them into Verilog
//		
//		input [9:0] SW;
//		input [3:0] KEY;
//		input CLOCK_50;
//		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
//		output [9:0] LEDR;
//endmodule
//		//Eventually need to randomize this
//		reg letter1 = 5'b10010;//S
//		reg letter2 = 5'b10011;//T
//		reg letter3 = 5'b00000;//A
//		reg letter4 = 5'b11000;//Y
//		reg letter5 = 5'b11111;//Dummy value which is not any of the letters, since this is a 4 letter word
//		wire enable_l1, enable_l2, enable_l3, enable_l4, enable_l5, enable_mask_remove, draw_hangman, unmask_letters, game_won;
//		control_letter c1(
//			.guess(SW[4:0]),
//			.clk(CLOCK_50),
//			.resetn(SW[9]),
//			.go(KEY[3]),//To cycle through the states
//			.letter1(letter1),
//			.letter2(letter2),
//			.letter3(letter3),
//			.letter4(letter4),
//			.letter5(letter5),
//			.enable_l1(enable_l1),
//			.enable_l2(enable_l2),
//			.enable_l3(enable_l3),
//			.enable_l4(enable_l4),
//			.enable_l5(enable_l5),
//			.correct(enable_mask_remove)
//		);
//		datapath d0(
//			.clk(CLOCK_50),
//			.resetn(SW[9]),
//			.enable_l1(enable_l1),
//			.enable_l2(enable_l2),
//			.enable_l3(enable_l3),
//			.enable_l4(enable_l4),
//			.enable_l5(enable_l5),
//			.draw_hangman(draw_hangman),//Equal to the number of times the user has guessed wrong.
//			.game_won(game_won)
//		);
//		
//		vga_adapter VGA(
//			.resetn(SW[9]),
//			.clock(CLOCK_50),
//			.colour(3'b010), //Just give a random colour for now
//			.x(7'b101010), //offsetting it by the letter to draw
//			.y(y),
//			.plot(enable_mask_remove),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
//		wire game_over;
//		assign game_over = game_won || draw_hangman == 6; //Game is over when user guesses too many wrong (e.g. 6 wrong) or wins
//		rate_divider r1(
//			.resetn(SW[9]),
//			.HEX0(HEX0),
//			.CLOCK_50(CLOCK_50),
//			.LEDR(LEDR[9:0]),
//			.enable(~game_over) //if the game is not over and the timer should continue
//		);
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
//			if (num_corrects < 4)
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
