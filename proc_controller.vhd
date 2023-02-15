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
        case(curr_state) is
            when FE =>
                next_state <= DE1;

            when DE1 =>
                if (opcode = O_NOOP) then
                    next_state <= FE;
                elsif (opcode = O_LBI) then
                    next_state <= DE2;
                elsif (opcode = O_SB or opcode = O_SBI) then
                    next_state <= ME;
                else
                    next_state <= EX;
                end if;

            when DE2 =>
                next_state <= EX;

            when EX =>
                next_state <= ME;

            when ME =>
                next_state <= FE;
        end case;
    end process;

    output_process: process(curr_state, opcode, e_flag)
    begin
        if (curr_state = FE) then
            pcSel <= '0';
            if (master_load_enable = '1') then
                imRead <= '1';
                pcLd <= '1';
            end if;
        elsif (curr_state = DE1 and (
            opcode = O_CMP or
            opcode = O_AND or
            opcode = O_ADD or
            opcode = O_SUB or
            opcode = O_LB or
            opcode = O_LBI or
            opcode = O_SBI
        )) then
            decoEnable <= '1';
            decoSel <= "00";
            if (master_load_enable = '1') then
                dmRead <= '1';
            end if;
        end if;

        case(opcode) is
            when O_NOOP =>
                decoEnable <= '0';
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';

            when O_IN =>
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "11";
                    accSel <= '1';
                    if (master_load_enable = '1') then
                        accLd <= '1';
                    end if;
                end if;

            when O_DS =>
                decoEnable <= '0';
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                if (curr_state = EX) then
                    if (master_load_enable = '1') then
                        dsLd <= '1';
                    end if;
                end if;

            when O_JEQ =>
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = EX and e_flag = '1') then
                    decoEnable <= '1';
                    decoSel <= "00";
                    jAddrSel <= '0';
                    pcSel <= '1';
                    if (master_load_enable = '1') then
                        pcLd <= '1';
                    end if;
                end if;

            when O_JNE =>
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = EX and e_flag = '0') then
                    decoEnable <= '1';
                    decoSel <= "00";
                    jAddrSel <= '0';
                    pcSel <= '1';
                    if (master_load_enable = '1') then
                        pcLd <= '1';
                    end if;
                end if;

            when O_J =>
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "00";
                    jAddrSel <= '0';
                    pcSel <= '1';
                    if (master_load_enable = '1') then
                        pcLd <= '1';
                    end if;
                end if;

            when O_JA =>
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "00";
                    jAddrSel <= '1';
                    pcSel <= '1';
                    if (master_load_enable = '1') then
                        pcLd <= '1';
                    end if;
                end if;

            when O_CMP =>
                dmWrite <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    if (master_load_enable = '1') then
                        flagLd <= '1';
                    end if;
                end if;

            when O_NOT =>
                decoEnable <= '0';
                dmRead <= '0';
                dmWrite <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    accSel <= '0';
                    aluOp <= "00";
                    if (master_load_enable = '1') then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                end if;

            when O_AND =>
                dmWrite <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '0';
                    aluOp <= "01";
                    if (master_load_enable = '1') then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                end if;
            
            when O_ADD =>
                dmWrite <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '0';
                    aluOp <= "10";
                    if (master_load_enable = '1') then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                end if;

            when O_SUB =>
                dmWrite <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '0';
                    aluOp <= "11";
                    if (master_load_enable = '1') then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                end if;

            when O_LB =>
                dmWrite <= '0';
                flagLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '1';
                    if (master_load_enable = '1') then
                        accLd <= '1';
                    end if;
                end if;

            when O_SB =>
                dmRead <= '0';
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = ME) then
                    decoEnable <= '1';
                    decoSel <= "00";
                    if (master_load_enable = '1') then
                        dmWrite <= '1';
                    end if;
                end if;

            when O_LBI =>
                dmWrite <= '0';
                flagLd <= '0';
                dsLd <= '0';
                if (curr_state = EX) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '1';
                    if (master_load_enable = '1') then
                        accLd <= '1';
                    end if;
                elsif (curr_state = DE2) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    if (master_load_enable = '1') then
                        dmRead <= '1';
                    end if;
                end if;

            when O_SBI =>
                flagLd <= '0';
                accLd <= '0';
                dsLd <= '0';
                if (curr_state = ME) then
                    decoEnable <= '1';
                    decoSel <= "01";
                    if (master_load_enable = '1') then
                        dmWrite <= '1';
                    end if;
                end if;

            when others => -- do nothing
        end case;
    end process;
end behavioral;









