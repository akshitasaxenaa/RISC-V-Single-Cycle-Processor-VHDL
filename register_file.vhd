library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity register_file is
    port (
        clk : in  std_logic;
        we3 : in  std_logic;                     -- RegWrite
        a1  : in  std_logic_vector(4 downto 0);   -- rs1
        a2  : in  std_logic_vector(4 downto 0);   -- rs2
        a3  : in  std_logic_vector(4 downto 0);   -- rd
        wd3 : in  std_logic_vector(31 downto 0);  -- write-back data (Result)
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0)
    );
end entity register_file;
 
architecture behavioral of register_file is
 
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
 
begin
 
    -- synchronous write, x0 never actually written
    process (clk)
    begin
        if rising_edge(clk) then
            if we3 = '1' and a3 /= "00000" then
                regs(to_integer(unsigned(a3))) <= wd3;
            end if;
        end if;
    end process;
 
    -- asynchronous reads, x0 hardwired to zero
    rd1 <= (others => '0') when a1 = "00000" else regs(to_integer(unsigned(a1)));
    rd2 <= (others => '0') when a2 = "00000" else regs(to_integer(unsigned(a2)));
 
end architecture behavioral;