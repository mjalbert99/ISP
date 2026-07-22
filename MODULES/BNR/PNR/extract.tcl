set out_dir "metals"
file mkdir ${out_dir}

write_lef ${out_dir}/${TOP}.lef

write_abstract_lef ${out_dir}/${TOP}_abstract.lef

write_sdf ${out_dir}/${TOP}.sdf

write_verilog ${out_dir}/${TOP}_post_pnr.v

write_timing_model ${out_dir}/${TOP}.lib

write_spef ${out_dir}/${TOP}.spef
