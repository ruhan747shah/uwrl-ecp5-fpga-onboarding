# FPGA Onboarding

This project is a simple LED blinker written in SystemVerilog for my Waterloo Reality Labs FPGA onboarding.

## Design

The clock is 25 MHz, so one clock cycle is 40 ns.

For a full 1 second blink:

- LED stays in each state for 0.5 s
- `HALF_PERIOD_CYCLES = 12,500,000`

The counter needs 24 bits because `2^24` is large enough to count to 12.5 million.

## Testing

I tested the design with:

- `HALF_PERIOD_CYCLES = 7` → PASS
- `HALF_PERIOD_CYCLES = 6` → PASS
- `HALF_PERIOD_CYCLES = 1` → PASS

I also changed the timing on purpose so the LED toggled one clock late. The testbench caught the error.

## Waveform

In GTKWave I checked:

- clock period = 40 ns
- LED changes every 280 ns
- full LED cycle = 560 ns

## Synthesis

Yosys used:

- 25 `TRELLIS_FF`
- 12 `CCU2C`
- 11 `LUT4`
- 2 `PFUMX`

`TRELLIS_FF` stores state like the counter bits.

`CCU2C` is used for the counter arithmetic.

`LUT4` is used for logic.

`PFUMX` is used for signal selection.

## Commands

```bash
iverilog -g2012 -Wall -s tb_top -o build/tb_top rtl/top.sv sim/tb_top.sv
vvp build/tb_top
gtkwave build/blink.vcd

```bash
yosys -l build/synth.log -p 'read_verilog -sv rtl/top.sv; synth_ecp5 -top top -json build/top.json; check -assert; stat'
```