library ieee;
use ieee.std_logic_1164.all;

entity rca is
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end rca;

architecture structural of rca is
signal inner_carry: std_logic_vector(7 downto 1);
begin
    u0: entity work.fa(dataflow)
        port map(
            a => a(0),
            b => b(0),
            cin => cin,
            cout => inner_carry(1),
            s => s(0)
        );

    g1: for i in 1 to 6 generate
        un: entity work.fa(dataflow)
            port map(
                a => a(i),
                b => b(i),
                cin => inner_carry(i),
                cout => inner_carry(i+1),
                s => s(i)
            );
    end generate g1;

    u7: entity work.fa(dataflow)
        port map(
            a => a(7),
            b => b(7),
            cin => inner_carry(7),
            cout => cout,
            s => s(7)
        );
end structural;