module LFSR(clock, enable, seed, LFSR);


	input clock;
	input [5:0] seed;
	input enable;
	
	
	output reg [5:0] LFSR = 0;
	
	
	reg XNOR;
	
		
	always @(posedge clock)
	begin
		if (enable)	LFSR <= {LFSR[4:0], XNOR};
		else LFSR <= seed;
	end
	
	always @(*)
	begin
		XNOR = LFSR[4] ^~ LFSR[2];
	end
	
endmodule