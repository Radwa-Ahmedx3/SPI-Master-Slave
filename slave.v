module slave (clk,rstn,ss_n,miso,mosi,rx_data,rx_valid,tx_data,tx_valid);
parameter [2:0] idle=000;
parameter [2:0] check=001;
parameter [2:0] write=010;
parameter [2:0] read_addr=011;
parameter [2:0] read_data=100;
reg [2:0] cs,ns;
reg read_addr_flag;

parameter data_width=8;

input mosi,clk,rstn,ss_n,tx_valid;
input [data_width-1:0] tx_data;
output reg miso,rx_valid;
output reg [data_width+1:0] rx_data;

reg [data_width+1:0] internal_register;
reg [3:0] counter;
reg [3:0] counter_4_read_data;
reg first_bit;

always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		cs <= idle;
		read_addr_flag <= 0;
	end

	else begin
		cs <= ns;
	end
end

always @(*)begin
	case (cs)
	idle:begin
		if(ss_n) ns=idle;
		else ns=check;
	end
	check:begin
		if(ss_n) ns=idle;
		else begin
			if (~mosi) ns = write;

			else if (mosi) begin
				if (read_addr_flag) ns=read_data;
				else ns=read_addr;
			end
		end
	end
	write:begin
		if(ss_n) ns=idle;
		else ns=write;
	end
	read_data:begin
		if(ss_n) ns=idle;
		else ns=read_data;
	end
	read_addr:begin
		if(ss_n) ns=idle;
		else ns=read_addr;
	end
	default: ns=idle;
	endcase
end


always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		miso <= 0;
		read_addr_flag <= 0;
		rx_valid <= 0;
		rx_data <= 0;
		counter <= 0;
		counter_4_read_data <= 0;
		internal_register <= 0;
	end

	else begin
		case(cs)
			check:begin
				internal_register [9] <= mosi;
				counter  <= counter + 1;
			end
			write: begin
                if (counter < 10) begin
                   internal_register[9 - counter] <= mosi;
                    counter  <= counter + 1;
                    rx_valid <= 0;
                end 
                else begin 
                    counter  <= 0;
                    rx_data  <= internal_register; 
                    rx_valid <= 1;
                end
            end
			read_addr: begin
                if (counter < 10) begin
                    internal_register[9 - counter] <= mosi;
                    counter  <= counter + 1;
                    rx_valid <= 0;
                end 
                else begin 
                    counter <= 0;
                    rx_data  <= internal_register; 
                    rx_valid <= 1;
                    read_addr_flag <= 1; 
                end
            end
			read_data: begin
				if (counter < 10) begin
					internal_register[9 - counter] <= mosi;
					counter <= counter + 1;
					rx_valid <= 0;
				end
				else begin 
					counter <= 0;
					rx_data <= internal_register;
					rx_valid <= 1;
				end
				if (tx_valid) begin
					internal_register   <= tx_data;
					miso <= tx_data[7]; 
					counter_4_read_data <= 1;
				end 
				else if (counter_4_read_data > 0 && counter_4_read_data <= 7) begin
					miso <= internal_register[7 - counter_4_read_data];
					counter_4_read_data <= counter_4_read_data + 1;
				end 
				else if (counter_4_read_data == 8) begin
					counter_4_read_data <= 0;
				end
				read_addr_flag <= 0;
			end
			default:begin
				counter <= 0;
				read_addr_flag <=0;
				counter_4_read_data <= 0;
			end
		endcase
	end
end
endmodule