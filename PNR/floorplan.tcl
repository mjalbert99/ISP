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

set DPC_LEF     "../MODULES/DPC/PNR/metals/DPC_abstract.lef"
set DPC_LIB_SLW "../MODULES/DPC/PNR/metals/DPC.lib"
set DPC_LIB_FST "../MODULES/DPC/PNR/metals/DPC.lib"

set BNR_LEF     "../MODULES/BNR/PNR/metals/BNR_abstract.lef"
set BNR_LIB_SLW "../MODULES/BNR/PNR/metals/BNR.lib"
set BNR_LIB_FST "../MODULES/BNR/PNR/metals/BNR.lib"

set DEMOSAIC_LEF     "../MODULES/DEMOSAIC/PNR/metals/DEMOSAIC_abstract.lef"
set DEMOSAIC_LIB_SLW "../MODULES/DEMOSAIC/PNR/metals/DEMOSAIC.lib"
set DEMOSAIC_LIB_FST "../MODULES/DEMOSAIC/PNR/metals/DEMOSAIC.lib"

set GAM_LEF     "../MODULES/GAM/PNR/metals/GAM_abstract.lef"
set GAM_LIB_SLW "../MODULES/GAM/PNR/metals/GAM.lib"
set GAM_LIB_FST "../MODULES/GAM/PNR/metals/GAM.lib"

read_lef $TECH_LEF
read_lef $CELL_LEF

read_liberty -max $LIB_FILE_SLW
read_liberty -min $LIB_FILE_FST

read_lef $SRAM_LEF
read_liberty -min $SRAM_LIB_FST
read_liberty -max $SRAM_LIB_SLW

read_lef $DPC_LEF
read_liberty -max $DPC_LIB_SLW
read_liberty -min $DPC_LIB_FST

read_lef $BNR_LEF
read_liberty -max $BNR_LIB_SLW
read_liberty -min $BNR_LIB_FST

read_lef $DEMOSAIC_LEF
read_liberty -max $DEMOSAIC_LIB_SLW
read_liberty -min $DEMOSAIC_LIB_FST

read_lef $GAM_LEF
read_liberty -max $GAM_LIB_SLW
read_liberty -min $GAM_LIB_FST

read_verilog ${SYNTH_DIR}/output/typ/${TOP}_typ_netlist.v
link_design $TOP

read_sdc $SDC_PATH


file mkdir output

# initialize_floorplan -utilization 70 \
#                      -aspect_ratio 1 \
#                      -core_space 3.5 3.5 \
#                      -site FreePDK45_38x28_10R_NP_162NW_34O


initialize_floorplan -die_area {0 0 2960 2610} \
                     -core_area {10 10 2950 2600} \
                     -site FreePDK45_38x28_10R_NP_162NW_34O


make_tracks

set_macro_base_halo 20 20
# rtl_macro_placer -write_macro_placement macros.txt

place_macro -macro_name {dpc} -location {50 20} -orientation R0
place_macro -macro_name {bnr} -location {1500 20} -orientation R0
place_macro -macro_name {demos} -location {1450 1350} -orientation MY
place_macro -macro_name {gam} -location {20 1100} -orientation MX

# set_io_pin_constraint -pin_names {clk resetn coef_in valid_in h_sync v_sync pixel_in gam_red_in gam_green_in gam_blue_in row0 row1 row2} -region left:*


place_pins -hor_layers {metal3 metal5} -ver_layers {metal2 metal4} \
            -min_distance 20 \
            -corner_avoidance 20

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
define_pdn_grid -name "OpenRAM_Grid0" -macro -instances {dpc bnr demos gam} -halo {1 1 1 1} -grid_over_pg_pins

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