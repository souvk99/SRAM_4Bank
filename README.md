# Assignment 2(ii): 4-Bank 64 KB SRAM

## 1. Architectural Sizing & Organization

This module models a **4-bank SRAM** with a cumulative storage capacity of **64 KB** ($524,288$ bits):

- **Number of Banks**: 4 independent physical banks (`bank_sel[1:0]` selects Banks 0, 1, 2, or 3).
- **Dimensions per Bank**: $256 \text{ rows} \times 512 \text{ bits} = 131,072 \text{ bits} = 16\text{ KB}$ per bank.
- **Total Capacity**: $4 \times 16\text{ KB} = 64\text{ KB}$ ($65,536\text{ bytes}$).
- **Word Width**: 32-bit (4-byte) single read/write port.
- **Words per Bank**: $16\text{ KB} / 4\text{ Bytes} = 4,096\text{ words}$ (12-bit address `addr[11:0]` per bank).
- **Access Timing**: Synchronous write (1 clock edge), synchronous read (registered output with 1-cycle latency).

---

## 2. Port Definitions

| Port | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 bit | System clock |
| `cs` | Input | 1 bit | Chip Select (active high) |
| `write_en` | Input | 1 bit | 1 = Write operation, 0 = Read operation |
| `bank_sel` | Input | 2 bits | Bank select `[1:0]` (0 to 3) |
| `addr` | Input | 12 bits | Word address within selected bank (`[11:0]`) |
| `write_data` | Input | 32 bits | Write data bus |
| `read_data` | Output | 32 bits | Synchronous read data bus |

---

## 3. Verification & Isolation Checks

The testbench (`tb_sram_4bank.v`) conducts comprehensive verification:
1. **Bank-Wise Operation**: Writes unique data words to distinct addresses in all 4 banks, then reads each back to verify functional correctness.
2. **Bank Isolation Stress Test**: Writes 4 completely distinct hexadecimal values to the **exact same memory address (`addr = 10`)** across all 4 banks. It then reads back all 4 banks at `addr = 10` to prove that `bank_sel` properly isolates banks with zero aliasing or cross-talk.

---

## 4. How to Run Simulation

```bash
# Compile
iverilog -o sim_sram_4bank.vvp sram_4bank.v tb_sram_4bank.v

# Execute
vvp sim_sram_4bank.vvp
```

To view waveforms:
```bash
gtkwave sram_4bank.vcd
```

