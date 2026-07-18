library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity alu is
    port (
        SrcA       : in  std_logic_vector(31 downto 0);
        SrcB       : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(2 downto 0);
        ALUResult  : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
end entity alu;
 
architecture behavioral of alu is
    signal result : std_logic_vector(31 downto 0);
begin
 
    process (SrcA, SrcB, ALUControl)
    begin
        case ALUControl is
            when "000" =>  -- add
                result <= std_logic_vector(unsigned(SrcA) + unsigned(SrcB));
            when "001" =>  -- subtract
                result <= std_logic_vector(unsigned(SrcA) - unsigned(SrcB));
            when "010" =>  -- and
                result <= SrcA and SrcB;
            when "011" =>  -- or
                result <= SrcA or SrcB;
            when "101" =>  -- slt: result = 1 if SrcA < SrcB (signed), else 0
                if signed(SrcA) < signed(SrcB) then
                    result <= (0 => '1', others => '0');
                else
                    result <= (others => '0');
                end if;
            when others =>
                result <= (others => '0');
        end case;
    end process;
 
    ALUResult <= result;
    Zero      <= '1' when result = x"00000000" else '0';
 
end architecture behavioral;