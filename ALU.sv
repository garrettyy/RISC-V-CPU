`timescale 1ns / 1ps

module ALU(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic [3:0] AluOp,
    output logic [31:0] result,
    output logic all_zero
);

localparam ADD  = 4'b0000;
localparam SUB  = 4'b1000;
localparam SLL  = 4'b0001;
localparam SLT  = 4'b0010;
localparam SLTU = 4'b0011;
localparam ALU_XOR  = 4'b0100;
localparam SRL  = 4'b0101;
localparam ALU_OR   = 4'b0110;
localparam ALU_AND  = 4'b0111;
localparam SRA  = 4'b1101;


logic [32:0] adder_result;
logic subtract;
logic overflow;

assign all_zero = (result==0);
// Create wire to be reused so adder is reused and zero extend ~B to not interfere with CO bit
assign adder_result =  A + (subtract ? {1'b0, ~B} : B) + subtract;
// Overflow happens if A and B have different signs and the result sign is flipped.
assign overflow = (A[31] ^ B[31]) & (A[31] ^ adder_result[31]);

// Flag is needed to force subtraction for SLT and SLTU
assign subtract = (AluOp == 4'b1000) || (AluOp == 4'b0011) || (AluOp == 4'b0010);

always_comb begin
    case(AluOp)
            ADD: result = adder_result[31:0];         
            SUB: result = adder_result[31:0];         
            SLL: result = A<<B[4:0];           
            SLT: result = {31'b0,adder_result[31]^overflow}; // Accounts for overflow case
            SLTU: result = {31'b0,~adder_result[32]}; 
            ALU_XOR: result = A^B;                  
            SRL: result = A>>B[4:0];                
            SRA: result = $signed(A)>>>B[4:0];        
            ALU_OR: result = A|B;                   
            ALU_AND: result = A&B;                  
            default: result = 0;
    endcase
end

endmodule
 