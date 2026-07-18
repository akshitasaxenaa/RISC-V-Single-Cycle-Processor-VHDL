library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity testcase_tb is
end entity testcase_tb;
 
architecture sim of testcase_tb is
 
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
    signal reset           : std_logic := '1';
    signal PC_debug        : std_logic_vector(31 downto 0);
    signal Instr_debug     : std_logic_vector(31 downto 0);
    signal RegWrite_debug  : std_logic;
    signal WriteReg_debug  : std_logic_vector(4 downto 0);
    signal WriteData_debug : std_logic_vector(31 downto 0);
 
    constant CLK_PERIOD : time := 20 ns;
    signal sim_done : boolean := false;
 
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
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;
 
    stim_proc: process
    begin
        -- release reset after one full cycle
        wait for CLK_PERIOD;
        reset <= '0';
        wait for 1 ns;  -- let combinational logic settle
 
        -- At this point PC = 0x00 and the first instruction
        -- addi x1, x0, 5 has been fetched and decoded.
 
        -- Check Program Counter
        if PC_debug = x"00000000" then
            report "PC check PASS: fetching address 0x00"
                severity note;
        else
            report "PC check FAIL: expected address 0x00000000"
                severity error;
        end if;
 
        -- Check instruction
        if Instr_debug = x"00500093" then
            report "Instruction check PASS: addi x1, x0, 5 fetched correctly"
                severity note;
        else
            report "Instruction check FAIL: incorrect instruction fetched"
                severity error;
        end if;
 
        -- Check execution result
        if RegWrite_debug = '1' and
           WriteReg_debug = "00001" and
           WriteData_debug = x"00000005" then
 
            report "RESULT PASS: x1 = 5, addi x1, x0, 5 executed correctly"
                severity note;
        else
            report "RESULT FAIL: addi x1, x0, 5 did not produce expected result"
                severity error;
        end if;
 
        report "ADDI-only datapath test complete"
            severity note;
 
        sim_done <= true;
        wait;
 
    end process;
 
end architecture sim;