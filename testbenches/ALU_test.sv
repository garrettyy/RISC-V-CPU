`timescale 1ns / 1ps

module ALU_test();
    // Inputs
    reg [31:0]	a;
    reg [31:0]	b;
    reg [3:0]	aluop;
    
    // Outputs
    wire [31:0]	result;
    wire		zero;
    
    // Test clock
    reg			clk ; // in this version we do not really need the clock
    
    // Expected outputs
    reg [31:0]	exp_result;
    wire		exp_zero;
    
    // Vector and Error counts
    reg [10:0]	vec_cnt, err_cnt;
    
    // TO DO:
    // Define an array called 'testvec' that is wide enough to hold the inputs:
    //   aluop, a, b
    // and the expected output
    //   exp_result
    // of the ALU. Make sure the array has at least 100 entries.
    // Note: we will not store 'exp_zero' in this array.
    reg [99:0] testvec [99:0];
    
    // The test clock generation
    always				// process always triggers
    begin
    clk = 1; #50;		// clk is 1 for 50 ns
    clk = 0; #50;		// clk is 0 for 50 ns
    end					// generate a 100 ns clock
    
    // Initialization
    initial
    begin
        $dumpfile("waves.vcd");
        $dumpvars(0, ALU_test); 
        // TO DO:
        // Read the content of the file testvectors_hex.txt into the
        // array testvec. The file contains values in hexadecimal format
        $readmemh("testvectors_riscv.txt", testvec);
        err_cnt = 0; // number of errors
        vec_cnt = 0; // number of vectors
    end
    
    // TO DO:
    // calculate the value of 'exp_zero' from the 'exp_result'
    assign exp_zero = (exp_result == 0) ? 1 : 0;
    // Tests
    always @ (posedge clk)		// trigger with the test clock
    begin
        // Wait 20 ns, so that we can safely apply the inputs
        #20;
        
        // Assign the signals from the testvec array
        {aluop,a,b,exp_result} = testvec[vec_cnt];

        // Wait another 60ns after which we will be at 80ns
        #60;
        
        // Check if output is not what we expect to see
        if ((result !== exp_result) | (zero !== exp_zero))
        begin
            // Display message
            $display("Error at %5d ns: Aluop %b a = %h b = %h", $time, aluop,a,b);	// %h displays hex
            $display("       %h (%h expected)",result,exp_result);
            $display(" Zero: %b (%b expected)",zero,exp_zero);							// %b displays binary
            err_cnt = err_cnt + 1;																// increment error count
        end
        
        vec_cnt = vec_cnt + 1;																	// next vector
        
        // We use === so that we can also test for X
        if ((testvec[vec_cnt][99:96] === 4'bxxxx))
        begin
            // End of test, no more entries...
            $display ("%d tests completed with %d errors", vec_cnt, err_cnt);
            
            // Wait so that we can see the last result
            #20;
            
            // Terminate simulation
            $finish;
        end
    end
    
    // TO DO:
    // Instantiate the Unit Under Test (UUT)
    ALU ALU_DUT (.A(a),.B(b), .AluOp(aluop), .result(result), .all_zero(zero));
    // bad_ALU ALU_DUT(a,b,aluop,result,zero);
endmodule
