module ROM(
    input logic [7:0] PC,
    output logic [31:0] instr
);

logic [31:0] ROM [63:0]; // Amount of lines of code in program

initial begin
    $readmemh("insmem_rv32.txt", ROM);
end

assign instr = ROM[PC[7:2]]; // Ignore bottom 2 bits because we increment PC by 4

endmodule