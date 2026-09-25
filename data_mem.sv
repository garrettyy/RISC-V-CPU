`timescale 1ns / 1ps

module data_memory(
    input logic clk, IsMemWrite,
    input logic [31:0] data_address, write_data,
    output logic [31:0] read_data
);

// 4 Kilobytes of memory
logic [31:0] memory [1023:0]; 


initial begin
    $readmemh("datamem_h.txt", memory);
end

always_comb begin 
    read_data = 0;
    if (data_address < 4096)
        read_data = memory[data_address[11:2]]; 
end

always_ff @(posedge clk) begin
    if (IsMemWrite && data_address < 4096)
        memory[data_address[11:2]] <= write_data;
end

endmodule
