##------------------------------------------------------------------------------
##|
##| Filename    : makefile
##| Author      : Russell L Friesenhahn
##| Origin Date : 20130820
##| 
##------------------------------------------------------------------------------
##|
##| Abstract
##|
##|	makefile for uart core simulation
##|
##|
##------------------------------------------------------------------------------
##|
##| Modification History
##|
##|
##------------------------------------------------------------------------------
##|
##| References
##|
##|
##|
##------------------------------------------------------------------------------

default: uart_tb

cntr.o: ../../hdl/vhdl/cntr.vhd
	ghdl -a ../../hdl/vhdl/cntr.vhd

cntr_bhv.o: ../../hdl/vhdl/cntr_bhv.vhd cntr.o
	ghdl -a ../../hdl/vhdl/cntr_bhv.vhd

uart.o: ../../hdl/vhdl/uart.vhd
	ghdl -a ../../hdl/vhdl/uart.vhd

uart_bhv.o: ../../hdl/vhdl/uart_bhv.vhd uart.o cntr.o
	ghdl -a ../../hdl/vhdl/uart_bhv.vhd

uart_bfm_pkg.o: ../../../uart_bfm/hdl/vhdl/uart_bfm_pkg.vhd
	ghdl -a --work=uart_bfm ../../../uart_bfm/hdl/vhdl/uart_bfm_pkg.vhd

uart_bfm_pkgbdy.o: ../../../uart_bfm/hdl/vhdl/uart_bfm_pkgbdy.vhd uart_bfm_pkg.o
	ghdl -a --work=uart_bfm ../../../uart_bfm/hdl/vhdl/uart_bfm_pkgbdy.vhd

uart_tb.o: ../../tb/uart_tb.vhd ../../hdl/vhdl/uart.vhd uart_bfm_pkg.o uart_bfm_pkgbdy.o
	ghdl -a ../../tb/uart_tb.vhd

uart_tb.sim: uart.o uart_tb.o uart_bfm_pkg.o uart_bfm_pkgbdy.o uart_bhv.o cntr_bhv.o
	ghdl -e -o uart_tb.sim uart_tb 

sim: uart_tb.sim
	./uart_tb.sim

debug: uart_tb.sim
	./uart_tb.sim --wave=uart_tb.ghw
	gtkwave -a uart_tb.sav uart_tb.ghw&

clean:
	rm -rf work* *.o *.cf *.sim *.ghw
