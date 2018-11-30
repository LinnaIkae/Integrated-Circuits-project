set minireport [report_timing_summary -no_header -no_detailed_paths -return_string]

if {! [string match -nocase {*timing constraints are met*} $minireport]} {
    send_msg_id showstopper-0 error "Timing constraints weren't met. Please check your design. Read up the usage of additions.tcl in the exercise description!"
    return -code error
} else {
	set project_path [get_property directory [current_project]]
	set prj_reports_dir [format "%sreports" [string range $project_path 0 [string last "/vivado" $project_path]]]

	open_run impl_1
	report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file [format "%s/report_prj_timing.txt" $prj_reports_dir]
	report_utilization -hierarchical -file [format "%s/report_prj_utilization_hier.txt" $prj_reports_dir]
	report_utilization -file [format "%s/report_prj_utilization.txt" $prj_reports_dir]
	report_clock_networks -file [format "%s/report_prj_clock_networks.txt" $prj_reports_dir]
	report_clock_interaction -delay_type min_max -significant_digits 3 -file [format "%s/report_prj_clock_interaction.txt" $prj_reports_dir]
}