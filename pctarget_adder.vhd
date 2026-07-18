library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity pctarget_adder is
    port (
        PC       : in  std_logic_vector(31 downto 0);
        ImmExt   : in  std_logic_vector(31 downto 0);
        PCTarget : out std_logic_vector(31 downto 0)
    );
end entity pctarget_adder;
 
architecture behavioral of pctarget_adder is
begin
    PCTarget <= std_logic_vector(unsigned(PC) + unsigned(ImmExt));
end architecture behavioral;