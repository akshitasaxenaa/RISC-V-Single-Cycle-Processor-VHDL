library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity data_memory_tb is
end entity data_memory_tb;
 
architecture sim of data_memory_tb is
 
    component data_memory is
        port (
            clk : in  std_logic;
            we  : in  std_logic;
            a   : in  std_logic_vector(31 downto 0);
            wd  : in  std_logic_vector(31 downto 0);
            rd  : out std_logic_vector(31 downto 0)
        );
    end component;
 
    signal clk : std_logic := '0';
    signal we  : std_logic := '0';
    signal a   : std_logic_vector(31 downto 0) := (others => '0');
    signal wd  : std_logic_vector(31 downto 0) := (others => '0');
    signal rd  : std_logic_vector(31 downto 0);
 
    constant CLK_PERIOD : time := 20 ns;
    signal   sim_done    : boolean := false;
 
begin
 
    DUT: data_memory
        port map (
            clk => clk,
            we  => we,
            a   => a,
            wd  => wd,
            rd  => rd
        );
 
    -- free-running clock
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
        procedure check(name : string; expected : std_logic_vector(31 downto 0)) is
begin
    assert (rd = expected)
        report "FAIL: " & name
        severity error;

    report "PASS: " & name severity note;
end procedure;
    begin
        -- let the clock settle, then check the initial (unwritten) value
        wait until rising_edge(clk);
        a  <= x"00000004";
        we <= '0';
        wait for 5 ns;  -- give the async read time to settle mid-cycle
        check("initial read @0x04 (before any write)", x"00000000");
 
        -- Step 1: store 0xDEADBEEF to address 0x00000004
        wait until rising_edge(clk);
        a  <= x"00000004";
        wd <= x"DEADBEEF";
        we <= '1';
        wait until rising_edge(clk);  -- the write happens on this edge
        we <= '0';
        wait for 1 ns;  -- small delta so the async read reflects the new value
        check("read @0x04 immediately after write (async read)", x"DEADBEEF");
 
        -- Step 2: read from a different, untouched address
        a <= x"00000008";
        wait for 1 ns;
        check("read @0x08 (never written)", x"00000000");
 
        -- Step 3: the actual "load" - go back to the address we stored to
        a <= x"00000004";
        wait for 1 ns;
        check("load @0x04 (store-then-load result)", x"DEADBEEF");
 
        report "Store-then-load sequence complete - see PASS/FAIL lines above." severity note;
        sim_done <= true;
        wait;
    end process;
 
end architecture sim;