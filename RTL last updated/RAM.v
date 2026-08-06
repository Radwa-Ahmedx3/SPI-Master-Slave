module RAM(clk,rstn,tx_valid,rx_valid,dout,din);
parameter addr_width=8;
parameter data_width=8;
parameter mem_depth=256;
    
input clk,rstn,rx_valid;
input [data_width+1:0] din;
output reg tx_valid;
output reg [data_width-1:0] dout;

reg [data_width-1:0] read_adr;
reg [data_width-1:0] write_adr;
reg [data_width-1:0] mem_array [0:mem_depth-1];
integer i;

always @(posedge clk or negedge rstn) begin
//////////////////////////////printing///////////////////////////////
if (rx_valid) begin
    $display("RAM @%0t: rx_valid=1 din=%b opcode=%b", $time, din, din[data_width+1:data_width]);
    case (din[data_width+1:data_width])
    2'b00: begin
        write_adr <= din[data_width-1:0];
        $display("  -> set write_adr = %0d", din[data_width-1:0]);
    end
    2'b01: begin
        mem_array[write_adr] <= din[data_width-1:0];
        $display("  -> write mem[%0d] <= %02h", write_adr, din[data_width-1:0]);
    end
 2'b10: begin
    read_adr <= din[data_width-1:0];
    dout <= mem_array[din[data_width-1:0]];  // Keep this assignment
    tx_valid <= 1'b1;
end
    2'b11: begin
        tx_valid <= 1'b1;
        $display("  -> opcode 11, tx_valid=1");
    end
    endcase
end



//////////////////////////////////////////
    if (~rstn) begin
        for(i=0 ; i<mem_depth ; i=i+1) begin
        	mem_array[i] <= 0;
    	end
        dout <= 0;
        tx_valid <= 0; 
        write_adr <= 0;
        read_adr <= 0;
    end

    else begin
        tx_valid <= 0; 
        if (rx_valid) begin 
            case (din [data_width+1:data_width])
            2'b00: write_adr <= din [data_width-1:0];
            2'b01: begin
                    mem_array[write_adr] <= din[data_width-1:0];
                end
                
                2'b10: begin
                    read_adr <= din[data_width-1:0];
 
                    dout     <= mem_array[din[data_width-1:0]]; 
                    tx_valid <= 1'b1;
                end
                
                2'b11: begin

                    tx_valid <= 1'b1;
                end
            endcase
    	end
    end
end
endmodule 