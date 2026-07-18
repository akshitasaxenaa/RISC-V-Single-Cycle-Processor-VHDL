library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity pcplus4_adder is
    port (
        PC      : in  std_logic_vector(31 downto 0);
        PCPlus4 : out std_logic_vector(31 downto 0)
    );
end entity pcplus4_adder;
 
architecture behavioral of pcplus4_adder is
begin
    PCPlus4 <= std_logic_vector(unsigned(PC) + 4);
end architecture behavioral;