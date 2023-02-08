library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (width: integer := 8);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(width-1 downto 0);
        dataOut: out std_logic_vector(width-1 downto 0)
    );
end entity reg;

architecture behavioral of reg is
   
begin
    process(clk, resetn)
    begin
        if (resetn = '0') then
            dataOut <= (others => '0');     
        elsif (rising_edge(clk)) then
		if (loadEnable = '1') then
           		 dataOut <= dataIn;
		end if;
        end if;
    end process;
end behavioral;