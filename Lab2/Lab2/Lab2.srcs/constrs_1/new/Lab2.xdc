## Lab2.xdc  -  CEG3155 Lab 2, Nexys A7-100T pin assignments (Table 5)

## 100 MHz clock (display refresh only)
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

## Push-buttons: GClock = BTNC, GReset = BTNU
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { GClock }];
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { GReset }];
## GClock comes from a push-button, not a clock-capable pin
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets GClock_IBUF];

## Operand switches: A = SW7..SW4, B = SW3..SW0
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { OperandA[3] }];
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { OperandA[2] }];
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { OperandA[1] }];
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { OperandA[0] }];
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { OperandB[3] }];
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { OperandB[2] }];
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { OperandB[1] }];
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { OperandB[0] }];

## OperationSelect = SW9..SW8 (1.8 V bank)
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS18 } [get_ports { OperationSelect[1] }];
set_property -dict { PACKAGE_PIN T8 IOSTANDARD LVCMOS18 } [get_ports { OperationSelect[0] }];

## MuxOut = LED15..LED8
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[7] }];
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[6] }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[5] }];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[4] }];
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[3] }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[2] }];
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[1] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[0] }];

## Status LEDs: CarryOut = LED0, ZeroOut = LED1, OverflowOut = LED2
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { CarryOut }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { ZeroOut }];
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { OverflowOut }];

## Seven-segment cathodes, active-low. seg = (g,f,e,d,c,b,a) to match the
## Appendix F patterns, so seg[0] = CA (segment a) ... seg[6] = CG (segment g)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg[0] }];   # CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg[1] }];   # CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg[2] }];   # CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg[3] }];   # CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg[4] }];   # CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg[5] }];   # CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg[6] }];   # CG

## Seven-segment anodes AN0..AN7
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { an[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { an[1] }];
set_property -dict { PACKAGE_PIN T9 IOSTANDARD LVCMOS33 } [get_ports { an[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { an[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { an[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { an[5] }];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { an[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { an[7] }];