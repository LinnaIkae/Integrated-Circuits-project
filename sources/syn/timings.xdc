# Generated Clock
create_generated_clock -name CLK2048_CLK -source [get_ports CLK125M] -divide_by 125000000 -multiply_by 2048 [get_pins INST_CLK_DIVIDER_BIKE/clk_o]

# Timing contraints
set_false_path -from [get_cells -hier -filter {(NAME =~ LCD_CONTROLLER_INST/*) && IS_SEQUENTIAL}] -to *
set_false_path -from * -to [get_cells -hier -filter {(NAME =~ LCD_CONTROLLER_INST/*) && IS_SEQUENTIAL}]

set_false_path -from * -to [get_cells -hier -filter {(NAME =~ INST_CLK_DIVIDER_BIKE/*) && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {(NAME =~ INST_CLK_DIVIDER_BIKE/*) && IS_SEQUENTIAL}] -to *

set_false_path -from [get_cells -hier -filter {(NAME =~ PULSE_SHAPE_REED/*) && IS_SEQUENTIAL}] -to *
set_false_path -from * -to [get_cells -hier -filter {(NAME =~ PULSE_SHAPE_REED/*) && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {(NAME =~ PULSE_SHAPE_MODE/*) && IS_SEQUENTIAL}] -to *
set_false_path -from * -to [get_cells -hier -filter {(NAME =~ PULSE_SHAPE_MODE/*) && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {(NAME =~ FDRE_CIRC*) && IS_SEQUENTIAL}] -to *
set_false_path -from * -to [get_cells -hier -filter {(NAME =~ FDRE_CIRC*) && IS_SEQUENTIAL}]