library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
    generic (d_width: integer := 8);
    port (
        s : in std_logic;
        i0 : in std_logic_vector(d_width-1 downto 0);
        i1 : in std_logic_vector(d_width-1 downto 0);
        o : out std_logic_vector(d_width-1 downto 0)
    );
end mux2;

architecture dataflow of mux2 is
begin
    with s select o <=
        i0 when '0',
        i1 when '1',
        (others => 'X') when others;
end dataflow;