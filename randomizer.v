module randomizer(clock, reset, letter1, letter2, letter3, letter4);
    input clock, reset;
    reg [1:0] random;
    output reg [5:0] letter1, letter2, letter3, letter4;
    
    lsfr l1 (
      .out(random),
      .clk(clock),
      .rst(reset)
      );
      
    always @(*)
        case (random)
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
  input clk, rst;
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
