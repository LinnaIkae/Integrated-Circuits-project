set_msg_config -suppress -string {{LCD_CONTROLLER}}
set_msg_config -suppress -id {filemgmt 20-1763}

# set "typing undriven pin" to error
set_msg_config -id {Synth 8-3295} -new_severity {ERROR}

set project_path [get_property directory [current_project]]
set prj_tb_dir [format "%ssources/tb" [string range $project_path 0 [string last "/vivado" $project_path]]]
set prj_tcl_dir [format "%ssources/tcl" [string range $project_path 0 [string last "/vivado" $project_path]]]

set_property include_dirs $prj_tb_dir [get_filesets sim_1]
set_property STEPS.ROUTE_DESIGN.TCL.POST [format "%s/checkTiming.tcl" $prj_tcl_dir] [get_runs impl_1]