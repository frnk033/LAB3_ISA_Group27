#file compilation
vcom -reportprogress 300 -work work ../src/a-constants.vhd
vcom -reportprogress 300 -work work ../src/a-myTypes.vhd
vcom -reportprogress 300 -work work ../src/a-riscv.vhd
vcom -reportprogress 300 -work work ../src/a.a-DATAPATH.vhd
vcom -reportprogress 300 -work work ../src/a.a.a-fetch_stage.vhd
vcom -reportprogress 300 -work work ../src/a.a.b-decode_stage.vhd
vcom -reportprogress 300 -work work ../src/a.a.c-execute_stage.vhd
vcom -reportprogress 300 -work work ../src/a.a.d-memory_stage.vhd
vcom -reportprogress 300 -work work ../src/a.a.e-writeback_stage.vhd
vcom -reportprogress 300 -work work ../src/a.a.f-alu.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.a-add_sub_block.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.b-ALU_adder.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.c-sum_gen.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.d-carry_sel.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.e-rca.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.f-fa.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.g-gg.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.h-carry_gen.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.i-pg_network.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.j-pg.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.l-comparator.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.m-alu_logic.vhd
vcom -reportprogress 300 -work work ../src/a.a.f.n-shifter.vhd
vcom -reportprogress 300 -work work ../src/a.a.g-forwarding_detection_unit.vhd
vcom -reportprogress 300 -work work ../src/a.a.h-forwarding_proc.vhd
vcom -reportprogress 300 -work work ../src/a.a.i-immediate_block.vhd
vcom -reportprogress 300 -work work ../src/a.a.j-adder.vhd
vcom -reportprogress 300 -work work ../src/a.a.k-comparator_block.vhd
vcom -reportprogress 300 -work work ../src/a.a.l-opcode_decoder.vhd
vcom -reportprogress 300 -work work ../src/a.a.m-stall_detection_unit.vhd
vcom -reportprogress 300 -work work ../src/a.a.n-register_file.vhd
vcom -reportprogress 300 -work work ../src/a.a.o-register.vhd
vcom -reportprogress 300 -work work ../src/a.a.p-mux2to1.vhd
vcom -reportprogress 300 -work work ../src/a.a.q-mux3to1.vhd
vcom -reportprogress 300 -work work ../src/a.a.r-mux4to1.vhd
vcom -reportprogress 300 -work work ../src/a.a.s-mux5to1.vhd
vcom -reportprogress 300 -work work ../src/a.a.t-mux6to1.vhd
vcom -reportprogress 300 -work work ../src/a.a.u-IRAM.vhd
vcom -reportprogress 300 -work work ../src/a.a.v-DATARAM.vhd
vcom -reportprogress 300 -work work ../src/a.b-CU.vhd
vcom -reportprogress 300 -work work ../src/clk_gen.vhd
#vcom -reportprogress 300 -work work ../src/TB_RISCV.vhd
vlog -work ./work ../src/tb_riscv.v
#waveforms
vsim -t 100ps -novopt work.tb_riscv
add wave sim:/tb_riscv/CLK_i
add wave sim:/tb_riscv/RST_n_i
add wave sim:/tb_riscv/U1/control_unit/ir_in
add wave sim:/tb_riscv/U1/data_path/decode/register_file/registers
add wave sim:/tb_riscv/DR/data_mem
#run simulation
run 2000 ns
