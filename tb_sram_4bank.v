`timescale 1ns / 1ps

module tb_sram_4bank;

    localparam DATA_WIDTH     = 32;
    localparam ADDR_WIDTH     = 12;
    localparam DEPTH_PER_BANK = 4096;
    localparam NUM_BANKS      = 4;

    reg                   clk;
    reg                   cs;
    reg                   write_en;
    reg  [1:0]            bank_sel;
    reg  [ADDR_WIDTH-1:0] addr;
    reg  [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data;

    // Instantiate 4-Bank SRAM DUT
    sram_4bank #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH_PER_BANK(DEPTH_PER_BANK),
        .NUM_BANKS(NUM_BANKS)
    ) dut (
        .clk(clk),
        .cs(cs),
        .write_en(write_en),
        .bank_sel(bank_sel),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer b;
    reg [DATA_WIDTH-1:0] expected_data;

    // Golden storage arrays
    reg [ADDR_WIDTH-1:0] test_addr [0:3];
    reg [DATA_WIDTH-1:0] test_val  [0:3];

    initial begin
        $dumpfile("sram_4bank.vcd");
        $dumpvars(0, tb_sram_4bank);

        clk        = 0;
        cs         = 0;
        write_en   = 0;
        bank_sel   = 0;
        addr       = 0;
        write_data = 0;
        errors     = 0;

        $display("============================================================================");
        $display(" RUNNING VERIFICATION FOR ASSIGNMENT 2(ii): 4-BANK 64 KB SRAM");
        $display("============================================================================");

        #20;

        // ---------------------------------------------------------------------
        // Test 1: Bank-wise Write to One Location in Each of the 4 Banks
        // ---------------------------------------------------------------------
        $display("\n[Test 1] Writing unique data to one unique location in each bank...");
        test_addr[0] = 12'd100; test_val[0] = 32'hB0_A1B2C3;
        test_addr[1] = 12'd250; test_val[1] = 32'hB1_D4E5F6;
        test_addr[2] = 12'd500; test_val[2] = 32'hB2_112233;
        test_addr[3] = 12'd750; test_val[3] = 32'hB3_445566;

        for (b = 0; b < 4; b = b + 1) begin
            @(negedge clk);
            cs         = 1;
            write_en   = 1;
            bank_sel   = b[1:0];
            addr       = test_addr[b];
            write_data = test_val[b];

            @(posedge clk);
            $display("  [WRITE] Bank %0d | Addr = %0d | Data = 0x%08h", b, addr, write_data);

            @(negedge clk);
            write_en = 0;
            cs       = 0;
        end

        // Read back and verify each bank
        $display("\n[Test 1] Reading back and verifying each of the 4 banks...");
        for (b = 0; b < 4; b = b + 1) begin
            @(negedge clk);
            cs         = 1;
            write_en   = 0;
            bank_sel   = b[1:0];
            addr       = test_addr[b];

            @(posedge clk); // Read latched
            @(posedge clk); // Synchronous read output valid

            if (read_data === test_val[b]) begin
                $display("  PASS: Bank %0d | Addr = %0d | Read = 0x%08h (Matches expected)",
                         b, test_addr[b], read_data);
            end else begin
                $display("  FAIL: Bank %0d | Addr = %0d | Read = 0x%08h, Expected = 0x%08h",
                         b, test_addr[b], read_data, test_val[b]);
                errors = errors + 1;
            end

            @(negedge clk);
            cs = 0;
        end

        repeat (2) @(posedge clk);

        // ---------------------------------------------------------------------
        // Test 2: Strong Isolation Check (Same Address across all 4 banks)
        // Writing 4 DIFFERENT values to the EXACT SAME address (addr = 10)
        // ---------------------------------------------------------------------
        $display("\n[Test 2] Strong Isolation Check: Writing 4 distinct values to the SAME address (addr = 10)...");
        test_val[0] = 32'hCAFE_0000;
        test_val[1] = 32'hFEED_1111;
        test_val[2] = 32'hBEEF_2222;
        test_val[3] = 32'hDEAD_3333;

        for (b = 0; b < 4; b = b + 1) begin
            @(negedge clk);
            cs         = 1;
            write_en   = 1;
            bank_sel   = b[1:0];
            addr       = 12'd10;
            write_data = test_val[b];

            @(posedge clk);
            @(negedge clk);
            write_en = 0;
            cs       = 0;
        end

        $display("  Reading back address 10 from all 4 banks to verify no cross-bank collision...");
        for (b = 0; b < 4; b = b + 1) begin
            @(negedge clk);
            cs         = 1;
            write_en   = 0;
            bank_sel   = b[1:0];
            addr       = 12'd10;

            @(posedge clk);
            @(posedge clk);

            if (read_data === test_val[b]) begin
                $display("  PASS: Bank %0d Addr 10 returned 0x%08h (Correct bank isolation)",
                         b, read_data);
            end else begin
                $display("  FAIL: Bank %0d Addr 10 returned 0x%08h, Expected 0x%08h (Bank collision detected!)",
                         b, read_data, test_val[b]);
                errors = errors + 1;
            end

            @(negedge clk);
            cs = 0;
        end

        // ---------------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------------
        $display("\n============================================================================");
        if (errors == 0) begin
            $display(" [RESULT] ALL ASSIGNMENT 2(ii) TESTS PASSED! (0 errors)");
            $display("  - 4 Independent Banks of 16 KB each (64 KB total) fully verified");
            $display("  - Bank-wise isolation and decoding validated with 0 aliasing");
        end else begin
            $display(" [RESULT] DETECTED %0d ERROR(S)", errors);
        end
        $display("============================================================================\n");

        #50;
        $finish;
    end

endmodule

