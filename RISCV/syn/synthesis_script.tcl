#### SYNTHESIS #####

source .synopsys_dc.setup

#  READING VHDL SOURCE FILES 
analyze -f vhdl -lib WORK ../src/a-constants.vhd
analyze -f vhdl -lib WORK ../src/a-myTypes.vhd
analyze -f vhdl -lib WORK ../src/a.a.p-mux2to1.vhd                    
analyze -f vhdl -lib WORK ../src/a.a.q-mux3to1.vhd                    
analyze -f vhdl -lib WORK ../src/a.a.r-mux4to1.vhd                    
analyze -f vhdl -lib WORK ../src/a.a.s-mux5to1.vhd   
analyze -f vhdl -lib WORK ../src/a.a.t-mux6to1.vhd 
analyze -f vhdl -lib WORK ../src/a.a.o-register.vhd   
analyze -f vhdl -lib WORK ../src/a.a.g-forwarding_detection_unit.vhd  
analyze -f vhdl -lib WORK ../src/a.a.h-forwarding_proc.vhd            
analyze -f vhdl -lib WORK ../src/a.a.i-immediate_block.vhd            
analyze -f vhdl -lib WORK ../src/a.a.j-adder.vhd                      
analyze -f vhdl -lib WORK ../src/a.a.k-comparator_block.vhd           
analyze -f vhdl -lib WORK ../src/a.a.l-opcode_decoder.vhd             
analyze -f vhdl -lib WORK ../src/a.a.m-stall_detection_unit.vhd       
analyze -f vhdl -lib WORK ../src/a.a.n-register_file.vhd 
analyze -f vhdl -lib WORK ../src/a.a.f.f-fa.vhd   
analyze -f vhdl -lib WORK ../src/a.a.f.e-rca.vhd   
analyze -f vhdl -lib WORK ../src/a.a.f.g-gg.vhd 
analyze -f vhdl -lib WORK ../src/a.a.f.j-pg.vhd  
analyze -f vhdl -lib WORK ../src/a.a.f.i-pg_network.vhd 
analyze -f vhdl -lib WORK ../src/a.a.f.h-carry_gen.vhd  
analyze -f vhdl -lib WORK ../src/a.a.f.d-carry_sel.vhd    
analyze -f vhdl -lib WORK ../src/a.a.f.c-sum_gen.vhd     
analyze -f vhdl -lib WORK ../src/a.a.f.b-ALU_adder.vhd   
analyze -f vhdl -lib WORK ../src/a.a.f.a-add_sub_block.vhd   
analyze -f vhdl -lib WORK ../src/a.a.f.l-comparator.vhd               
analyze -f vhdl -lib WORK ../src/a.a.f.m-alu_logic.vhd                
analyze -f vhdl -lib WORK ../src/a.a.f.n-shifter.vhd                  
analyze -f vhdl -lib WORK ../src/a.a.f-alu.vhd   
analyze -f vhdl -lib WORK ../src/a.a.a-fetch_stage.vhd                
analyze -f vhdl -lib WORK ../src/a.a.b-decode_stage.vhd 
analyze -f vhdl -lib WORK ../src/a.a.c-execute_stage.vhd  
analyze -f vhdl -lib WORK ../src/a.a.d-memory_stage.vhd 
analyze -f vhdl -lib WORK ../src/a.a.e-writeback_stage.vhd     
analyze -f vhdl -lib WORK ../src/a.a-DATAPATH.vhd       
analyze -f vhdl -lib WORK ../src/a.b-CU.vhd     
analyze -f vhdl -lib WORK ../src/a-riscv.vhd                                                                                                                       

set power_preserve_rtl_hier_names true
elaborate RISCV -arch str -lib WORK > ./elaborate.txt

# APPLYING CONSTRAINTS
create_clock -name MY_CLK -period 5.2 Clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

# START THE SYNTHESIS
compile

# SAVE THE RESULTS
report_timing > report_timing.txt
report_area > report_area.txt

ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/riscv.sdf
write -f verilog -hierarchy -output ../netlist/riscv.v
write_sdc ../netlist/riscv.sdc
