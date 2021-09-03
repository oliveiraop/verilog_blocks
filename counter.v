module counter(clock, reset, number);

	parameter bits = 5;
	parameter first = 0;


	input clock;
	input reset;
	
	output reg [bits-1:0] number;
	reg [bits-1:0] number_next;
	
	always @ (*)
	begin
		number_next = number+1;
	end
		
	always @ (posedge clock, posedge reset)
	begin
		if (reset) number <= first;
		else number <= number_next;
	end
	
endmodule