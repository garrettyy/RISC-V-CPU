module RISCV (
    input logic clk,
    input logic rst,
    input logic [31:0] IOReadData,
    output logic IOWriteEn,
    output logic [31:0] IOWriteData,
    output logic [3:0] IOAddr
);

logic [7:0] PC;
logic [31:0] instr;
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic RegWrite, ALUSrc1, ALUSrc2, MemWrite, MemtoReg, MemRead, Branch, lui, Jump, PcSrc, all_zero;
logic [3:0] AluOp;
logic [4:0] read_addr1;
logic [4:0] read_addr2;
logic [4:0] write_addr;
logic [31:0] write_data_reg;
logic [31:0] addr1_data;
logic [31:0] addr2_data;
logic [31:0] imm;
logic [31:0] A;
logic [31:0] B;
logic [31:0] result;
logic [31:0] data_address;
logic [31:0] write_data;
logic [31:0] read_data;
logic [31:0] data_out;
logic [31:0] constant;
logic [31:0] target;
logic [31:0] data_IO_mem;
logic isIO, IsMemWrite;

// Muxes for dataflow
assign A = ALUSrc1 ? PC : addr1_data;
assign B = ALUSrc2 ? imm : addr2_data;
assign write_data_reg = Jump ? PC+4 : (lui ? imm : data_out); // Must store PC + 4 to return to for JAL and JALR instructions
assign data_out = MemtoReg ? data_IO_mem : result;

// Break down the instruction for regfile and control unit
assign read_addr1 = instr[19:15]; 
assign read_addr2 = instr[24:20];
assign write_addr = instr[11:7];
assign funct3 = instr[14:12];
assign opcode = instr[6:0];
assign funct7 = instr[31:25];

// Mux for updating PC with branch and jump logic
assign constant = ((Branch & all_zero) | Jump) ? imm : 4;
assign target = PcSrc ? addr1_data : PC;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        PC <= 0;
    end else begin
        PC <= target + constant;
    end
end

// Instantiate modules and assign ports
ROM u_ROM (.*);
reg_file u_reg_file (.*);
control_unit u_control_unit(.*);
imm_gen u_imm_gen(.*);
ALU u_ALU(.*);
data_memory u_data_memory(.*);

assign write_data = addr2_data; // This is to match the naming of modules
assign data_address = result;

// IO logic that intercepts part of address space and routes to IO with muxes
assign isIO = (result[31:4] == 28'h0007ff) ? 1 : 0;
assign data_IO_mem = isIO ? IOReadData : read_data; // Reads from IO when in IO address space
assign IsMemWrite = MemWrite & ~isIO; // IsMemWrite means writing to actual memory in cpu
assign IOWriteEn = isIO & MemWrite; 
assign IOWriteData = write_data;
assign IOAddr = result[4:0];

endmodule