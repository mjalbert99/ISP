set TOP "CCM"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../constraints/ccm.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/nangate45"

set TECH_LEF  "${PDK_ROOT}/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "${PDK_ROOT}/lef/NangateOpenCellLibrary.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/libs/NangateOpenCellLibrary_typical.lib"
set LIB_FILE_FST  "${PDK_ROOT}/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_ROOT "/root/Work/vlsi/pdks/pdk/nangate45/sram_20x2048"

set SRAM_LEF "../../SRAM/10x2048V/PNR/metals/SRAM10x2048_abstract.lef"
set SRAM_LIB_SLW "../../SRAM/10x2048V/PNR/metals/SRAM10x2048.lib"
set SRAM_LIB_FST "../../SRAM/10x2048V/PNR/metals/SRAM10x2048.lib"

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


initialize_floorplan -utilization 30 \
                     -aspect_ratio 1 \
                     -core_space 3 3 \
                     -site FreePDK45_38x28_10R_NP_162NW_34O



make_tracks

set_macro_base_halo 5 5


set_io_pin_constraint -pin_names {clk resetn valid_in h_sync v_sync coef_in red_in green_in blue_in row0 row1 row2} -region left:*
set_io_pin_constraint -pin_names {valid_out h_sync_out v_sync_out red_out green_out blue_out} -region right:*

place_pins -hor_layers metal3 -ver_layers metal2 \
            -min_distance 1 \
            -corner_avoidance 1

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

pdngen

write_def output/${TOP}_floorplanned.def

puts "\[INFO\] Floorplan completed successfully. File generated: output/${TOP}_floorplanned.def"