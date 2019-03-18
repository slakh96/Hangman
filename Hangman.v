module Hangman(SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR);
		
		input [9:0] SW;
		input [3:0] KEY;
		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		output [9:0] LEDR;
		//Eventually need to randomize this
		reg letter1 = 5'b10010;//S
		reg letter2 = 5'b10011;//T
		reg letter3 = 5'b00000;//A
		reg letter4 = 5'b11000;//Y
		reg letter5 = 5'b11111;//Dummy value, which is not any of the letters, since this is a 4 letter word
endmodule

module control_letter(input guess, input clk, input resetn, input go, input letter1, input letter2, input letter3, input letter4, input letter5,
	output enable_l1, output enable_l2, output enable_l3, output enable_l4, output enable_l5);
	//Inputs letters of correct word so that we can compare and find out what state to go to, outputs the enable for each of the registers, 
	//so that they can be loaded with ones (indicating that the specific letter position have been guessed right).
	assign enable_l1 = 1'b0;
	assign enable_l2 = 1'b0;
	assign enable_l3 = 1'b0;
	assign enable_l4 = 1'b0;
	assign enable_l5 = 1'b0;
	wire correct = 1'b0;
	
    localparam  S_INCORRECT     = 4'd0,
                S_INCORRECT_WAIT= 4'd1,
                S_CORRECT       = 4'd2,
                S_CORRECT_WAIT  = 4'd3;
    always@(*)
    begin: state_table 
            case (current_state)
                S_INCORRECT: next_state = go ? S_INCORRECT_WAIT : S_INCORRECT; // Loop in current state until value is input
                S_INCORRECT_WAIT: next_state = go ? S_INCORRECT_WAIT : begin// Loop in current state until go signal goes low
							//begin
								//next_state = go ? S_INCORRECT_WAIT : S_LOAD_B; // Loop in current state until go signal goes low
								if(guess == letter1)
									begin
										next_state = S_CORRECT;
										enable_l1 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter2)
									begin
										next_state = S_CORRECT;
										enable_l2 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter3)
									begin
										next_state = S_CORRECT;
										enable_l3 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter4)
									begin
										next_state = S_CORRECT;
										enable_l4 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter5)
									begin
										next_state = S_CORRECT;
										enable_l5 = 1'b1;
										correct = 1'b1;
									end
								if (correct == 1'b0)
									next_state = S_INCORRECT;
								
							end
					 S_CORRECT: next_state = go ? S_CORRECT_WAIT : S_CORRECT; // Loop in current state until value is input
                S_CORRECT_WAIT: next_state = go ? S_CORRECT_WAIT :  // Loop in current state until go signal goes low
                S_INCORRECT_WAIT: next_state = go ? S_INCORRECT_WAIT : begin // Loop in current state until go signal goes low
							//begin
								//next_state = go ? S_INCORRECT_WAIT : S_LOAD_B; // Loop in current state until go signal goes low
								if(guess == letter1)
									begin
										next_state = S_CORRECT;
										enable_l1 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter2)
									begin
										next_state = S_CORRECT;
										enable_l2 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter3)
									begin
										next_state = S_CORRECT;
										enable_l3 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter4)
									begin
										next_state = S_CORRECT;
										enable_l4 = 1'b1;
										correct = 1'b1;
									end
								if(guess == letter5)
									begin
										next_state = S_CORRECT;
										enable_l5 = 1'b1;
										correct = 1'b1;
									end
								if (correct == 1'b0)
									next_state = S_INCORRECT;
								
							end
            default:     next_state = S_INCORRECT;
        endcase
    end // state_table
	

endmodule

module datapath();

endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
