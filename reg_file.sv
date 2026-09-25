module reg_file(
    input logic clk, RegWrite,
    input logic [4:0] read_addr1,
    input logic [4:0] read_addr2,
    input logic [4:0] write_addr,
    input logic [31:0] write_data_reg,
    output logic [31:0] addr1_data,
    output logic [31:0] addr2_data
);

logic [31:0] regs [31:0];

assign addr1_data = (read_addr1 == 0) ? 0 : regs[read_addr1];
assign addr2_data = (read_addr2 == 0) ? 0 : regs[read_addr2];

always_ff @(posedge clk) begin
    if (RegWrite)
        regs[write_addr] <= write_data_reg;
end
endmodule