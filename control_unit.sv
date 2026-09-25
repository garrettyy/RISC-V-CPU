module control_unit(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic RegWrite, ALUSrc1, ALUSrc2, MemWrite, MemtoReg, MemRead, Branch, lui, Jump, PcSrc,
    output logic [3:0] AluOp
);

logic [9:0] controls;
assign {RegWrite, ALUSrc1, ALUSrc2, MemWrite, MemtoReg, MemRead, Branch, lui, Jump, PcSrc} = controls;

localparam [6:0] OP_RTYPE = 7'b0110011;  // R-Type
localparam [6:0] OP_ITYPE = 7'b0010011;  // I-Type
localparam [6:0] OP_LW    = 7'b0000011;  // Load Word
localparam [6:0] OP_SW    = 7'b0100011;  // Store Word
localparam [6:0] OP_BEQ   = 7'b1100011;  // B-Type
localparam [6:0] OP_JAL   = 7'b1101111;  // J-Type
localparam [6:0] OP_LUI   = 7'b0110111;  // U-Type
localparam [6:0] OP_JALR  = 7'b1100111;  // I-Type
localparam [6:0] OP_AUIPC = 7'b0010111;  // U-Type


// Based on opcode, raise certain flags and set AluOp
always_comb begin
    case (opcode) 
        OP_RTYPE:   begin controls = 10'b1000000000; AluOp = {funct7[5],funct3}; end
        OP_ITYPE:   begin controls = 10'b1010000000; AluOp = {1'b0,funct3}; end
        OP_LW:      begin controls = 10'b1010110000; AluOp = 4'b0000; end
        OP_SW:      begin controls = 10'b0011000000; AluOp = 4'b0000; end
        OP_BEQ:     begin controls = 10'b0000001000; AluOp = 4'b1000; end // look into doing more branch instructions
        OP_JAL:     begin controls = 10'b1110000010; AluOp = 4'b0000; end 
        OP_LUI:     begin controls = 10'b1000000100; AluOp = 4'b0000; end 
        OP_JALR:    begin controls = 10'b1110000011; AluOp = 4'b0000; end
        OP_AUIPC:   begin controls = 10'b1110000000; AluOp = 4'b0000; end
        default:    begin controls = 10'b0000000000; AluOp = 4'b0000; end
    endcase 
end

endmodule