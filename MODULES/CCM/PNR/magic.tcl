
drc off
gds readonly true
gds rescue false


gds read /root/Work/vlsi/pdks/pdk/nangate45/gds/NangateOpenCellLibrary.gds

lef read /root/Work/vlsi/pdks/pdk/nangate45/lef/NangateOpenCellLibrary.tech.lef
lef read /root/Work/vlsi/pdks/pdk/nangate45/lef/NangateOpenCellLibrary.lef

def read output/token_bus_routed.def

load token_bus
select top cell

gds write gds/final_token_bus_top.gds

drc on
drc check
set drc_errors [drc list count total]
puts "TOTAL DRC ERRORS: $drc_errors"

set drc_log [open "gds/drc_signoff.log" w]
puts $drc_log "DRC Error Count: $drc_errors"
if {$drc_errors > 0} {
    puts $drc_log [drc list count]
}
close $drc_log


extract path gds
extract do local
extract all
ext2spice lvs
ext2spice subcircuits on
ext2spice subcircuit top on

ext2spice prefix gds/
ext2spice token_bus

exit