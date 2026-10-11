`timescale 1ns / 1ps

//==============================================================================
// Assignment 2(ii): 4-Bank SRAM (Total Capacity: 64 KB)
//
// Specification & Sizing:
//   - Total capacity : 64 KB = 65,536 Bytes = 524,288 bits
//   - Multi-bank     : 4 independent banks (selected via bank_sel[1:0])
//   - Bank size      : 256 rows x 512 bits = 131,072 bits = 16 KB per bank
//   - Data port width: 32 bits (4 bytes)
//   - Words per bank : 16 KB / 4 Bytes = 4,096 words per bank (ADDR_WIDTH = 12)
//                      (Total across 4 banks = 16,384 words x 32 bits = 64 KB)
//   - Access timing  : Synchronous write, synchronous registered read
//==============================================================================

module sram_4bank #(
    parameter DATA_WIDTH     = 32,
    parameter ADDR_WIDTH     = 12,       // 2^12 = 4,096 words per bank
    parameter DEPTH_PER_BANK = 4096,
    parameter NUM_BANKS      = 4
)(
    input  wire                   clk,
    input  wire                   cs,         // Chip select (active high)
    input  wire                   write_en,   // 1 = Write, 0 = Read
    input  wire [1:0]             bank_sel,   // 2-bit bank selector (Bank 0, 1, 2, 3)
    input  wire [ADDR_WIDTH-1:0]  addr,       // Local address inside the selected bank
    input  wire [DATA_WIDTH-1:0]  write_data, // 32-bit write data bus
    output reg  [DATA_WIDTH-1:0]  read_data   // 32-bit synchronous read data bus
);

    // 4 independent physical memory bank arrays
    reg [DATA_WIDTH-1:0] bank_mem_0 [0:DEPTH_PER_BANK-1];
    reg [DATA_WIDTH-1:0] bank_mem_1 [0:DEPTH_PER_BANK-1];
    reg [DATA_WIDTH-1:0] bank_mem_2 [0:DEPTH_PER_BANK-1];
    reg [DATA_WIDTH-1:0] bank_mem_3 [0:DEPTH_PER_BANK-1];

    always @(posedge clk) begin
        if (cs) begin
            if (write_en) begin
                // Synchronous Bank-Wise Write
                case (bank_sel)
                    2'b00: bank_mem_0[addr] <= write_data;
                    2'b01: bank_mem_1[addr] <= write_data;
                    2'b10: bank_mem_2[addr] <= write_data;
                    2'b11: bank_mem_3[addr] <= write_data;
                endcase
            end
            else begin
                // Synchronous Bank-Wise Read (1-cycle read latency)
                case (bank_sel)
                    2'b00: read_data <= bank_mem_0[addr];
                    2'b01: read_data <= bank_mem_1[addr];
                    2'b10: read_data <= bank_mem_2[addr];
                    2'b11: read_data <= bank_mem_3[addr];
                endcase
            end
        end
    end

endmodule

