library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity alu_wRCA is
    port(
        alu_inA, alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end alu_wRCA;

architecture structural of alu_wRCA is

signal adder_result    : std_logic_vector(7 downto 0);

signal carryselect_cin : std_logic;
signal carryselect_not : std_logic;
signal final_b         : std_logic_vector(7 downto 0);
signal sum_or_diff     : std_logic_vector(7 downto 0);
signal penult_out      : std_logic_vector(7 downto 0);

begin
    carryselect_cin <= alu_op(0);
    carryselect_not <= alu_op(0);
    final_b <= alu_inB when carryselect_not = '0' else not alu_inB;
    
    adder: entity work.rca(structural)
        port map ( -- a, b, cin, cout, s
            a => alu_inA,
            b => final_b,
            cin => carryselect_cin,
            cout => C,
            s => sum_or_diff
        );

    with alu_op select penult_out <=
        not alu_inA when "00",
        alu_inA and alu_inB when "01",
        sum_or_diff when "10",
        sum_or_diff when others;

    Z <= '1' when penult_out = "00000000" else '0';
    alu_out <= penult_out;

    compare: entity work.cmp(structural)
        port map (
            alu_inA,
            alu_inB,
            E
        );
end structural;
