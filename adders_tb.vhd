library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity adders_tb is
end entity adders_tb;
 
architecture sim of adders_tb is
 
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
 
    -- pcplus4_adder signals
    signal PC4_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal PCPlus4  : std_logic_vector(31 downto 0);
 
    -- pctarget_adder signals
    signal PCT_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal ImmExt   : std_logic_vector(31 downto 0) := (others => '0');
    signal PCTarget : std_logic_vector(31 downto 0);
 
    constant T : time := 20 ns;
 
begin
 
    DUT_PCPLUS4: pcplus4_adder
        port map (PC => PC4_in, PCPlus4 => PCPlus4);
 
    DUT_PCTARGET: pctarget_adder
        port map (PC => PCT_in, ImmExt => ImmExt, PCTarget => PCTarget);
 
    stim_proc: process
        procedure check(
    name : string;
    got : std_logic_vector(31 downto 0);
    expected : std_logic_vector(31 downto 0)
) is
begin
    assert (got = expected)
        report "FAIL: " & name
        severity error;

    report "PASS: " & name severity note;
end procedure;
    begin
        -- 1) PCPlus4, normal case
        PC4_in <= x"00001000";
        wait for T;
        check("PCPlus4, normal case      ", PCPlus4, x"00001004");
 
        -- 2) PCTarget, positive offset (+16)
        PCT_in <= x"00001000";
        ImmExt <= x"00000010";
        wait for T;
        check("PCTarget, +16 offset      ", PCTarget, x"00001010");
 
        -- 3) PCTarget, negative offset (-8), i.e. a backward branch
        PCT_in <= x"00001000";
        ImmExt <= x"FFFFFFF8";  -- -8 in two's complement
        wait for T;
        check("PCTarget, -8 offset (back)", PCTarget, x"00000FF8");
 
        -- 4) PCPlus4, 32-bit wraparound
        PC4_in <= x"FFFFFFFC";
        wait for T;
        check("PCPlus4, 32-bit wraparound", PCPlus4, x"00000000");
 
        report "All adder test cases applied - see PASS/FAIL lines above." severity note;
        wait;
    end process;
 
end architecture sim;