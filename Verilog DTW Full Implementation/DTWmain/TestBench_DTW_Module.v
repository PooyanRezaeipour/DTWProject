`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:44:01 12/25/2021
// Design Name:   DTWmadule
// Module Name:   E:/Bachlor_Project/Verliog Implementation/DTWmain/TestBench_DTW_Module.v
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

module TestBench_DTW_Module;

	// Inputs
	reg InSample;
	reg InTest;
	reg clk;
   reg Start;
	
	// Outputs
	wire valid;
	wire [5:0] Out_Euclidean_Distatnce;

	// Instantiate the Unit Under Test (UUT)
	DTWmadule uut (
		.InSample(InSample), 
		.InTest(InTest), 
		.Start(Start),
		.clk(clk), 
		.valid(valid), 
		.Out_Euclidean_Distatnce(Out_Euclidean_Distatnce)
	);

	initial begin
		// Initialize Inputs
		InSample = 0;
		InTest = 0;
		Start=0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		
		
      Start=1;
		#40;
		Start=0;
		
		
	end
      
		always #20 clk <= ~clk;  // 25MHz 
endmodule

