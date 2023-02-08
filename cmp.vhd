library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity cmp is
    port(   a: in   std_logic_vector (7 downto 0);
            b: in   std_logic_vector (7 downto 0);
    	    e: out  std_logic);
end cmp;

architecture structural of cmp is
signal eq_flags: std_logic_vector(7 downto 0);
begin
    eq_flags <= a XNOR b;
    e <= AND_REDUCE(eq_flags);
end structural;
