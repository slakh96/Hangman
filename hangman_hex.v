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
