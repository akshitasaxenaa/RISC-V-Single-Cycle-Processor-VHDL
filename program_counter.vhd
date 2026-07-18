library ieee;
use ieee.std_logic_1164.all;
 
entity program_counter is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        PCNext : in  std_logic_vector(31 downto 0);
        PC     : out std_logic_vector(31 downto 0)
    );
end entity program_counter;
 
architecture behavioral of program_counter is
begin
    process (clk, reset)
    begin
        if reset = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            PC <= PCNext;
        end if;
    end process;
end architecture behavioral;