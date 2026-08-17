set TOP "D_CPU"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../constraints/d_cpu.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/nangate45"

set TECH_LEF  "${PDK_ROOT}/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "${PDK_ROOT}/lef/NangateOpenCellLibrary.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/libs/NangateOpenCellLibrary_typical.lib"
set LIB_FILE_FST  "${PDK_ROOT}/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_ROOT "/root/Work/vlsi/pdks/pdk/nangate45/sram_20x2048"

set BNR_LEF "../../BNR/PNR/metals/BNR_abstract.lef"
set BNR_LIB "../../BNR/PNR/metals/BNR.lib"

set WBG_LEF "../../WBG/PNR/metals/WBG_abstract.lef"
set WBG_LIB "../../WBG/PNR/metals/WBG.lib"

set DEMOSAIC_LEF "../../DEMOSAIC/PNR/metals/DEMOSAIC_abstract.lef"
set DEMOSAIC_LIB "../../DEMOSAIC/PNR/metals/DEMOSAIC.lib"

read_lef $TECH_LEF
read_lef $CELL_LEF


read_liberty -max $LIB_FILE_SLW
read_liberty -min $LIB_FILE_FST

read_lef $BNR_LEF
read_liberty -max $BNR_LIB
read_liberty -min $BNR_LIB

read_lef $WBG_LEF
read_liberty -max $WBG_LIB
read_liberty -min $WBG_LIB

read_lef $DEMOSAIC_LEF
read_liberty -max $DEMOSAIC_LIB
read_liberty -min $DEMOSAIC_LIB

read_verilog ${SYNTH_DIR}/output/typ/${TOP}_typ_netlist.v
link_design $TOP

read_sdc $SDC_PATH


file mkdir output


# initialize_floorplan -utilization 30 \
#                      -aspect_ratio 1.5 \
#                      -core_space 10 10 \
#                      -site FreePDK45_38x28_10R_NP_162NW_34O

initialize_floorplan -die_area {0 0 1350 1940} \
                     -core_area {10 10 1340 1930} \
                     -site FreePDK45_38x28_10R_NP_162NW_34O


make_tracks

set_macro_base_halo 5 5

place_macro -macro_name {bnr} -location {15.0 15} -orientation R0
place_macro -macro_name {wbg} -location {100 920} -orientation MX
place_macro -macro_name {demos} -location {20 990} -orientation R0



set_io_pin_constraint -pin_names {clk resetn} -region left:*
set_io_pin_constraint -pin_names {h_sync v_sync pixel_in} -region bottom:500-800
set_io_pin_constraint -pin_names {valid_out h_sync_out v_sync_out red_out green_out blue_out} -region top:400-900

place_pins -hor_layers metal3 -ver_layers metal2 \
            -min_distance 15 \
            -corner_avoidance 15

insert_tiecells "LOGIC1_X1/Z" -prefix "TIE_HIGH_"
insert_tiecells "LOGIC0_X1/Z" -prefix "TIE_LOW_"
place_tapcells
place_endcaps


add_global_connection -net VDD -pin_pattern {^VDD$} -power
add_global_connection -net VSS -pin_pattern {^VSS$} -ground

add_global_connection -net VDD -pin_pattern {^VDD$} -power -inst_pattern {sram*}
add_global_connection -net VSS -pin_pattern {^VSS$} -ground -inst_pattern {sram*}

set_voltage_domain -power VDD -ground VSS

define_pdn_grid -name "Core" -pins {metal5 metal6}


# add_pdn_ring -grid "Core" \
#              -layers {metal4 metal5} \
#              -widths 0.7 \
#              -spacings 1.0 \
#              -pad_offsets 0.0 \
#              -add_connect


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
               -offset 5.0 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal5 \
               -width 1.5 \
               -pitch 60 \
               -offset 8.0 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal6 \
               -width 1.5 \
               -pitch 60 \
               -offset 11.0 \
               -spacing 1.6


add_pdn_connect -grid "Core" -layers {metal1 metal4}
add_pdn_connect -grid "Core" -layers {metal4 metal5}
add_pdn_connect -grid "Core" -layers {metal5 metal6}

# SRAMS
define_pdn_grid -name "OpenRAM_Grid0" -macro -instances {bnr wbg demos} -halo {5 5 5 5} -grid_over_pg_pins

add_pdn_stripe -grid "OpenRAM_Grid0" \
               -layer metal4 \
               -width 0.5 \
               -pitch 26 \
               -offset -6.0

add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal5 metal6}
add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal4 metal5}
add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal3 metal4}


pdngen

write_def output/${TOP}_floorplanned.def

puts "\[INFO\] Floorplan completed successfully. File generated: output/${TOP}_floorplanned.def"