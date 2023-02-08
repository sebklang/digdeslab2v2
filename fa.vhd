library ieee;
use ieee.std_logic_1164.all;

entity fa is
    port(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic
    );
end fa;

architecture dataflow of fa is
signal p: std_logic;
signal r: std_logic;
signal t: std_logic;
begin
    p    <= a XOR b;
    r    <= p AND cin;
    t    <= a AND b;
    s    <= p XOR cin;
    cout <= r OR  t;
end dataflow;