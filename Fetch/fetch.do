vsim -gui work.fetch
# vsim -gui work.fetch 
# Start time: 09:57:33 on May 25,2022
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.fetch(arch_fetch)
# Loading work.mux8(arch1)
add wave -position insertpoint  \
sim:/fetch/clk \
sim:/fetch/branch_address \
sim:/fetch/memory_address \
sim:/fetch/sel_br \
sim:/fetch/sw_int \
sim:/fetch/swap \
sim:/fetch/hazard \
sim:/fetch/hlt \
sim:/fetch/mem_in_use \
sim:/fetch/pc_mem \
sim:/fetch/rst \
sim:/fetch/fetch_output \
sim:/fetch/mux8_output \
sim:/fetch/next_pc \
sim:/fetch/sel_freeze \
sim:/fetch/sel_mem \
sim:/fetch/sel_mux8
force -freeze sim:/fetch/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/fetch/sel_br 0 0
force -freeze sim:/fetch/sw_int 0 0
force -freeze sim:/fetch/swap 0 0
force -freeze sim:/fetch/hazard 0 0
force -freeze sim:/fetch/hlt 0 0
force -freeze sim:/fetch/mem_in_use 0 0
force -freeze sim:/fetch/pc_mem 0 0
force -freeze sim:/fetch/rst 0 0
run
run
force -freeze sim:/fetch/swap 1 0
run
run
force -freeze sim:/fetch/swap 0 0
force -freeze sim:/fetch/pc_mem 1 0
force -freeze sim:/fetch/memory_address 16#01100000 0
run
force -freeze sim:/fetch/pc_mem 0 0
run
run
force -freeze sim:/fetch/sel_br 1 0
force -freeze sim:/fetch/branch_address 16#00000010 0
run