restart -f -nowave
add wave decoEnable decoSel imDataOut dmDataOut accOut extIn busOut

force decoEnable '0'
force decoSel 2'b00
force imDataOut 8'b00000000
force dmDataOut 8'b11111111
force accOut 8'b00001111
force extIn 8'b11110000
run 100ns

force decoEnable '1'

force decoSel 2'b00
run 100ns


force extIn 8'b00000000
force imDataOut 8'b11110000
run 100ns

force decoSel 2'b01
run 100ns

force decoSel 2'b10
run 100ns

force decoSel 2'b11
run 100ns