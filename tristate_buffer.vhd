library ieee;
use ieee.std_logic_1164.all;

entity tristate_buffer is 
    port (
        x  : in  std_logic_vector(7 downto 0);
        en : in  std_logic;
        y  : out std_logic_vector(7 downto 0)
    );
end tristate_buffer;

architecture behavioral of tristate_buffer is
begin
    y <= x when (en = '1') else (others => 'Z');
end behavioral;
