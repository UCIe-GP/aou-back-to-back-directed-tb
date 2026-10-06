# Delete old compiled units to prevent stale simulation binaries
if [file exists work] {
    vdel -all -lib work
}
vlib work

set ::env(AOU_CORE_HOME) "."

vlog -sv -f RTL/filelist.f
vlog -sv -f tb/filelist.f

vsim -voptargs=+acc -c work.tb_top

run -all
quit -f