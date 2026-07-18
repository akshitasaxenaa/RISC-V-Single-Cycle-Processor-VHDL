library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity instruction_memory is
    port (
        a  : in  std_logic_vector(31 downto 0);
        rd : out std_logic_vector(31 downto 0)
    );
end entity instruction_memory;
 
architecture behavioral of instruction_memory is
 
    type rom_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal mem : rom_type := (
        0  => x"00500093",  -- addi x1, x0, 5
        1  => x"00A00113",  -- addi x2, x0, 10
        2  => x"002081B3",  -- add  x3, x1, x2
        3  => x"00302023",  -- sw   x3, 0(x0)
        4  => x"00002203",  -- lw   x4, 0(x0)
        5  => x"00418463",  -- beq  x3, x4, 8
        6  => x"06300293",  -- addi x5, x0, 99   (skipped)
        7  => x"00700313",  -- addi x6, x0, 7    (branch target)
        others => (others => '0')
    );
 
begin
    rd <= mem(to_integer(unsigned(a(7 downto 2))));
end architecture behavioral;