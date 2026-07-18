library ieee;
use ieee.std_logic_1164.all;
 
entity pcsrc_mux is
    port (
        PCPlus4  : in  std_logic_vector(31 downto 0);
        PCTarget : in  std_logic_vector(31 downto 0);
        PCSrc    : in  std_logic;
        PCNext   : out std_logic_vector(31 downto 0)
    );
end entity pcsrc_mux;
 
architecture behavioral of pcsrc_mux is
begin
    PCNext <= PCTarget when PCSrc = '1' else PCPlus4;
end architecture behavioral;