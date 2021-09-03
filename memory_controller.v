module memory_controller(clock, get_card, reset, card_in, card_out, mem_address, mem_clock, mem_write_enable, game_ready, card_ready);

	input clock;
	input get_card;
	input reset;
	input [7:0] card_in;
	
	output reg [7:0] card_out;
	output reg [5:0] mem_address;
	output reg mem_clock;
	output reg mem_write_enable;
	output reg game_ready;
	output reg card_ready;
	
	reg lfsr_enable;
	
	reg [7:0] card_one;
	reg [5:0] card_one_address;
	reg [7:0] card_two;
	reg [5:0] card_two_address;
	
	
	reg [4:0] est_f;
	reg [4:0] est_a;

	wire [5:0] seed_counter;
	reg seed_counter_reset;
	
	reg mem_counter_clock;
	reg mem_counter_reset;
	wire [5:0]mem_counter;
	
	reg loop_counter_clock;
	reg loop_counter_reset;
	wire [2:0]loop_counter;
	
	wire [5:0]random;
	
	parameter inicio = 5'b00000;
	parameter inicio2 = 5'b00001;
	parameter shuffle1 = 5'b00010;
	parameter shuffle2 = 5'b01101;
	parameter shuffle3 = 5'b00011;
	parameter shuffle4 = 5'b00100;
	parameter shuffle5 = 5'b00101;
	parameter shuffle6 = 5'b00110;
	parameter shuffle7 = 5'b00111;
	parameter shuffle8 = 5'b01000;
	parameter shuffle9 = 5'b01001;
	parameter shuffle10 = 5'b01010;
	parameter shuffle11 = 5'b01011;
	parameter inc1 = 5'b01100;
	parameter inc2 = 5'b01110;
	parameter reset_addr = 5'b01111;
	parameter reset_addr2 = 5'b10000;
	parameter ready = 5'b10001;
	parameter get1 = 5'b10010;
	parameter get2 = 5'b10011;
	parameter shuffle12 = 5'b10100;
	parameter no_cards = 5'b10101;
	parameter loop_counter1 = 5'b10110;
	parameter loop_counter2 = 5'b10111;
	
	LFSR random_generator(
		.clock(clock),
		.enable(lfsr_enable),
		.seed(seed_counter),
		.LFSR(random)
		);
	
		
	counter mem_counter_block(
		.clock(mem_counter_clock),
		.reset(mem_counter_reset),
		.number(mem_counter)
		);
		defparam mem_counter_block.bits = 6;
		
	counter loop_counter_block(
		.clock(loop_counter_clock),
		.reset(loop_counter_reset),
		.number(loop_counter)
		);
		defparam loop_counter_block.bits = 3;
		
		
	counter seed_counter_block(
		.clock(clock),
		.reset(seed_counter_reset),
		.number(seed_counter)
		);
		defparam seed_counter_block.bits = 6;
	
	//decodificador de proximo estado
	always @ (*)
	begin
		case (est_a)
			inicio:
				est_f = inicio2;
			inicio2:
				est_f = shuffle1;
			shuffle1:
				est_f = shuffle2;
			shuffle2:
				est_f = shuffle3;
			shuffle3:
				est_f = shuffle4;
			shuffle4:
				est_f = shuffle5;
			shuffle5:
				est_f = shuffle6;
			shuffle6:
				est_f = shuffle7;
			shuffle7:
				est_f = shuffle8;
			shuffle8:
				est_f = shuffle9;
			shuffle9:
				est_f = shuffle10;
			shuffle10:
				est_f = shuffle11;
			shuffle11:
				est_f = shuffle12;
			shuffle12:
				est_f = inc1;
			inc1:
				est_f = inc2;
			inc2:
			begin
				if ((mem_counter >51) && (game_ready == 1'b1)) est_f = no_cards;
				else if (mem_counter > 51) est_f = loop_counter1;
				else if (game_ready == 1'b0) est_f = shuffle1;
				else est_f = ready;
			end
			reset_addr:
				est_f = reset_addr2;
			reset_addr2:
			begin
				if (loop_counter == 3'b111) est_f = ready;
				else est_f = shuffle1;
			end
			ready:
			begin
				if (get_card == 1'b1) est_f = get1;
				else est_f = ready;
			end
			get1:
				est_f = get2;
			get2:
			begin
				if (get_card == 1'b0) est_f = inc1;
				else est_f = get2;
			end
			no_cards:
				est_f = no_cards;
			loop_counter1:
			begin
				est_f = loop_counter2;
			end
			loop_counter2:
			begin
				est_f = reset_addr;
			end
			default:
				est_f = no_cards;
			endcase
	end
	
	always @ (*) 
	begin
		if (loop_counter == 3'b111) game_ready = 1'b1;
		else game_ready = 1'b0;
		card_ready = 1'b0;
		card_out = 0;
		lfsr_enable = 1'b0;
		mem_address = 0;
		mem_clock = 1'b0;
		mem_write_enable = 1'b0;
		mem_counter_reset = 1'b0;
		mem_counter_clock = 1'b0;
		loop_counter_reset = 1'b0;
		loop_counter_clock = 1'b0;
		seed_counter_reset = 1'b0;
		case (est_a)
			inicio:
				begin
				// Altera
				card_ready = 1'b0;
				mem_counter_reset = 1'b1;
				loop_counter_reset = 1'b1;
				seed_counter_reset = 1'b0;
				end
			inicio2:
			begin
				lfsr_enable = 1'b1;
				mem_counter_reset = 1'b0;
				loop_counter_reset = 1'b0;
			end
			shuffle1:
			begin
				lfsr_enable = 1'b1;
				mem_address = mem_counter;
				if (random > 51)
					card_two_address = random - 51;
				else
					card_two_address = random;
			end
			shuffle2:
			begin
				lfsr_enable = 1'b1;
				mem_address = mem_counter;
				card_one_address = mem_counter;
				mem_clock = 1'b1;
			end
			shuffle3:
			begin
				lfsr_enable = 1'b1;
				card_one = card_in;
				mem_clock = 1'b0;
			end
			shuffle4:
			begin
				lfsr_enable = 1'b1;
				mem_address = card_two_address;
			end
			shuffle5:
			begin
				lfsr_enable = 1'b1;
				mem_clock = 1'b1;
				mem_address = card_two_address;
			end
			shuffle6:
			begin
				lfsr_enable = 1'b1;
				card_two = card_in;
				card_out = card_one;
				mem_address = card_two_address;
				mem_clock = 1'b0;
			end
			shuffle7:
			begin
				lfsr_enable = 1'b1;
				mem_write_enable = 1'b1;
				card_out = card_one;
				mem_address = card_two_address;
			end
			shuffle8:
			begin
				mem_write_enable = 1'b1;
				mem_clock = 1'b1;
				card_out = card_one;
				mem_address = card_two_address;
			end
			shuffle9:
			begin
				mem_clock = 1'b0;
				card_out = card_one;
				mem_address = card_two_address;
			end
			shuffle10:
			begin
				mem_write_enable = 1'b1;
				mem_address = card_one_address;
				card_out = card_two;
			end
			shuffle11:
			begin
				mem_write_enable = 1'b1;
				mem_address = card_one_address;
				card_out = card_two;
				mem_clock = 1'b1;
			end
			shuffle12:
			begin
				mem_address = card_one_address;
				card_out = card_two;
				mem_clock = 1'b0;
				mem_write_enable = 1'b0;
			end
			inc1:
			begin
				card_ready = 1'b0;
				mem_counter_clock = 1'b1;
			end
			inc2:
			begin
				mem_counter_clock = 1'b0;
			end
			reset_addr:
			begin
				mem_counter_reset = 1'b1;
			end
			reset_addr2:
			begin
				mem_counter_reset = 1'b0;
			end
			ready:
			begin
				card_ready = 1'b0;
				mem_address = mem_counter;
			end
			get1:
			begin
				mem_address = mem_counter;
				mem_clock = 1'b1;
			end
			get2:
			begin
				mem_address = mem_counter;
				card_ready = 1'b1;
				mem_clock = 1'b0;
			end
			no_cards:
			begin
				mem_counter_reset = 1'b1;
				loop_counter_reset = 1'b1;
				seed_counter_reset = 1'b1;
			end
			loop_counter1:
			begin
				loop_counter_clock = 1'b1;
			end
			loop_counter2:
			begin
				loop_counter_clock = 1'b0;
			end
			default:
			begin
				card_ready = 1'b0;
				game_ready = 1'b0;
				card_out = 0;
				lfsr_enable = 1'b0;
				mem_address = 0;
				mem_clock = 1'b0;
				mem_write_enable = 1'b0;
				mem_address = 0;
				mem_counter_reset = 1'b0;
				mem_counter_clock = 1'b0;
				loop_counter_reset = 1'b0;
				loop_counter_clock = 1'b0;
				seed_counter_reset = 1'b1;
			end
				
				
				
		endcase
	end
	
	always @(posedge clock)
		begin
			if (reset) est_a<=inicio;
			else est_a<=est_f;
		end
	


endmodule