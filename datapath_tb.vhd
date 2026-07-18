library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity datapath_tb is
end entity datapath_tb;
 
architecture sim of datapath_tb is
 
    component datapath is
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            PC_debug        : out std_logic_vector(31 downto 0);
            Instr_debug     : out std_logic_vector(31 downto 0);
            RegWrite_debug  : out std_logic;
            WriteReg_debug  : out std_logic_vector(4 downto 0);
            WriteData_debug : out std_logic_vector(31 downto 0)
        );
    end component;
 
    signal clk             : std_logic := '0';
    signal reset            : std_logic := '1';
    signal PC_debug        : std_logic_vector(31 downto 0);
    signal Instr_debug     : std_logic_vector(31 downto 0);
    signal RegWrite_debug  : std_logic;
    signal WriteReg_debug  : std_logic_vector(4 downto 0);
    signal WriteData_debug : std_logic_vector(31 downto 0);
 
    constant CLK_PERIOD : time := 20 ns;
    signal sim_done : boolean := false;
 
    -- guards against x5 ever being written (proves the branch skip worked)
    signal x5_ever_written : boolean := false;
 
begin
 
    DUT: datapath
        port map (
            clk             => clk,
            reset           => reset,
            PC_debug        => PC_debug,
            Instr_debug     => Instr_debug,
            RegWrite_debug  => RegWrite_debug,
            WriteReg_debug  => WriteReg_debug,
            WriteData_debug => WriteData_debug
        );
 
    clk_gen: process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;
 
    -- continuously watches for any write to x5 across the whole run
    guard_x5: process (clk)
    begin
        if rising_edge(clk) then
            if RegWrite_debug = '1' and WriteReg_debug = "00101" then
                x5_ever_written <= true;
            end if;
        end if;
    end process;
 
    stim_proc: process
        procedure check_pc(
    cycle_name : string;
    expected : std_logic_vector(31 downto 0)
) is
begin
    assert (PC_debug = expected)
        report "FAIL: " & cycle_name & " PC"
        severity error;

    report "PASS: " & cycle_name & " PC"
        severity note;
end procedure;
 
        procedure check_write(
    cycle_name : string;
    exp_write : std_logic;
    exp_reg : std_logic_vector(4 downto 0);
    exp_data : std_logic_vector(31 downto 0)
) is
begin
    assert (RegWrite_debug = exp_write)
        report "FAIL: " & cycle_name & " RegWrite"
        severity error;

    if exp_write = '1' then
        assert (WriteReg_debug = exp_reg)
            report "FAIL: " & cycle_name & " WriteReg"
            severity error;

        assert (WriteData_debug = exp_data)
            report "FAIL: " & cycle_name & " WriteData"
            severity error;
    end if;

    report "PASS: " & cycle_name & " write check"
        severity note;
end procedure;
    begin
        -- hold reset for one full cycle
        wait for CLK_PERIOD;
        reset <= '0';
 
        -- Cycle 1: PC=0x00, addi x1,x0,5 -> x1=5
        wait for 1 ns;  -- let combinational signals settle after the clock edge
        check_pc("cyc1", x"00000000");
        check_write("cyc1 (addi x1,x0,5)", '1', "00001", x"00000005");
 
        -- Cycle 2: PC=0x04, addi x2,x0,10 -> x2=10
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc2", x"00000004");
        check_write("cyc2 (addi x2,x0,10)", '1', "00010", x"0000000A");
 
        -- Cycle 3: PC=0x08, add x3,x1,x2 -> x3=15
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc3", x"00000008");
        check_write("cyc3 (add x3,x1,x2)", '1', "00011", x"0000000F");
 
        -- Cycle 4: PC=0x0C, sw x3,0(x0) -> mem[0]=15, no reg write
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc4", x"0000000C");
        check_write("cyc4 (sw x3,0(x0))", '0', "00000", x"00000000");
 
        -- Cycle 5: PC=0x10, lw x4,0(x0) -> x4=15 (proves the sw actually landed)
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc5", x"00000010");
        check_write("cyc5 (lw x4,0(x0))", '1', "00100", x"0000000F");
 
        -- Cycle 6: PC=0x14, beq x3,x4,8 -> branch taken, no reg write
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc6", x"00000014");
        check_write("cyc6 (beq x3,x4,8)", '0', "00000", x"00000000");
 
        -- Cycle 7: PC should be 0x1C (branch target), NOT 0x18 -
        -- this is the single most important check: it proves the
        -- branch was taken and the "addi x5,x0,99" at 0x18 was skipped
        wait until rising_edge(clk); wait for 1 ns;
        check_pc("cyc7", x"0000001C");
        check_write("cyc7 (addi x6,x0,7)", '1', "00110", x"00000007");
 
        -- let one more cycle elapse so the guard_x5 process has sampled
        -- every relevant clock edge, then check it
        wait until rising_edge(clk); wait for 1 ns;
        if x5_ever_written then
            report "x5-never-written check FAIL: x5 was written at some point" severity error;
        else
            report "x5-never-written check PASS: addi x5,x0,99 was correctly skipped" severity note;
        end if;
 
        report "Full datapath program run complete - see PASS/FAIL lines above." severity note;
        sim_done <= true;
        wait;
    end process;
 
end architecture sim;