vlib work

set ::env(AOU_CORE_HOME) "."

vlog -sv -f RTL/filelist.f
vlog -sv -f tb/filelist.f
vsim -voptargs=+acc -c work.tb_top

run -all
examine -radix hex /tb_top/u_slave/mymemory