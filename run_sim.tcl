open_project [file normalize "SRAM_4Bank.xpr"]
set_property top sram_4bank [get_filesets sources_1]
set_property top tb_sram_4bank [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
run all
close_sim
close_project
exit

