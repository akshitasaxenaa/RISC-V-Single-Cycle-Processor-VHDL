library ieee;
use ieee.std_logic_1164.all;
 
entity resultsrc_mux is
    port (
        ALUResult : in  std_logic_vector(31 downto 0);
        ReadData  : in  std_logic_vector(31 downto 0);
        PCPlus4   : in  std_logic_vector(31 downto 0);
        ImmExt    : in  std_logic_vector(31 downto 0);
        ResultSrc : in  std_logic_vector(1 downto 0);
        Result    : out std_logic_vector(31 downto 0)
    );
end entity resultsrc_mux;
 
architecture behavioral of resultsrc_mux is
begin
    with ResultSrc select
        Result <= ALUResult when "00",
                  ReadData  when "01",
                  PCPlus4   when "10",
                  ImmExt    when others;  -- "11"
end architecture behavioral;