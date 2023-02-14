library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;

        decoEnable: out std_logic;
        decoSel: out std_logic_vector(1 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        jAddrSel: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        dsLd: out std_logic
    );
end proc_controller;

architecture behavioral of proc_controller is

type state_type is (FE, DE1, DE2, EX, ME);
signal curr_state: state_type;
signal next_state: state_type;

begin
    fsm : process(clk, resetn)
    begin
        if (resetn = '0') then
            curr_state <= FE;
        elsif (rising_edge(clk) and master_load_enable = '1') then
            curr_state <= next_state;
        end if;
    end process;

    next_state_process: process(curr_state, opcode)
    begin
        
    end process;
end behavioral;









