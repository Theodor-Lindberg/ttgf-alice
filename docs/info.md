## How it works

Alice is an 8-bit unsigned calculator. The current value is held in an accumulator and is continuously shown on `uo_out`.

| Signal | Use |
| --- | --- |
| `ui_in[7:0]` | Unsigned number input, 0–255 |
| `uio_in[0]` | Enter button |
| `uio_in[3:1]` | 3-bit operation selector |
| `uo_out[7:0]` | Current calculator value |
| `uio[7]` | Output used for the error/status flag |
| `clk`, `rst_n` | Clock and active-low reset |

Operation codes are:

| `uio_in[3:1]` | Operation |
| --- | --- |
| `000` | No operation |
| `001` | Add |
| `010` | Subtract |
| `011` | Multiply |
| `100` | Sine lookup |
| `101` | Square-root lookup |
| `110` | Exponential lookup ($e^x$) |
| `111` | Natural-log lookup ($\ln(x)$) |

For a binary operation, enter the first number, press Enter, select the operation and press Enter, then put the second number on `ui_in` and press Enter. The result replaces the accumulator, so another operation can be chained. For a lookup operation, enter a number and then select the lookup operation and press Enter; the current number is used as the ROM address and the ROM result replaces it.

Enter is sampled on the rising clock edge. Release it and let it be sampled low before pressing it again. The calculator uses 8-bit results, so arithmetic overflow and underflow wrap modulo $2^8$. Resetting `rst_n` low clears the current value and calculator state. `ena` is currently unused.

The sine ROM maps all 256 input addresses to an unsigned, offset sine wave, approximately $y=127.5\left(1+\sin\left(2\pi x/255\right)\right)$, quantized to 8 bits. Thus, the output ranges from about 0 to 255 rather than using signed negative values.

## How to test

The testbench checks addition, subtraction, multiplication, chained operations, and the square-root, exponential, natural-log, and sine lookups.

## External hardware

No external components are required. The inputs and operation selector can be driven by switches, a host, or a testbench; the Tiny Tapeout platform supplies the clock and reset. `uio[7]` is configured as an output for the error/status flag, while `uio[6:0]` are inputs. The Enter input has no mechanical-button debounce, so a physical button may need external debouncing.
