create_project -force SRAM_4Bank . -part xc7a35tcpg236-1
add_files -fileset sources_1 [file normalize "sram_4bank.v"]
add_files -fileset sim_1 [file normalize "tb_sram_4bank.v"]
set_property top sram_4bank [get_filesets sources_1]
set_property top tb_sram_4bank [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
run all
close_sim
close_project
exit

