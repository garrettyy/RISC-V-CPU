module tb;

logic clk;
logic rst;
logic [31:0] IOReaddata;
logic IOWriteEn;
logic [31:0] IOWriteData;
logic [3:0] IOAddr;

always begin
    #5;
    clk = ~clk;
end

initial begin
    $dumpfile("waveform.vcd"); // Must dumpfile to view waveform
    $dumpvars(0, tb);
    clk = 0;
    IOReaddata = 0;
    rst = 1;
    #10;
    rst = 0;
    #1000;
    $finish;
end

RISCV u_RISCV (clk, rst, IOReaddata, IOWriteEn, IOWriteData, IOAddr);

endmodule