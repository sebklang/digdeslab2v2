restart -f -nowave
add wave clk resetn loadEnable dataIn dataOut width

force clk 0 0, 1 50ns -repeat 100ns
force resetn 0 0, 1 120ns
force loadEnable 1
force dataIn 8'b10101001 
run 300ns
#force width 1
force resetn 0 0, 1 120ns
force loadEnable 1
force dataIn 8'b0
run 300ns

