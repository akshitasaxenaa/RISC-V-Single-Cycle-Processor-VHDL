library ieee;
use ieee.std_logic_1164.all;
 
entity alusrc_mux is
    port (
        RD2    : in  std_logic_vector(31 downto 0);
        ImmExt : in  std_logic_vector(31 downto 0);
        ALUSrc : in  std_logic;
        SrcB   : out std_logic_vector(31 downto 0)
    );
end entity alusrc_mux;
 
architecture behavioral of alusrc_mux is
begin
    SrcB <= ImmExt when ALUSrc = '1' else RD2;
end architecture behavioral;