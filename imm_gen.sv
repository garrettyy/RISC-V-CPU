module imm_gen (
    input logic [31:0] instr,
    output logic [31:0] imm
);

logic [6:0] opcode;

assign opcode = instr[6:0];

localparam [6:0] OP_RTYPE = 7'b0110011;  // R-Type
localparam [6:0] OP_ITYPE = 7'b0010011;  // I-Type
localparam [6:0] OP_LW    = 7'b0000011;  // I-Type
localparam [6:0] OP_SW    = 7'b0100011;  // S-Type
localparam [6:0] OP_BEQ   = 7'b1100011;  // B-Type
localparam [6:0] OP_JAL   = 7'b1101111;  // J-Type
localparam [6:0] OP_LUI   = 7'b0110111;  // U-Type
localparam [6:0] OP_JALR  = 7'b1100111;  // I-Type
localparam [6:0] OP_AUIPC = 7'b0010111;  // U-Type

// Based on the opcode type, assign the immediate outputted by unscrambling bits in the instruction 
always_comb begin
    case (opcode) 
        OP_ITYPE:   begin imm = {{20{instr[31]}},instr[31:20]}; end
        OP_LW:      begin imm = {{20{instr[31]}},instr[31:20]}; end
        OP_SW:      begin imm = {{20{instr[31]}},instr[31:25],instr[11:7]}; end
        OP_BEQ:     begin imm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8], 1'b0}; end // Last bit is 0 because we only jump to even addresses
        OP_JAL:     begin imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; end // Last bit is 0 because we only jump to even addressess
        OP_LUI:     begin imm = {instr[31:12], 12'b0}; end 
        OP_JALR:    begin imm = {{20{instr[31]}},instr[31:20]}; end
        OP_AUIPC:   begin imm = {instr[31:12],12'b0}; end 
        default:    begin imm = 0; end
    endcase
end

endmodule