`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:52:11 01/23/2022
// Design Name:   DTWmadule
// Module Name:   E:/Bachlor_Project/Verilog Silence Remove/DTWmain/TestBench_DTW_Full.v
// Project Name:  DTWmain
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DTWmadule
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestBench_DTW_Full;

	// Inputs
	reg signed[11:0]InSample;
	reg signed[11:0]InTest;
	reg Start;
	reg StartReceiveSample;
	reg StartReceiveTest;
	reg clk;

	// Outputs
	wire valid;
	wire signed[11:0] Out_Euclidean_Distatnce;

	// Instantiate the Unit Under Test (UUT)
	DTWmadule uut (
		.InSample(InSample), 
		.InTest(InTest), 
		.Start(Start), 
		.StartReceiveSample(StartReceiveSample), 
		.StartReceiveTest(StartReceiveTest), 
		.clk(clk), 
		.valid(valid), 
		.Out_Euclidean_Distatnce(Out_Euclidean_Distatnce)
	);

	initial begin
		// Initialize Inputs
		InSample = 0;
		InTest = 0;
		Start = 0;
		StartReceiveSample = 0;
		StartReceiveTest = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		//InSample= 4'd3;
		#80;
		StartReceiveSample = 1;        // sample initialization
		InSample= 12'd3;
		#40;
		InSample= 12'd1;
		#40;
		InSample= 12'd2;
		#40;
		InSample= 12'd3;
		#40;
		InSample= 12'd4;
		#40;
		InSample= 12'd5;
		#40;
		InSample= 12'd6;
		#40;
		StartReceiveSample = 0;
		//InTest=4'd4;
		#80;
		
		StartReceiveTest = 1;        // test initialization
		InTest=12'd4;
		#40;
		InTest=12'd3;
		#40;
		InTest=12'd2;
		#40;
		InTest=12'd3;
		#40;
		InTest=12'd4;
		#40;
		InTest=12'd5;
		#40;
      StartReceiveTest = 0;
		#40;
		
		
		#80;                    // Start Calculating DTW Matrix
	   Start=1;
		#40;
		Start=0;
		
	end
	
	
     always #20 clk <= ~clk;  // 25MHz    
endmodule

