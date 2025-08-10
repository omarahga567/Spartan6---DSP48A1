vlib work
vlog  reg_mux_input.v DSP48A1_TOP.V DSP48A1_tb.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave *
run -all
