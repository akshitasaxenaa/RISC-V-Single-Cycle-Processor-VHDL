library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity data_memory is
    port (
        clk : in  std_logic;
        we  : in  std_logic;
        a   : in  std_logic_vector(31 downto 0);
        wd  : in  std_logic_vector(31 downto 0);
        rd  : out std_logic_vector(31 downto 0)
    );
end entity data_memory;
 
architecture behavioral of data_memory is
 
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal mem : ram_type := (others => (others => '0'));
 
begin
 
    -- synchronous write
    write_proc: process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(a(7 downto 2)))) <= wd;
            end if;
        end if;
    end process;
 
    -- asynchronous (combinational) read
    rd <= mem(to_integer(unsigned(a(7 downto 2))));
 
end architecture behavioral;