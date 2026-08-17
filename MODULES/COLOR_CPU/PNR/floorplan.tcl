set TOP "C_CPU"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../constraints/c_cpu.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/nangate45"

set TECH_LEF  "${PDK_ROOT}/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "${PDK_ROOT}/lef/NangateOpenCellLibrary.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/libs/NangateOpenCellLibrary_typical.lib"
set LIB_FILE_FST  "${PDK_ROOT}/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_ROOT "/root/Work/vlsi/pdks/pdk/nangate45/sram_20x2048"

set CCM_LEF "../../CCM/PNR/metals/CCM_abstract.lef"
set CCM_LIB "../../CCM/PNR/metals/CCM.lib"

set GAM_LEF "../../GAM/PNR/metals/GAM_abstract.lef"
set GAM_LIB "../../GAM/PNR/metals/GAM.lib"


read_lef $TECH_LEF
read_lef $CELL_LEF


read_liberty -max $LIB_FILE_SLW
read_liberty -min $LIB_FILE_FST

read_lef $CCM_LEF
read_liberty -max $CCM_LIB
read_liberty -min $CCM_LIB

read_lef $GAM_LEF
read_liberty -max $GAM_LIB
read_liberty -min $GAM_LIB


read_verilog ${SYNTH_DIR}/output/typ/${TOP}_typ_netlist.v
link_design $TOP

read_sdc $SDC_PATH


file mkdir output



initialize_floorplan -die_area {0 0 1310 1540} \
                     -core_area {10 10 1300 1530} \
                     -site FreePDK45_38x28_10R_NP_162NW_34O


make_tracks

set_macro_base_halo 5 5
place_macro -macro_name {ccm} -location {15 740} -orientation R00
place_macro -macro_name {gam} -location {215 15} -orientation R0



set_io_pin_constraint -pin_names {clk resetn coef_in valid_in h_sync v_sync red_in green_in blue_in gam_red_in gam_green_in gam_blue_in row0, row1, row2} -region left:*
set_io_pin_constraint -pin_names {valid_out h_sync_out v_sync_out red_out green_out blue_out} -region right:*

place_pins -hor_layers metal3 -ver_layers metal2 \
            -min_distance 8 \
            -corner_avoidance 10

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
define_pdn_grid -name "OpenRAM_Grid0" -macro -instances {ccm gam} -halo {5 5 5 5} -grid_over_pg_pins

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