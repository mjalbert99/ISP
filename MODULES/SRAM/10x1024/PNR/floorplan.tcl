set TOP "SRAM"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../constraints/sram.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/nangate45"
set TECH_LEF  "${PDK_ROOT}/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "${PDK_ROOT}/lef/NangateOpenCellLibrary.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/libs/NangateOpenCellLibrary_typical.lib"
set LIB_FILE_FST  "${PDK_ROOT}/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_ROOT "/root/Work/vlsi/pdks/pdk/nangate45/sram_10x1024"
set SRAM_LEF "${SRAM_ROOT}/sram_10x1024.lef"
set SRAM_LIB_SLW "${SRAM_ROOT}/sram_10x1024_TT_1p1V_25C.lib"
set SRAM_LIB_FST "${SRAM_ROOT}/sram_10x1024_FF_1p25V_0C.lib"

read_lef $TECH_LEF
read_lef $CELL_LEF

read_lef $SRAM_LEF

read_liberty -max $LIB_FILE_SLW
read_liberty -max $SRAM_LIB_SLW

read_liberty -min $LIB_FILE_FST
read_liberty -min $SRAM_LIB_FST

read_verilog ${SYNTH_DIR}/output/typ/${TOP}_typ_netlist.v
link_design $TOP

read_sdc $SDC_PATH


file mkdir output


initialize_floorplan -die_area {0 0 245 300} \
                     -core_area {10 10 235 290} \
                     -site FreePDK45_38x28_10R_NP_162NW_34O



make_tracks

# rtl_macro_placer -write_macro_placement macros.txt
place_macro -macro_name {sram} -location {22 22}


set_io_pin_constraint -pin_names {clk0 csb0 din0 addr0 clk1 csb1 din1 addr1} -region left:70-250
set_io_pin_constraint -pin_names {dout1} -region right:-20-80

place_pins -hor_layers metal3 -ver_layers metal2 \
            -min_distance 5 \
            -corner_avoidance 10.0

insert_tiecells "LOGIC1_X1/Z" -prefix "TIE_HIGH_"
insert_tiecells "LOGIC0_X1/Z" -prefix "TIE_LOW_"
place_tapcells
place_endcaps


add_global_connection -net VDD -pin_pattern {^VDD$} -power
add_global_connection -net VSS -pin_pattern {^VSS$} -ground

add_global_connection -net VDD -pin_pattern {^vdd$} -power -inst_pattern {sram}
add_global_connection -net VSS -pin_pattern {^gnd$} -ground -inst_pattern {sram}

set_voltage_domain -power VDD -ground VSS

define_pdn_grid -name "Core" -pins {metal4 metal5}


# # # Connects to STD rows
 add_pdn_stripe -grid "Core" \
                -followpins \
                -layer metal1 \
                -width 0.08 \
                -snap_to_grid


# # --- PDN MESH ---
add_pdn_stripe -grid "Core" \
               -layer metal4 \
               -width 0.5 \
               -pitch 26 \
               -offset 12.5 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal5 \
               -width 0.5 \
               -pitch 26 \
               -offset 0.0 \
               -spacing 1.6


add_pdn_connect -grid "Core" -layers {metal1 metal4}
add_pdn_connect -grid "Core" -layers {metal4 metal5}

# SRAM
define_pdn_grid -name "OpenRAM_Grid" -macro -instance "sram" -halo {0 0 0 0}

add_pdn_connect -grid "OpenRAM_Grid" -layers {metal3 metal4}
add_pdn_connect -grid "OpenRAM_Grid" -layers {metal4 metal5}

pdngen

write_def output/${TOP}_floorplanned.def

puts "\[INFO\] Floorplan completed successfully. File generated: output/${TOP}_floorplanned.def"