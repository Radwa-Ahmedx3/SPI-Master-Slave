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

// NEW: dedicated shift register and bit counter for the 10-bit frame
reg [data_width+1:0] shift_reg; // 10-bit shift register
reg [3:0] bit_cnt;              // counts 0..10

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        // reset everything that was previously reset
        miso <= 0;
        read_addr_flag <= 0;
        rx_valid <= 0;
        rx_data <= 0;
        counter <= 0;
        counter_4_read_data <= 0;

        // new regs
        shift_reg <= 0;
        bit_cnt <= 0;
    end
    else begin
        // If chip select is high, reset the per-frame state so capture restarts cleanly.
        if (ss_n) begin
            shift_reg <= 0;
            bit_cnt <= 0;
            rx_valid <= 0;
            counter <= 0;
            counter_4_read_data <= 0;
            read_addr_flag <= 0;
            // keep miso at 0 when not selected
            miso <= 0;
        end
        else begin
            // Capture bits in every state that expects serial input.
            // Use a single shift register that shifts left and inserts MOSI at LSB:
            // This correctly assembles MSB-first frames into shift_reg so after 10 samples
            // shift_reg == transmitted 10-bit word.

            // --- Modified framing: assert rx_valid on the SAME cycle we sample the 10th bit ---
            if (bit_cnt < (data_width + 2 - 1)) begin
                // still collecting bits (haven't received the 10th bit yet)
                shift_reg <= { shift_reg[data_width:0], mosi }; // shift in new bit
                bit_cnt <= bit_cnt + 1;
                rx_valid <= 1'b0;
            end
            else begin
                // This posedge is sampling the 10th bit. Assemble final word and pulse rx_valid for one cycle.
                rx_data <= { shift_reg[data_width:0], mosi }; // final 10-bit word (old shift_reg + current MOSI)
                rx_valid <= 1'b1;
                bit_cnt <= 0;
                shift_reg <= 0;
                // rx_valid will be cleared on the next collecting cycle (above).
            end

            // Now handle read_data transmit (miso) and other state-dependent behaviour
            case (cs)
                check: begin
                    // nothing else needed here: capture done above
                end

                write: begin
                    // no special action here; rx_valid will indicate full frame to RAM
                    // Keep counter for backward compat (not used for framing anymore)
                    counter <= 0;
                end

                read_addr: begin
                    if (rx_valid) begin
                        read_addr_flag <= 1'b1;
                    end
                end

                read_data: begin
                    // Shift out tx_data directly on MISO during read_data state
                    if (counter_4_read_data < 8) begin
                        miso <= tx_data[7 - counter_4_read_data];
                        counter_4_read_data <= counter_4_read_data + 1;
                    end
                    else if (counter_4_read_data == 8) begin
                        counter_4_read_data <= 0;
                    end

                    read_addr_flag <= 0;
                end

                default: begin
                    counter <= 0;
                    counter_4_read_data <= 0;
                end
            endcase
        end
    end
end
endmodule 