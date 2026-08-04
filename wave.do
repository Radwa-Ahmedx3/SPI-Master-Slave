onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /wrapper_slave_tb_final/clk
add wave -noupdate /wrapper_slave_tb_final/rstn
add wave -noupdate /wrapper_slave_tb_final/ss_n
add wave -noupdate /wrapper_slave_tb_final/mosi
add wave -noupdate /wrapper_slave_tb_final/miso
add wave -noupdate /wrapper_slave_tb_final/dut/rx_valid
add wave -noupdate /wrapper_slave_tb_final/dut/tx_valid
add wave -noupdate /wrapper_slave_tb_final/dut/tx_data
add wave -noupdate /wrapper_slave_tb_final/dut/rx_data
add wave -noupdate -expand -group {SPI Slave} -color Cyan /wrapper_slave_tb_final/dut/slave1/read_addr_flag
add wave -noupdate -expand -group {SPI Slave} -color Cyan /wrapper_slave_tb_final/dut/slave1/internal_register
add wave -noupdate -expand -group {SPI Slave} -color Cyan -radix unsigned /wrapper_slave_tb_final/dut/slave1/counter
add wave -noupdate -expand -group {SPI Slave} -color Cyan -radix unsigned /wrapper_slave_tb_final/dut/slave1/counter_4_read_data
add wave -noupdate -expand -group {SPI Slave} -color Cyan /wrapper_slave_tb_final/dut/slave1/cs
add wave -noupdate -expand -group {SPI Slave} -color Cyan /wrapper_slave_tb_final/dut/slave1/ns
add wave -noupdate -expand -group RAM -color White /wrapper_slave_tb_final/dut/ram1/read_adr
add wave -noupdate -expand -group RAM -color White /wrapper_slave_tb_final/dut/ram1/write_adr
add wave -noupdate -expand -group RAM -color White /wrapper_slave_tb_final/dut/ram1/mem_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {220000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {197050 ps} {288508 ps}
