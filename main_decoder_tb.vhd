library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_decoder_tb is
end entity main_decoder_tb;

architecture sim of main_decoder_tb is

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

    signal opcode    : std_logic_vector(6 downto 0) := (others => '0');
    signal RegWrite  : std_logic;
    signal ImmSrc    : std_logic_vector(2 downto 0);
    signal ALUSrc    : std_logic;
    signal MemWrite  : std_logic;
    signal ResultSrc : std_logic_vector(1 downto 0);
    signal Branch    : std_logic;
    signal ALUOp     : std_logic_vector(1 downto 0);
    signal Jump      : std_logic;

    constant T : time := 20 ns;

begin

    DUT : main_decoder
        port map (
            opcode    => opcode,
            RegWrite  => RegWrite,
            ImmSrc    => ImmSrc,
            ALUSrc    => ALUSrc,
            MemWrite  => MemWrite,
            ResultSrc => ResultSrc,
            Branch    => Branch,
            ALUOp     => ALUOp,
            Jump      => Jump
        );

    stim_proc : process

        procedure check(
            name      : string;
            exp_rw    : std_logic;
            exp_iset  : std_logic_vector(2 downto 0);
            exp_asrc  : std_logic;
            exp_mw    : std_logic;
            exp_rsrc  : std_logic_vector(1 downto 0);
            exp_br    : std_logic;
            exp_aluop : std_logic_vector(1 downto 0);
            exp_jp    : std_logic
        ) is
        begin
            assert (
                RegWrite = exp_rw and
                ImmSrc = exp_iset and
                ALUSrc = exp_asrc and
                MemWrite = exp_mw and
                ResultSrc = exp_rsrc and
                Branch = exp_br and
                ALUOp = exp_aluop and
                Jump = exp_jp
            )
            report "FAIL: " & name
            severity error;

            report "PASS: " & name severity note;
        end procedure;

    begin

        -- R-type: add
        opcode <= "0110011";
        wait for T;
        check("R-type", '1', "000", '0', '0', "00", '0', "10", '0');

        -- Load: lw
        opcode <= "0000011";
        wait for T;
        check("lw", '1', "000", '1', '0', "01", '0', "00", '0');

        -- I-type ALU: addi
        opcode <= "0010011";
        wait for T;
        check("addi", '1', "000", '1', '0', "00", '0', "10", '0');

        -- Store: sw
        opcode <= "0100011";
        wait for T;
        check("sw", '0', "001", '1', '1', "00", '0', "00", '0');

        -- Branch: beq
        opcode <= "1100011";
        wait for T;
        check("beq", '0', "010", '0', '0', "00", '1', "01", '0');

        -- Jump: jal
        opcode <= "1101111";
        wait for T;
        check("jal", '1', "011", '0', '0', "10", '0', "00", '1');

        -- U-type: lui
        opcode <= "0110111";
        wait for T;
        check("lui", '1', "100", '1', '0', "11", '0', "00", '0');

        report "All 7 opcodes applied - see PASS/FAIL messages above."
            severity note;

        wait;

    end process;

end architecture sim;