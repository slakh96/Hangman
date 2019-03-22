module Hangman3(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, KEY, LEDR, CLOCK_50);
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
		reg Dash = 6'h0;
		reg letter1 = 6'h1C; // Letter S
		reg letter2 = 6'h1D; // Letter T
		reg letter3 = 6'hA; // Letter A
		reg letter4 = 6'h22; // Letter Y
		reg letter5 = 6'h21; //Dummy value which is not any of the letters, since this is a 4 letter word

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
    input dash; //What to print to the hex if the letter is not yet revealed
	 input go;

    output [2:0] wrong_guesses; //How many wrong guesses the user made over the whole game
    output valid, invalid;
    output [1:0] game_status; //WIN, LOSE or PLAY
    output [5:0] letter_display1, letter_display2, letter_display3, letter_display4; //What to display to the hex, either dash or the actual letter

    parameter PLAY=2'd0;
    parameter LOSE=2'd1;
    parameter WIN=2'd2;


<<<<<<< HEAD
    reg[3:0] correct_guess;
=======
	reg[3:0] correct_guess;
>>>>>>> 2b6535c98151f4a7a03e234b79d9c09384d93932
    wire[5:0] next_guess;

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

    always@((posedge clk & posedge go) or posedge resetn)
        begin
            if(resetn)
                begin
                correct_guess <= state_zero;
                wrong_status <= wrong0;
                end

            else
                begin
<<<<<<< HEAD
                correct_guess <= next_guess; //Go to the next state 
                if(correct_guess != win_state & wrong_status != wrong4) // If game not over yet
=======
                correct_guess <= next_guess;
                if(guess != win_state & wrong_status != wrong4)
>>>>>>> 2b6535c98151f4a7a03e234b79d9c09384d93932
                    wrong_status <= next_wrong_state;
                end
        end

    assign next_guess[0] = (guess == letter1 & ~correct_guess[0] ? 1'b1 : correct_guess[0]);//Might be overcomplicating things, but I think it works
    assign next_guess[1] = (guess == letter2 & ~correct_guess[1] ? 1'b1 : correct_guess[1]);
    assign next_guess[2] = (guess == letter3 & ~correct_guess[2] ? 1'b1 : correct_guess[2]);
    assign next_guess[3] = (guess == letter4 & ~correct_guess[3] ? 1'b1 : correct_guess[3]);

    // if ok state, do nothing, otherwise go to the 'next' wrong state
    assign next_wrong_state =
        ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
<<<<<<< HEAD
        | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3])) ? wrong_status :
=======
        | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3]) ? wrong_status :
>>>>>>> 2b6535c98151f4a7a03e234b79d9c09384d93932
            (wrong_status == wrong0 ? wrong1 :
                (wrong_status == wrong1 ? wrong2 :
                    (wrong_status == wrong2 ? wrong3 :
                        wrong4))));//wrong state advances when you got a guess wrong...might be overcomplicating things

    assign wrong_guesses = wrong_status;

    assign valid =  ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
<<<<<<< HEAD
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3])) ? 1'b0 :
                1'b1);

    assign invalid =  ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3])) ? 1'b1 :
                1'b0); //Invalid = ~valid
=======
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3]) ? 1'b0 :
                1'b1);

    assign invalid =  ((guess == letter1 & ~correct_guess[0]) | (guess == letter2 & ~correct_guess[1])
            | (guess == letter3 & ~correct_guess[2]) | (guess == letter4 & ~correct_guess[3]) ? 1'b1 :
                1'b0);
>>>>>>> 2b6535c98151f4a7a03e234b79d9c09384d93932

    // Make the rules
    assign game_status = (wrong_status == wrong4 ? LOSE : (correct_guess == win_state ? WIN : PLAY));//Sets the gamestate correctly
    assign letter_display[0] = ((correct_guess[0] == 1'b1) ? letter1 : dash);
    assign letter_display[1] = ((correct_guess[1] == 1'b1) ? letter2 : dash);//display dash unless the user guessed this particular letter right
    assign letter_display[2] = ((correct_guess[2] == 1'b1) ? letter3 : dash);
    assign letter_display[3] = ((correct_guess[3] == 1'b1) ? letter4 : dash);

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
