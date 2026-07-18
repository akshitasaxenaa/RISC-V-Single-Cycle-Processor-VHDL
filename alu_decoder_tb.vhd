library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity alu_decoder_tb is
end entity alu_decoder_tb;
 
architecture sim of alu_decoder_tb is
 
    component alu_decoder is
        port (
            opb5       : in  std_logic;
            funct3     : in  std_logic_vector(2 downto 0);
            funct7b5   : in  std_logic;
            ALUOp      : in  std_logic_vector(1 downto 0);
            ALUControl : out std_logic_vector(2 downto 0)
        );
    end component;
 
    signal opb5       : std_logic := '0';
    signal funct3     : std_logic_vector(2 downto 0) := "000";
    signal funct7b5   : std_logic := '0';
    signal ALUOp      : std_logic_vector(1 downto 0) := "00";
    signal ALUControl : std_logic_vector(2 downto 0);
 
    constant T : time := 20 ns;
 
begin
 
    DUT: alu_decoder
        port map (
            opb5       => opb5,
            funct3     => funct3,
            funct7b5   => funct7b5,
            ALUOp      => ALUOp,
            ALUControl => ALUControl
        );
 
    stim_proc: process
       procedure check(name : string; expected : std_logic_vector(2 downto 0)) is
begin
    assert ALUControl = expected
        report "FAIL: " & name
        severity error;

    report "PASS: " & name;
end procedure;

    begin
        -- 1) lw/sw address calculation
        opb5 <= '0'; funct3 <= "010"; funct7b5 <= '0'; ALUOp <= "00";
        wait for T;
        check("lw/sw (ALUOp=00)", "000");
 
        -- 2) beq/bne comparison
        opb5 <= '1'; funct3 <= "000"; funct7b5 <= '0'; ALUOp <= "01";
        wait for T;
        check("beq/bne (ALUOp=01)", "001");
 
        -- 3) R-type sub: opb5=1, funct3=000, funct7b5=1
        opb5 <= '1'; funct3 <= "000"; funct7b5 <= '1'; ALUOp <= "10";
        wait for T;
        check("R-type sub", "001");
 
        -- 4) R-type add: opb5=1, funct3=000, funct7b5=0
        opb5 <= '1'; funct3 <= "000"; funct7b5 <= '0'; ALUOp <= "10";
        wait for T;
        check("R-type add", "000");
 
        -- 5) I-type addi: opb5=0, funct3=000, funct7b5=1 (must be ignored -> add)
        opb5 <= '0'; funct3 <= "000"; funct7b5 <= '1'; ALUOp <= "10";
        wait for T;
        check("I-type addi (funct7b5 ignored)", "000");
 
        -- 6) slt / slti
        opb5 <= '1'; funct3 <= "010"; funct7b5 <= '0'; ALUOp <= "10";
        wait for T;
        check("slt/slti", "101");
 
        -- 7) or / ori
        opb5 <= '1'; funct3 <= "110"; funct7b5 <= '0'; ALUOp <= "10";
        wait for T;
        check("or/ori", "011");
 
        -- 8) and / andi
        opb5 <= '1'; funct3 <= "111"; funct7b5 <= '0'; ALUOp <= "10";
        wait for T;
        check("and/andi", "010");
 
        report "All test cases applied - see PASS/FAIL lines above." severity note;
        wait;
    end process;
 
end architecture sim;