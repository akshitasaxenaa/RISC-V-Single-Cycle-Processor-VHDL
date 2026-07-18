library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity registerfile_tb is
end registerfile_tb;
 
architecture sim of registerfile_tb is
 
component register_file
        Port (
            clk       : in  STD_LOGIC;
            we3       : in  STD_LOGIC;
            a1        : in  STD_LOGIC_VECTOR(4 downto 0);
            a2        : in  STD_LOGIC_VECTOR(4 downto 0);
            a3        : in  STD_LOGIC_VECTOR(4 downto 0);
            wd3       : in  STD_LOGIC_VECTOR(31 downto 0);
            rd1       : out STD_LOGIC_VECTOR(31 downto 0);
            rd2       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
 
    signal clk      : STD_LOGIC := '0';
    signal we3      : STD_LOGIC := '0';
    signal a1       : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal a2       : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal a3       : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal wd3      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal rd1      : STD_LOGIC_VECTOR(31 downto 0);
    signal rd2      : STD_LOGIC_VECTOR(31 downto 0);
 
    constant CLK_PERIOD : time := 10 ns;
 
begin
 
    DUT: register_file
        port map (
            clk => clk,
            we3 => we3,
            a1  => a1,
            a2  => a2,
            a3  => a3,
            wd3 => wd3,
            rd1 => rd1,
            rd2 => rd2
        );
 
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;
 
    stim_proc: process
    begin
        report "==== Register File Testbench Start ====";
 
        -- Test 1: Write x1 = 15
        we3      <= '1';
        a3 <= "00001";              -- x1
        wd3 <= x"0000000F";          -- 15
        wait until rising_edge(clk);
        wait for 1 ns;                   -- let the write settle
 
        -- Test 2: Write x2 = 5
        a3 <= "00010";              -- x2
        wd3 <= x"00000005";          -- 5
        wait until rising_edge(clk);
        wait for 1 ns;
 
        -- Test 3: Write x3 = 10
        a3 <= "00011";              -- x3
        wd3 <= x"0000000A";          -- 10
        wait until rising_edge(clk);
        wait for 1 ns;
 
        we3 <= '0';                       -- stop writing, start reading
 
        -- Test 4: Simultaneously read x1 and x2 (ADD x3, x1, x2 scenario)
        a1 <= "00001";             -- x1
        a2 <= "00010";             -- x2
        wait for 1 ns;
        
        assert rd1 = x"0000000F"
            report "FAIL: x1 should read 15" severity error;
        assert rd2 = x"00000005"
            report "FAIL: x2 should read 5" severity error;
        report "PASS: x1 = 15, x2 = 5 read simultaneously";
 
        -- Test 5: Read x3 to confirm the earlier write landed
        a1 <= "00011";             -- x3
        wait for 1 ns;
        assert rd1 = x"0000000A"
            report "FAIL: x3 should read 10" severity error;
        report "PASS: x3 = 10";
 
        -- Test 6: Try to write x0 -- it must stay 0
        we3      <= '1';
        a3 <= "00000";              -- x0
        wd3 <= x"FFFFFFFF";          -- try to force garbage in
        wait until rising_edge(clk);
        wait for 1 ns;
        we3 <= '0';
 
        a1 <= "00000";             -- read x0
        wait for 1 ns;
        assert rd1 = x"00000000"
            report "FAIL: x0 must always read 0" severity error;
        report "PASS: x0 stayed 0 despite write attempt";
 
        -- Test 7: Write disabled (we = '0') should not modify a register
        we3      <= '0';
        a3 <= "00100";              -- x4
        wd3 <= x"12345678";
        wait until rising_edge(clk);
        wait for 1 ns;
 
        a1 <= "00100";             -- read x4
        wait for 1 ns;
        assert rd1 = x"00000000"
            report "FAIL: x4 should remain 0, write was not enabled" severity error;
        report "PASS: write with we = '0' was correctly ignored";
 
        report "==== Register File Testbench Complete ====";
        wait;
 
    end process;
 
end sim;