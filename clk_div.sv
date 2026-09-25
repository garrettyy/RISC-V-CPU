module clk_div ( 
    input clk,
    input rst,
    output clk_en 
);
    reg [3:0] clk_count;

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            clk_count <= 0;
        end else if (clk_count == 4'd9) begin
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    // Pulse high once every 10 clock cycles (adjustable)
    assign clk_en = (clk_count == 4'd9);

endmodule