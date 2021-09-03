module timer(clock, timeout, enable, flag);

parameter bits = 32;

input clock;
input [bits - 1:0] timeout;
input enable;

output reg flag;

reg [bits - 1:0] counter;
reg [bits - 1:0] counter_next;


always @ (*)
begin
	counter_next = counter - 1;
end

always @ (posedge clock)
begin
	if (enable)
	begin
		counter <= timeout;
		flag <= 0;
	end
	else if (counter != 0)
	begin
		counter <= counter_next;
	end
	else
	begin
		flag <= 1;
	end
end

endmodule
	