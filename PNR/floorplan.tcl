set TOP "ISP"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../constraints/isp.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/nangate45"

set TECH_LEF  "${PDK_ROOT}/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "${PDK_ROOT}/lef/NangateOpenCellLibrary.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/libs/NangateOpenCellLibrary_typical.lib"
set LIB_FILE_FST  "${PDK_ROOT}/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_ROOT "/root/Work/vlsi/pdks/pdk/nangate45/sram_20x2048"

set SRAM_LEF     "../MODULES/SRAM/10x2048V/PNR/metals/SRAM10x2048_abstract.lef"
set SRAM_LIB_SLW "../MODULES/SRAM/10x2048V/PNR/metals/SRAM10x2048.lib"
set SRAM_LIB_FST "../MODULES/SRAM/10x2048V/PNR/metals/SRAM10x2048.lib"

set P_LEF     "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU_abstract.lef"
set P_LIB_SLW "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU.lib"
set P_LIB_FST "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU.lib"

set D_LEF     "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU_abstract.lef"
set D_LIB_SLW "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU.lib"
set D_LIB_FST "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU.lib"

set C_LEF     "../MODULES/COLOR_CPU/PNR/metals/C_CPU_abstract.lef"
set C_LIB_SLW "../MODULES/COLOR_CPU/PNR/metals/C_CPU.lib"
set C_LIB_FST "../MODULES/COLOR_CPU/PNR/metals/C_CPU.lib"


read_lef $TECH_LEF
read_lef $CELL_LEF

read_liberty -max $LIB_FILE_SLW
read_liberty -min $LIB_FILE_FST

read_lef $SRAM_LEF
read_liberty -min $SRAM_LIB_FST
read_liberty -max $SRAM_LIB_SLW

read_lef $D_LEF
read_liberty -max $D_LIB_SLW
read_liberty -min $D_LIB_FST

read_lef $P_LEF
read_liberty -max $P_LIB_SLW
read_liberty -min $P_LIB_FST

read_lef $C_LEF
read_liberty -max $C_LIB_SLW
read_liberty -min $C_LIB_FST


read_verilog ${SYNTH_DIR}/output/typ/${TOP}_typ_netlist.v
link_design $TOP

read_sdc $SDC_PATH


file mkdir output

# initialize_floorplan -utilization 30 \
#                      -aspect_ratio 1 \
#                      -core_space 3.5 3.5 \
#                      -site FreePDK45_38x28_10R_NP_162NW_34O


initialize_floorplan -die_area {0 0 1660 4530} \
                     -core_area {10 10 1650 4520} \
                     -site FreePDK45_38x28_10R_NP_162NW_34O


make_tracks

set_macro_base_halo 20 20
# rtl_macro_placer -write_macro_placement macros.txt

place_macro -macro_name {p_cpu} -location {80 30} -orientation R0
place_macro -macro_name {d_cpu} -location {80 980} -orientation R0
place_macro -macro_name {c_cpu} -location {80 2950} -orientation R0


set_io_pin_constraint -pin_names {clk resetn coef_in valid_in h_sync v_sync pixel_in gam_red_in gam_green_in gam_blue_in row0 row1 row2} -region left:*
set_io_pin_constraint -pin_names {valid_out h_sync_out v_sync_out red_out green_out blue_out} -region right:*


place_pins -hor_layers {metal3 metal5} -ver_layers {metal2 metal4} \
            -min_distance 2 \
            -corner_avoidance 2

insert_tiecells "LOGIC1_X1/Z" -prefix "TIE_HIGH_"
insert_tiecells "LOGIC0_X1/Z" -prefix "TIE_LOW_"
place_tapcells
place_endcaps


add_global_connection -net VDD -pin_pattern {^VDD$} -power
add_global_connection -net VSS -pin_pattern {^VSS$} -ground

add_global_connection -net VDD -pin_pattern {^VDD$} -power -inst_pattern {dpc bnr demos gam}
add_global_connection -net VSS -pin_pattern {^VSS$} -ground -inst_pattern {dpc bnr demos gam}

set_voltage_domain -power VDD -ground VSS

define_pdn_grid -name "Core" -pins {metal7 metal8}


# add_pdn_ring -grid "Core" \
#              -layers {metal7 metal8} \
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
               -pitch 160 \
               -offset 8.0 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal6 \
               -width 1.5 \
               -pitch 160 \
               -offset 11.0 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal7 \
               -width 1.5 \
               -pitch 320 \
               -offset 11.0 \
               -spacing 1.6

add_pdn_stripe -grid "Core" \
               -layer metal8 \
               -width 1.5 \
               -pitch 320 \
               -offset 11.0 \
               -spacing 1.6


add_pdn_connect -grid "Core" -layers {metal1 metal4}
add_pdn_connect -grid "Core" -layers {metal4 metal5}
add_pdn_connect -grid "Core" -layers {metal5 metal6}
add_pdn_connect -grid "Core" -layers {metal6 metal7}
add_pdn_connect -grid "Core" -layers {metal7 metal8}

# SRAMS
define_pdn_grid -name "OpenRAM_Grid0" -macro -instances {p_cpu d_cpu c_cpu} -halo {1 1 1 1} -grid_over_pg_pins

add_pdn_stripe -grid "OpenRAM_Grid0" \
               -layer metal4 \
               -width 0.5 \
               -pitch 26 \
               -offset -6.0

add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal7 metal8}
add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal6 metal7}
add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal5 metal6}
add_pdn_connect -grid "OpenRAM_Grid0" -layers {metal4 metal5}


pdngen

write_def output/${TOP}_floorplanned.def

puts "\[INFO\] Floorplan completed successfully. File generated: output/${TOP}_floorplanned.def"