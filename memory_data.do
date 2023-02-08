restart -f -nowave
add wave DATA_WIDTH ADDR_WIDTH INIT_FILE clk readEn writeEn address dataIn dataOut store

force clk 0 0, 1 50ns -repeat 100ns 
#repeat after 100ns passed
force readEn 0 0, 1 120ns
force writeEn 0 0, 0 120ns
force address 8'b00000000
force writeEn 1 121, 1  150ns
force dataIn 8'b10101001 
run 900ns

# change to
#generic (DATA_WIDTH : integer := 8;
#             ADDR_WIDTH : integer := 8;
#             INIT_FILE : string := "d_memory_lab2.mif");
 