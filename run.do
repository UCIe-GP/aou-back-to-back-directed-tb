vlib work

set env(AOU_CORE_HOME) "."

vlog -sv -f RTL/filelist.f

vsim -c work.AOU_TOP

run -all
exit