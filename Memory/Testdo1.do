add wave -position end sim:/memory_unit/*
force -freeze sim:/memory_unit/rst 0 0
force -freeze sim:/memory_unit/Interrupt 0 0
force -freeze sim:/memory_unit/Control_Signals 16#000000 0
force -freeze sim:/memory_unit/PC_Concat 16#00012345 0
force -freeze sim:/memory_unit/ALU_Heap_Value 16#99999999 0
run
force -freeze sim:/memory_unit/RD2 16#88888888 0
run
force -freeze sim:/memory_unit/rst 1 0
run
force -freeze sim:/memory_unit/rst 0 0
force -freeze sim:/memory_unit/Interrupt 1 0
run
force -freeze sim:/memory_unit/Interrupt 0 0
force -freeze sim:/memory_unit/Control_Signals 000000000000000001000000 0
run
force -freeze sim:/memory_unit/Control_Signals 000000000000010000000000 0
run
