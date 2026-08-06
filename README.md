# SPI Master-Slave Integration with Single-Port RAM
An end-to-end Verilog implementation of an **SPI (Serial Peripheral Interface) Master-Slave Protocol** integrated with a **Single-Port RAM Block**. 

This repository contains the complete RTL design, testbenches, timing logs, and simulation waveform results.

# Project Overview
This project demonstrates a complete digital IC block where an SPI Master communicates with an SPI Slave, which in turn acts as a memory controller interface for an internal Single-Port RAM module.

# Key Features:
  Protocol: Standard 4-wire SPI (`CS_n`, `SCLK`, `MOSI`, `MISO`).
  RAM Architecture: Synchronous Single-Port RAM ($256 \times 8$ depth/width).
  Control FSM: Master & Slave State Machines designed to handle 10-bit SPI frame structures (Opcode + Address/Data).
  Self-Checking Testbench: Automated verification with dynamic output matching logic.

# System Architecture & Operation
The system processes 10-bit control frames transmitted serially over `MOSI`:
  `2'b00` ── Write Address setup
  `2'b01` ── Write Data into specified RAM address
  `2'b10` ── Read Data request from RAM to `MISO` line

# Simulation & Verification Results
The design was simulated and verified using **ModelSim**.

# Testbench verdict
STEP 1: Write Address (0xAA / 170) Loaded into Slave
STEP 2: Write Data (0x55) successfully committed to RAM[170]
STEP 3: Read Address (0xAA) Loaded into Slave
STEP 4: Read Data (0x55) captured on MISO line

SUCCESS: Read Data matches Written Data (0x55)!
STATUS : All Four Verification Cases Passed Successfully!

# How to Run Simulation
>> Important: All RTL source files inside RTL last updated/ MUST be compiled before running the testbench compilation.

1. Clone the repository: git clone [https://github.com/Radwa-Ahmedx3/SPI-Master-Slave.git](https://github.com/Radwa-Ahmedx3/SPI-Master-Slave.git)
2. Open ModelSim and set your working directory to the repository folder.
3. Compile Order (Strict):
   - Compile design modules first: RAM.v, SPI_Master.v, SPI_Slave.v
   - Compile the top-level testbench: SPI_Master_Slave_Integration.v
4. Run Simulation:
   - Clock period is configured to 10 ns (F_clk = 100 MHz).
   - Execute in ModelSim Transcript window:
     
                  vsim work.SPI_Integration_tb
                  add wave -r /*
                  run -all
     
# Repository Structure
├── Integration test bench results/   # Waveform screenshots and execution logs
├── RTL last updated/                 # Verilog Source Files (RAM.v, SPI_Master.v, SPI_Slave.v)
├── SPI_Master_Slave_Integration.v    # Top-level Integration module & TB
└── README.md                         # Project Documentation
