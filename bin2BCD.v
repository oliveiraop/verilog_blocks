module bin2BCD (binario_in, unidade, dezena, centena, milhar);

	parameter bits_in = 8;
	
	input [bits_in-1:0] binario_in;
	output [3:0] unidade, dezena, centena, milhar;
	reg [15:0] bcd;
	reg [bits_in-1:0] binario;

	reg [7:0] i;
	
	assign unidade = bcd[3:0];
	
	assign dezena = bcd[7:4];
	
	assign centena = bcd[11:8];
	
	assign milhar = bcd[15:12];
	
	always @ (binario_in) 
	begin
		bcd = 0;
		binario = binario_in;

		for (i = 0; i < bits_in; i = i+1) //run for 8 iterations
            begin
                bcd = {bcd[14:0],binario[bits_in-1-i]}; //concatenation
                    
                //if a hex digit of 'bcd' is more than 4, add 3 to it.  
                if(i < 7 && bcd[3:0] > 4) 
                    bcd[3:0] = bcd[3:0] + 3;
                if(i < 7 && bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
                if(i < 7 && bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;  
					 if(i < 7 && bcd[15:12] > 4)
                    bcd[15:12] = bcd[15:12] + 3; 
            end
	end
	
endmodule