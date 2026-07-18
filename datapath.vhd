library ieee;
use ieee.std_logic_1164.all;
 
entity datapath is
    port (
        clk   : in std_logic;
        reset : in std_logic;
 
        -- debug/monitor outputs (simulation-only visibility, no
        -- functional effect on the datapath itself)
        PC_debug        : out std_logic_vector(31 downto 0);
        Instr_debug     : out std_logic_vector(31 downto 0);
        RegWrite_debug  : out std_logic;
        WriteReg_debug  : out std_logic_vector(4 downto 0);
        WriteData_debug : out std_logic_vector(31 downto 0)
    );
end entity datapath;
 
architecture structural of datapath is
 
    ----------------------------------------------------------------------
    -- Component declarations (identical to the earlier version)
    ----------------------------------------------------------------------
 
    component program_counter is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            PCNext : in  std_logic_vector(31 downto 0);
            PC     : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component instruction_memory is
        port (
            a  : in  std_logic_vector(31 downto 0);
            rd : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component main_decoder is
        port (
            opcode    : in  std_logic_vector(6 downto 0);
            RegWrite  : out std_logic;
            ImmSrc    : out std_logic_vector(2 downto 0);
            ALUSrc    : out std_logic;
            MemWrite  : out std_logic;
            ResultSrc : out std_logic_vector(1 downto 0);
            Branch    : out std_logic;
            ALUOp     : out std_logic_vector(1 downto 0);
            Jump      : out std_logic
        );
    end component;
 
    component alu_decoder is
        port (
            opb5       : in  std_logic;
            funct3     : in  std_logic_vector(2 downto 0);
            funct7b5   : in  std_logic;
            ALUOp      : in  std_logic_vector(1 downto 0);
            ALUControl : out std_logic_vector(2 downto 0)
        );
    end component;
 
    component register_file is
        port (
            clk : in  std_logic;
            we3 : in  std_logic;
            a1  : in  std_logic_vector(4 downto 0);
            a2  : in  std_logic_vector(4 downto 0);
            a3  : in  std_logic_vector(4 downto 0);
            wd3 : in  std_logic_vector(31 downto 0);
            rd1 : out std_logic_vector(31 downto 0);
            rd2 : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component sign_extend is
        port (
            instr  : in  std_logic_vector(31 downto 0);
            ImmSrc : in  std_logic_vector(2 downto 0);
            ImmExt : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component alusrc_mux is
        port (
            RD2    : in  std_logic_vector(31 downto 0);
            ImmExt : in  std_logic_vector(31 downto 0);
            ALUSrc : in  std_logic;
            SrcB   : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component alu is
        port (
            SrcA       : in  std_logic_vector(31 downto 0);
            SrcB       : in  std_logic_vector(31 downto 0);
            ALUControl : in  std_logic_vector(2 downto 0);
            ALUResult  : out std_logic_vector(31 downto 0);
            Zero       : out std_logic
        );
    end component;
 
    component data_memory is
        port (
            clk : in  std_logic;
            we  : in  std_logic;
            a   : in  std_logic_vector(31 downto 0);
            wd  : in  std_logic_vector(31 downto 0);
            rd  : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component pcplus4_adder is
        port (
            PC      : in  std_logic_vector(31 downto 0);
            PCPlus4 : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component pctarget_adder is
        port (
            PC       : in  std_logic_vector(31 downto 0);
            ImmExt   : in  std_logic_vector(31 downto 0);
            PCTarget : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component resultsrc_mux is
        port (
            ALUResult : in  std_logic_vector(31 downto 0);
            ReadData  : in  std_logic_vector(31 downto 0);
            PCPlus4   : in  std_logic_vector(31 downto 0);
            ImmExt    : in  std_logic_vector(31 downto 0);
            ResultSrc : in  std_logic_vector(1 downto 0);
            Result    : out std_logic_vector(31 downto 0)
        );
    end component;
 
    component pcsrc_mux is
        port (
            PCPlus4  : in  std_logic_vector(31 downto 0);
            PCTarget : in  std_logic_vector(31 downto 0);
            PCSrc    : in  std_logic;
            PCNext   : out std_logic_vector(31 downto 0)
        );
    end component;
 
    ----------------------------------------------------------------------
    -- Internal signals
    ----------------------------------------------------------------------
 
    signal PC, PCNext, PCPlus4, PCTarget : std_logic_vector(31 downto 0);
    signal Instr                         : std_logic_vector(31 downto 0);
    signal RD1, RD2, ImmExt, SrcB        : std_logic_vector(31 downto 0);
    signal ALUResult, ReadData, Result   : std_logic_vector(31 downto 0);
 
    signal RegWrite, ALUSrc, MemWrite, Branch, Jump, Zero, PCSrc : std_logic;
    signal ImmSrc    : std_logic_vector(2 downto 0);
    signal ResultSrc : std_logic_vector(1 downto 0);
    signal ALUOp     : std_logic_vector(1 downto 0);
    signal ALUControl: std_logic_vector(2 downto 0);
 
begin
 
    ----------------------------------------------------------------------
    -- Fetch
    ----------------------------------------------------------------------
 
    PC_REG: program_counter
        port map (clk => clk, reset => reset, PCNext => PCNext, PC => PC);
 
    IMEM: instruction_memory
        port map (a => PC, rd => Instr);
 
    ----------------------------------------------------------------------
    -- Decode
    ----------------------------------------------------------------------
 
    MAIN_DEC: main_decoder
        port map (
            opcode    => Instr(6 downto 0),
            RegWrite  => RegWrite,
            ImmSrc    => ImmSrc,
            ALUSrc    => ALUSrc,
            MemWrite  => MemWrite,
            ResultSrc => ResultSrc,
            Branch    => Branch,
            ALUOp     => ALUOp,
            Jump      => Jump
        );
 
    ALU_DEC: alu_decoder
        port map (
            opb5       => Instr(5),
            funct3     => Instr(14 downto 12),
            funct7b5   => Instr(30),
            ALUOp      => ALUOp,
            ALUControl => ALUControl
        );
 
    ----------------------------------------------------------------------
    -- Register file read / sign extend
    ----------------------------------------------------------------------
 
    RF: register_file
        port map (
            clk => clk,
            we3 => RegWrite,
            a1  => Instr(19 downto 15),
            a2  => Instr(24 downto 20),
            a3  => Instr(11 downto 7),
            wd3 => Result,
            rd1 => RD1,
            rd2 => RD2
        );
 
    SIGEXT: sign_extend
        port map (instr => Instr, ImmSrc => ImmSrc, ImmExt => ImmExt);
 
    ----------------------------------------------------------------------
    -- Execute
    ----------------------------------------------------------------------
 
    ALU_SRC: alusrc_mux
        port map (RD2 => RD2, ImmExt => ImmExt, ALUSrc => ALUSrc, SrcB => SrcB);
 
    MAIN_ALU: alu
        port map (
            SrcA       => RD1,
            SrcB       => SrcB,
            ALUControl => ALUControl,
            ALUResult  => ALUResult,
            Zero       => Zero
        );
 
    ----------------------------------------------------------------------
    -- Memory
    ----------------------------------------------------------------------
 
    DMEM: data_memory
        port map (clk => clk, we => MemWrite, a => ALUResult, wd => RD2, rd => ReadData);
 
    ----------------------------------------------------------------------
    -- PC update path
    ----------------------------------------------------------------------
 
    PC_PLUS4: pcplus4_adder
        port map (PC => PC, PCPlus4 => PCPlus4);
 
    PC_TARGET: pctarget_adder
        port map (PC => PC, ImmExt => ImmExt, PCTarget => PCTarget);
 
    PCSrc <= Jump or (Branch and Zero);
 
    PC_SRC_MUX: pcsrc_mux
        port map (PCPlus4 => PCPlus4, PCTarget => PCTarget, PCSrc => PCSrc, PCNext => PCNext);
 
    ----------------------------------------------------------------------
    -- Write-back
    ----------------------------------------------------------------------
 
    RESULT_MUX: resultsrc_mux
        port map (
            ALUResult => ALUResult,
            ReadData  => ReadData,
            PCPlus4   => PCPlus4,
            ImmExt    => ImmExt,
            ResultSrc => ResultSrc,
            Result    => Result
        );
 
    ----------------------------------------------------------------------
    -- Debug/monitor taps
    ----------------------------------------------------------------------
 
    PC_debug        <= PC;
    Instr_debug     <= Instr;
    RegWrite_debug  <= RegWrite;
    WriteReg_debug  <= Instr(11 downto 7);
    WriteData_debug <= Result;
 
end architecture structural;