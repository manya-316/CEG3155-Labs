## -----------------------------------------------------------------------------
## keyboardController.xdc : constraints for the Nexys A7-100T (XC7A100T-1CSG324C)
## CEG 3155 Lab 4, keyboard controller. Pins from Table 4 of the lab handout.
## -----------------------------------------------------------------------------

## Bitstream configuration required by the Artix-7
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## Global clock: 100 MHz on-board oscillator (CLK100MHZ)
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { GClock }]
create_clock -period 10.00 [get_ports GClock]

## Global reset: CPU_RESETN push button (active low)
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { GReset }]

## PS/2 signals recreated by the on-board PIC24 from the USB keyboard on J5
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { KeyboardClock }]
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports { KeyboardInfo }]

## 7-segment display: cathodes CA..CG and decimal point (active low)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { DP }]

## 7-segment display: anodes AN0..AN7 (active low)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { AN[0] }]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { AN[1] }]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { AN[2] }]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { AN[3] }]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { AN[4] }]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { AN[5] }]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { AN[6] }]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { AN[7] }]

## BCD1: left hex digit of the scan code on LD15..LD12
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { BCD1[3] }]
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { BCD1[2] }]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { BCD1[1] }]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { BCD1[0] }]

## BCD2: right hex digit of the scan code on LD7..LD4
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { BCD2[3] }]
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { BCD2[2] }]
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { BCD2[1] }]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { BCD2[0] }]

## Notes
## * No ALLOW_COMBINATORIAL_LOOPS waiver: the SR element of digitalFilter is
##   a clocked flip-flop, so the design has no combinational loop.
## * Table 4 also lists ModeSwitch (SW0, J15), LED_KEY_HELD (LD0, H17) and
##   LED_CHORD (LD1, K15). They are not in the Table 3 specification and are
##   not ports of this design, so they are not constrained here.