library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity muxes_tb is
end entity muxes_tb;
 
architecture sim of muxes_tb is
 
    component pcsrc_mux is
        port (
            PCPlus4  : in  std_logic_vector(31 downto 0);
            PCTarget : in  std_logic_vector(31 downto 0);
            PCSrc    : in  std_logic;
            PCNext   : out std_logic_vector(31 downto 0)
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
 
    component resultsrc_mux is
        port (
            ALUResult : in  std_logic_vector(31 downto 0);
            ReadData  : in  std_logic_vector(31 downto 0);
            ResultSrc : in  std_logic;
            Result    : out std_logic_vector(31 downto 0)
        );
    end component;
 
    -- pcsrc_mux signals
    signal PCPlus4, PCTarget, PCNext : std_logic_vector(31 downto 0) := (others => '0');
    signal PCSrc : std_logic := '0';
 
    -- alusrc_mux signals
    signal RD2, ImmExt, SrcB : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUSrc : std_logic := '0';
 
    -- resultsrc_mux signals
    signal ALUResult, ReadData, Result : std_logic_vector(31 downto 0) := (others => '0');
    signal ResultSrc : std_logic := '0';
 
    constant T : time := 20 ns;
 
begin
 
    DUT_PCSRC: pcsrc_mux
        port map (PCPlus4 => PCPlus4, PCTarget => PCTarget, PCSrc => PCSrc, PCNext => PCNext);
 
    DUT_ALUSRC: alusrc_mux
        port map (RD2 => RD2, ImmExt => ImmExt, ALUSrc => ALUSrc, SrcB => SrcB);
 
    DUT_RESULTSRC: resultsrc_mux
        port map (ALUResult => ALUResult, ReadData => ReadData, ResultSrc => ResultSrc, Result => Result);
 
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
        -- fixed, distinguishable data on all three muxes' inputs
        PCPlus4   <= x"00000004";
        PCTarget  <= x"BBBBBBBB";
        RD2       <= x"11111111";
        ImmExt    <= x"000000FF";
        ALUResult <= x"AAAAAAAA";
        ReadData  <= x"CCCCCCCC";
 
        ----------------------------------------------------------------
        -- pcsrc_mux
        ----------------------------------------------------------------
        PCSrc <= '0';
        wait for T;
        check("pcsrc_mux, PCSrc=0 -> PCPlus4 ", PCNext, PCPlus4);
 
        PCSrc <= '1';
        wait for T;
        check("pcsrc_mux, PCSrc=1 -> PCTarget", PCNext, PCTarget);
 
        ----------------------------------------------------------------
        -- alusrc_mux
        ----------------------------------------------------------------
        ALUSrc <= '0';
        wait for T;
        check("alusrc_mux, ALUSrc=0 -> RD2   ", SrcB, RD2);
 
        ALUSrc <= '1';
        wait for T;
        check("alusrc_mux, ALUSrc=1 -> ImmExt", SrcB, ImmExt);
 
        ----------------------------------------------------------------
        -- resultsrc_mux
        ----------------------------------------------------------------
        ResultSrc <= '0';
        wait for T;
        check("resultsrc_mux, ResultSrc=0 -> ALUResult", Result, ALUResult);
 
        ResultSrc <= '1';
        wait for T;
        check("resultsrc_mux, ResultSrc=1 -> ReadData ", Result, ReadData);
 
        report "All mux select combinations exercised - see PASS/FAIL lines above." severity note;
        wait;
    end process;
 
end architecture sim;