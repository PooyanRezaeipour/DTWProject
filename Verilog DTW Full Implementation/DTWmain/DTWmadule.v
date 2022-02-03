`timescale 1ns / 1ps
module DTWmadule(
    input [11:0]InSample,
	 input [11:0]InTest,
	 input Start,
	 input StartReceiveSample,
	 input StartReceiveTest,
    input clk,
	 output reg valid,
	 output reg [11:0] Out_Euclidean_Distatnce
    );
reg startFlag=0;
reg wea_DTW_Matrix=0;
reg weaSample=0;
reg weaTest=0;
reg [2:0]waitForMin=3'd0;
reg [10:0]addrTest=11'd0;
reg [10:0]addrSample=11'd0;
reg [11:0]addrMatrixDTW=12'd0;   
reg finish=0 , start_read_mins=0;
reg valid_temp=0 , valid_min=0 , valid_Element=0 , active_Sample=0;     
reg [11:0]count_DTW_matrix=12'd0;
reg [11:0]count_DTW_matrix_write=12'd0;   //used for write address in DTW Matrix Ram
wire signed [11:0]Sample;         // output of the Sample Signal Ram
wire signed [11:0]Test;           // output of the Test Signal Ram
reg signed [11:0]regSample=0;     // input of the Sample Signal Ram
reg signed [11:0]regTest=0;       // input of the Test Signal Ram
reg signed [11:0]min=0;           // minimum of three elements which we named them 'temp'
reg signed [11:0]temp[2:0];
wire signed [11:0]out_matrixDTW;        // output of the DTW Matrix Ram
reg signed [11:0]DTW_Matrix_Element=0;  //  input of the DTW Matrix Ram 
reg [10:0]numSample=0;           // used to count the number of sample signal after removing silence
reg [10:0]numTest=0;
reg [11:0]maxNumDTW=11'd10;
reg flagDTWMatrix=0;          // zero for the first row , one for the second row
reg signed [11:0]sumSample=0;
reg signed [11:0]sumTest=0;
reg signed [11:0]meanSample=0;
reg signed [11:0]meanTest=0;
reg flagReceivingSample=0;
reg flagReceivingTest=0;
reg startNormSample=0;            // flag for starting normalization
reg startNormTest=0;
reg [2:0]countSampleNorm=0;
reg [2:0]countTestNorm=0;
reg finishNormTest=0;
reg finishNormSample=0;
//---------------------------------------------------------------------------------------------------------------------------------------------

//-----------------------------------------   
always @(posedge clk) valid <= finish;
always @(posedge clk)begin
       if(Start)begin
		   startFlag <= 1;
		 end
		 
		 if(startFlag && finishNormSample && finishNormTest)begin
		    startFlag <= 0;
		    start_read_mins <= 1;
		 end
       
       if(flagReceivingSample && flagReceivingTest && StartReceiveSample==0 && StartReceiveTest==0)begin
		   flagReceivingSample <= 0;
			flagReceivingTest <= 0;
		   meanSample <= sumSample/addrSample;
			meanTest <= sumTest/addrTest;
		   numSample <= addrSample;
		   numTest <= addrTest;
			addrSample <= 1;        
			addrTest <= 1;  
         startNormSample<=1;			
			startNormTest<=1;
		end
// ------------------------------------------------------- Initializing Test and Sample Rams Block and removing silence
     if(StartReceiveSample)begin      
	      flagReceivingSample <= 1;
		   if(InSample > 12'd2)begin     // threshold for removing silence
			  addrSample <= addrSample + 1;
			  sumSample <= sumSample + InSample;
			  regSample <= InSample;
			  weaSample <= 1;
			end else begin
			  weaSample <= 0;
			end
		end else begin
           weaSample <= 0;
      end		
		
		if(StartReceiveTest)begin
		   flagReceivingTest <= 1;
		   if(InTest > 12'd2)begin       // threshold for removing silence
		     addrTest <= addrTest + 1;
			  sumTest <= sumTest + InTest;
			  regTest <= InTest;
			  weaTest <= 1;
			end else begin
			  weaTest <= 0;
			end
		end else begin
		     weaTest <= 0;
		end
//---------------------------------------------------------------    Z-Normalization Sample Signal
     if(startNormSample)begin
	     if(addrSample < numSample+1)begin
		     if(countSampleNorm == 3'd0)begin
			    countSampleNorm <= countSampleNorm + 1;
			  end else if(countSampleNorm == 3'd1)begin
			    regSample <= Sample - meanSample;
			    countSampleNorm <= countSampleNorm + 1;
			  end else if(countSampleNorm == 3'd2)begin
			    countSampleNorm <= countSampleNorm + 1;
			    weaSample <= 1;
			  end else if(countSampleNorm == 3'd3)begin
			    weaSample <= 0;
			    countSampleNorm <= 0;
			    addrSample <= addrSample + 1;
			  end
			  
	     end else if(addrSample == numSample+1)begin
		      finishNormSample <= 1;
		      startNormSample <= 0;
            addrSample <= 1;
        end		 		   
	  end 
//---------------------------------------------------------------    Z-Normalization Test Signal
     if(startNormTest)begin
	     if(addrTest < numTest+1)begin
		     if(countTestNorm == 3'd0)begin
			    countTestNorm <= countTestNorm + 1;
			  end else if(countTestNorm == 3'd1)begin
			    regTest <= Test - meanTest;
			    countTestNorm <= countTestNorm + 1;
			  end else if(countTestNorm == 3'd2)begin
			    countTestNorm <= countTestNorm + 1;
			    weaTest <= 1;
			  end else if(countTestNorm == 3'd3)begin
			    weaTest <= 0;
			    countTestNorm <= 0;
			    addrTest <= addrTest + 1;
			  end
			  
	     end else if(addrTest == numTest+1)begin
		      finishNormTest <= 1;
		      startNormTest <= 0;
            addrTest <= 1;
        end		 		   
	  end 
//----------------------------------------------------------------- Start Reading Sample and Test for calculating the DTW Matrix		
// ---------------------------------------------------------------- Addressing Sample Signal Ram	
  if(StartReceiveTest==0 && StartReceiveSample==0)begin
	  if(valid_Element && active_Sample && finish==0 && addrSample < numSample+1)begin  //sample is considered to be in column of DTW Matrix
   		addrSample <= addrSample +1;
         active_Sample<=0;
			
		end else if(addrSample == numSample+1) begin
		   addrSample <= 1;
	   end
		  
		  if(addrTest == numTest && addrTest != 0 && startNormTest == 0 )begin
		  active_Sample <= 1;
		  end
		  if(valid_Element && addrTest == numTest )begin 
		  active_Sample <= 0;
		  end
// -----------------------------------------------------------------  Addressing Test Signal Ram		  
		if(valid_Element && finish==0 && addrTest < numTest+1)begin  // test is considered to be in row of DTW Matrix
		   addrTest <= addrTest +1;
			
	   end else if(addrTest == numTest+1) begin   
	   	addrTest <= 1;
   	end
	end
// --------------------------------------------------	calculating the minimum of three temprory values after reading them
		if(valid_temp && finish==0)begin
		  valid_temp <= 0;
		  if(temp[0]<temp[1])begin
		     if(temp[2]<temp[0])begin
			     min <= temp[2];
				  valid_min<=1;          // if valid_min=1 , then min has been found, now we can calculate the element of DTW matrix
				 end else begin
				  min<= temp[0];
				  valid_min<=1;
				end 
	     end else begin
		      if(temp[2]<temp[1])begin
			     min <= temp[2];
				  valid_min<=1;
			   end else begin
			     min <= temp[1];
				  valid_min<=1;
				end
		  end
      end
//-------------------------------------------------   calculating each elemnt of DTW matrix after finding the min
		if(valid_min && finish==0)begin
		   valid_min <= 0;
			if(Sample > Test)begin
		     DTW_Matrix_Element <=  min + (Sample - Test);  
			  valid_Element <= 1;
		  end else begin
		     DTW_Matrix_Element <=  min + (Test - Sample);  
			  valid_Element <= 1;	  
		  end
		end
//----------------------------------- Addressing the DTW matrix, Tasks: 1) Read three temps for calculating min of them  2) Write the result

//-------- 1) Read three temps for calculating min, note that this proccess will take 1 to 5 clocks depending on the location of the current element
       if(start_read_mins && finish==0)begin
		   wea_DTW_Matrix <= 0;
		 	maxNumDTW <= (numSample*numTest);	   
			if(addrSample == 11'd1 && addrTest == 11'd1)begin
			   temp[0]<= 0;
				temp[1]<= 12'd30;
				temp[2]<= 12'd30;	
				start_read_mins <= 0;
				valid_temp <= 1;
			end else if(addrSample == 11'd1)begin
			   temp[0]<= 12'd30;
				temp[1]<= 12'd30;				
				temp[2]<= DTW_Matrix_Element; 	
				start_read_mins <= 0;
				valid_temp <= 1;
			end else if(addrTest == 11'd1 )begin  
			   if(waitForMin == 3'd0)begin
               waitForMin<= waitForMin + 3'd1;				
             	if(flagDTWMatrix == 0)begin			
						addrMatrixDTW <= addrMatrixDTW + numTest;
					end else begin    // for the case flagDTWMatrix == 1
					   addrMatrixDTW <= addrMatrixDTW - numTest + 12'd1;
					end					
            end else if(waitForMin == 3'd1)begin	
				   waitForMin <= waitForMin + 2'd1;
            end else if(waitForMin == 3'd2)begin
   				waitForMin <= 3'd0 ;
					temp[0]<= 12'd30;
					temp[1]<= 12'd30;				
					temp[2]<= out_matrixDTW;	
					start_read_mins <= 0;
					valid_temp <= 1;
			   end
				
		   end else begin
				  if(flagDTWMatrix == 0)begin	
   					if(waitForMin == 3'd0)begin
							addrMatrixDTW <= count_DTW_matrix_write - 12'd1; 
							waitForMin <= waitForMin +1;
						end else if(waitForMin == 3'd1) begin
							addrMatrixDTW <= count_DTW_matrix_write + numTest - 12'd1;
							waitForMin <= waitForMin +1;  
						end else if(waitForMin == 3'd2)begin
							addrMatrixDTW <= count_DTW_matrix_write + numTest; 
							waitForMin <= waitForMin +1;
							temp[0] <= out_matrixDTW;  
						end else if(waitForMin == 3'd3) begin  
							temp[1] <= out_matrixDTW;
							waitForMin <= waitForMin +1; 				
						end else if(waitForMin == 3'd4)begin
							start_read_mins <= 0;
							waitForMin <= 0;
							temp[2] <= out_matrixDTW;
							valid_temp <= 1;
						end
					end else begin            // for the case flagDTWMatrix == 1
					    if(waitForMin == 3'd0)begin
							addrMatrixDTW <= count_DTW_matrix_write - 12'd1; 
							waitForMin <= waitForMin +1;
						end else if(waitForMin == 3'd1) begin
							addrMatrixDTW <= count_DTW_matrix_write - numTest ;
							waitForMin <= waitForMin +1;  
						end else if(waitForMin == 3'd2)begin
							addrMatrixDTW <= count_DTW_matrix_write - numTest - 12'd1; 
							waitForMin <= waitForMin +1;
							temp[0] <= out_matrixDTW;  
						end else if(waitForMin == 3'd3) begin  
							temp[1] <= out_matrixDTW;
							waitForMin <= waitForMin +1; 				
						end else if(waitForMin == 3'd4)begin
							start_read_mins <= 0;
							waitForMin <= 0;
							temp[2] <= out_matrixDTW;
							valid_temp <= 1;
						end
						
					end
			  end		
		 end 			 

//----------------------------------------------------------------- 2) write elemets
		  if(finish==0 && count_DTW_matrix < maxNumDTW )begin
		    if(valid_Element)begin
			   count_DTW_matrix <= count_DTW_matrix + 12'd1;
		      valid_Element <= 0;
			   wea_DTW_Matrix <= 1;
		      addrMatrixDTW <= count_DTW_matrix_write;
				if(count_DTW_matrix_write < (numTest - 12'd1) )begin
				   flagDTWMatrix <= 0;
					count_DTW_matrix_write <= count_DTW_matrix_write + 12'd1;
				end else if(count_DTW_matrix_write < ((2* numTest) - 12'd1)) begin
				   flagDTWMatrix <= 1;
					count_DTW_matrix_write <= count_DTW_matrix_write + 12'd1;
				end else begin
				   flagDTWMatrix <= 0;
				   count_DTW_matrix_write <= 0;
				end
		    end 
			 
		  end else begin
		     count_DTW_matrix <= 0;
			  count_DTW_matrix_write <= 0;
			  start_read_mins <= 0;
			  wea_DTW_Matrix <= 0;
			  finish <= 1;
		  end
		
//-------------------------------
    if(wea_DTW_Matrix)begin  
	    wea_DTW_Matrix <= 0;
       start_read_mins <= 1;	
       if(addrMatrixDTW == ((2* numTest) - 12'd1))begin
          addrMatrixDTW<=0;
       end 		 
    end	 

//------------------------------  finish (Euclidean_Distatnce is ready)
    if(finish)begin
	   Out_Euclidean_Distatnce <= out_matrixDTW;
	 end 
//------------------------------	 
	 
end

DTW_Matrix DTW_Matrix_Memory (
  .clka(clk), // input clka
  .wea(wea_DTW_Matrix), // input [0 : 0] wea
  .addra(addrMatrixDTW), // input [11 : 0] addra
  .dina(DTW_Matrix_Element), // input [11 : 0] dina
  .douta(out_matrixDTW) // output [11 : 0] douta
);
Ram_Test Test_Memory (
  .clka(clk), // input clka
  .wea(weaTest), // input [0 : 0] wea
  .addra(addrTest), // input [10 : 0] addra
  .dina(regTest), // input [11 : 0] dina
  .douta(Test) // output [11 : 0] douta
);
Ram_Sample Sample_Memory (
  .clka(clk), // input clka
  .wea(weaSample), // input [0 : 0] wea
  .addra(addrSample), // input [10 : 0] addra
  .dina(regSample), // input [11 : 0] dina
  .douta(Sample) // output [11 : 0] douta
);
endmodule
 