library ieee;
use ieee.std_logic_1164.all;

entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab3.mif";
             iInitFile : string := "i_memory_lab3.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
end EDA322_processor;

architecture structural of EDA322_processor is

component reg
    generic (width: integer := 8);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(width-1 downto 0);
        dataOut: out std_logic_vector(width-1 downto 0)
    );
end component;

component alu_wRCA
    port(
        alu_inA, alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end component;

component mux2
    generic (d_width: integer := 8);
    port (
        s : in std_logic;
        i0 : in std_logic_vector(d_width-1 downto 0);
        i1 : in std_logic_vector(d_width-1 downto 0);
        o : out std_logic_vector(d_width-1 downto 0)
    );
end component;

component proc_bus
    port (
        decoEnable : in std_logic;
        decoSel    : in std_logic_vector(1 downto 0);
        imDataOut   : in std_logic_vector(7 downto 0);
        dmDataOut     : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0)
    );
end component;

component rca
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end component;

component memory
    generic (DATA_WIDTH : integer := 8;
             ADDR_WIDTH : integer := 8;
             INIT_FILE : string := "i_memory_lab3.mif");
    port (
        clk     : in std_logic;
        readEn    : in std_logic;
        writeEn   : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end component;

component proc_controller
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
end component;

signal opcode_signal: std_logic_vector(3 downto 0);
signal e_flag_out_signal: std_logic;

signal decoEnable_signal: std_logic;
signal decoSel_signal: std_logic_vector(1 downto 0);
signal pcSel_signal: std_logic;
signal pcLd_signal: std_logic;
signal jAddrSel_signal: std_logic;
signal imRead_signal: std_logic;
signal dmRead_signal: std_logic;
signal dmWrite_signal: std_logic;
signal aluOp_signal: std_logic_vector(1 downto 0);
signal flagLd_signal: std_logic;
signal accSel_signal: std_logic;
signal accLd_signal: std_logic;
signal dsLd_signal: std_logic;

signal imDataOut_signal: std_logic_vector(11 downto 0);
signal dmDataOut_signal: std_logic_vector(7 downto 0);
signal accOut_signal: std_logic_vector(7 downto 0);
signal busOut_signal: std_logic_vector(7 downto 0);
signal aluOut_signal: std_logic_vector(7 downto 0);
signal dsOut_signal: std_logic_vector(7 downto 0);

signal pcOut_signal: std_logic_vector(7 downto 0);

signal pcIncrOut_signal: std_logic_vector(7 downto 0);
signal jAddrAdderOut_signal: std_logic_vector(7 downto 0);
signal jAddrAdderB_signal: std_logic_vector(7 downto 0);
signal jumpAddr_signal: std_logic_vector(7 downto 0);
signal nextPC_signal: std_logic_vector(7 downto 0);

signal E_flag_signal: std_logic;
signal C_flag_signal: std_logic;
signal Z_flag_signal: std_logic;

signal accSelMuxOut_signal: std_logic_vector(7 downto 0);

signal tempFlagVecEOut: std_logic_vector(0 downto 0);
signal tempFlagVecE: std_logic_vector(0 downto 0);
signal tempFlagVecC: std_logic_vector(0 downto 0);
signal tempFlagVecZ: std_logic_vector(0 downto 0);

begin

    controller: proc_controller
        port map(
            clk => clk,
            resetn => resetn,
            master_load_enable => master_load_enable,
            opcode => opcode_signal,
            e_flag => e_flag_out_signal,

            decoEnable => decoEnable_signal,
            decoSel => decoSel_signal,
            pcSel => pcSel_signal,
            pcLd => pcLd_signal,
            jAddrSel => jAddrSel_signal,
            imRead => imRead_signal,
            dmRead => dmRead_signal,
            dmWrite => dmWrite_signal,
            aluOp => aluOp_signal,
            flagLd => flagLd_signal,
            accSel => accSel_signal,
            accLd => accLd_signal,
            dsLd => dsLd_signal
        );

    internalBus: proc_bus
        port map(
            decoEnable => decoEnable_signal,
            decoSel => decoSel_signal,
            imDataOut => imDataOut_signal(7 downto 0),
            dmDataOut => dmDataOut_signal,
            accOut => accOut_signal,
            extIn => extIn,
            busOut => busOut_signal
        );

    instructionMemory: memory
        generic map(
            DATA_WIDTH => 12,
            INIT_FILE => "i_memory_lab3.mif"
        )
        port map(
            clk,
            readEn => imRead_signal,
            writeEn => '0',
            address => pcOut_signal,
            dataIn => "000000000000",
            dataOut => imDataOut_signal
        );
    opcode_signal <= imDataOut_signal(11 downto 8);
    
    dataMemory: memory
        generic map(
            DATA_WIDTH => 8,
            INIT_FILE => "d_memory_lab3.mif"
        )
        port map(
            clk,
            readEn => dmRead_signal,
            writeEn => dmWrite_signal,
            address => busOut_signal,
            dataIn => accOut_signal,
            dataOut => dmDataOut_signal
        );

    pcIncrAdder: rca
        port map(
            a => pcOut_signal,
            b => "00000001",
            cin => '0',
            cout => open,
            s => pcIncrOut_signal
        );

    jAddrAdderB_signal <= not ('0' & busOut_signal(6 downto 0)) when busOut_signal(7) = '1'
                         else ('0' & busOut_signal(6 downto 0));
    jAddrAdder: rca
        port map(
            a => pcOut_signal,
            b => jAddrAdderB_signal,
            cin => busOut_signal(7),
            cout => open,
            s => jAddrAdderOut_signal
        );

    jAddrMux: mux2
        port map(
            s => jAddrSel_signal,
            i0 => jAddrAdderOut_signal,
            i1 => busOut_signal,
            o => jumpAddr_signal
        );

    pcSelMux: mux2
        port map(
            s => pcSel_signal,
            i0 => pcIncrOut_signal,
            i1 => jumpAddr_signal,
            o => nextPC_signal
        );

    PC_reg: reg
        generic map(
            width => 8
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => pcLd_signal,
            dataIn => nextPC_signal,
            dataOut => pcOut_signal
        );

    alu: alu_wRCA
        port map(
            alu_inA => accOut_signal,
            alu_inB => busOut_signal,
            alu_op => aluOp_signal,

            alu_out => aluOut_signal,
            C => C_flag_signal,
            E => E_flag_signal,
            Z => Z_flag_signal
        );

    accSelMux: mux2
        port map(
            s => accSel_signal,
            i0 => aluOut_signal,
            i1 => busOut_signal,
            o => accSelMuxOut_signal
        );

    ACC_reg: reg
        generic map(
            width => 8
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => accLd_signal,
            dataIn => accSelMuxOut_signal,
            dataOut => accOut_signal
        );

    DS_reg: reg
        generic map(
            width => 8
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => dsLd_signal,
            dataIn => accOut_signal,
            dataOut => ds2seg
        );

    tempFlagVecE(0) <= E_flag_signal;
    tempFlagVecEOut(0) <= e_flag_out_signal;
    E_reg: reg
        generic map(
            width => 1
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => flagLd_signal,
            dataIn => tempFlagVecE,
            dataOut => tempFlagVecEOut
        );

    tempFlagVecC(0) <= C_flag_signal;
    C_reg: reg
        generic map(
            width => 1
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => flagLd_signal,
            dataIn => tempFlagVecC,
            dataOut => open
        );
    
    tempFlagVecZ(0) <= Z_flag_signal;
    Z_reg: reg
        generic map(
            width => 1
        )
        port map(
            clk => clk,
            resetn => resetn,
            loadEnable => flagLd_signal,
            dataIn => tempFlagVecZ,
            dataOut => open
        );


    pc2Seg <= pcOut_signal;
    imDataOut2seg <= imDataOut_signal;
    dmDataOut2seg <= dmDataOut_signal;
    aluOut2seg <= aluOut_signal;
    acc2seg <= accOut_signal;
    ds2seg <= dsOut_signal;
    busOut2seg <= busOut_signal;

end structural;