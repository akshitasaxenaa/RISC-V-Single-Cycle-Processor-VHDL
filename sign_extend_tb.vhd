library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity sign_extend_tb is
end entity sign_extend_tb;
 
architecture sim of sign_extend_tb is
 
    component sign_extend is
        port (
            instr  : in  std_logic_vector(31 downto 0);
            ImmSrc : in  std_logic_vector(1 downto 0);
            ImmExt : out std_logic_vector(31 downto 0)
        );
    end component;
 
    signal instr   : std_logic_vector(31 downto 0) := (others => '0');
    signal ImmSrc  : std_logic_vector(1 downto 0)  := "00";
    signal ImmExt  : std_logic_vector(31 downto 0);
 
    constant T : time := 20 ns;  -- stimulus period
 
begin
 
    DUT: sign_extend
        port map (
            instr  => instr,
            ImmSrc => ImmSrc,
            ImmExt => ImmExt
        );
 
    stim_proc: process
begin

    -- Test 1: I-type -- addi x1, x2, -5
    instr  <= x"FFB10093";
    ImmSrc <= "00";
    wait for T;

    assert ImmExt = x"FFFFFFFB"
        report "FAIL: I-type (addi x1,x2,-5)"
        severity error;
    report "PASS: I-type (addi x1,x2,-5)";

    -- Test 2: S-type -- sw x1, 8(x2)
    instr  <= x"00112423";
    ImmSrc <= "01";
    wait for T;

    assert ImmExt = x"00000008"
        report "FAIL: S-type (sw x1,8(x2))"
        severity error;
    report "PASS: S-type (sw x1,8(x2))";

    -- Test 3: B-type -- beq x3, x4, -4
    instr  <= x"FE418EE3";
    ImmSrc <= "10";
    wait for T;

    assert ImmExt = x"FFFFFFFC"
        report "FAIL: B-type (beq x3,x4,-4)"
        severity error;
    report "PASS: B-type (beq x3,x4,-4)";

    -- Test 4: J-type -- jal x5, 16
    instr  <= x"010002EF";
    ImmSrc <= "11";
    wait for T;

    assert ImmExt = x"00000010"
        report "FAIL: J-type (jal x5,16)"
        severity error;
    report "PASS: J-type (jal x5,16)";

    report "==== Sign Extend Testbench Complete ===="
        severity note;

    wait;

end process;
 
end architecture sim;