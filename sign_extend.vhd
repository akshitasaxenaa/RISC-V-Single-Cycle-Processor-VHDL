library ieee;
use ieee.std_logic_1164.all;
 
entity sign_extend is
    port (
        instr  : in  std_logic_vector(31 downto 0);
        ImmSrc : in  std_logic_vector(2 downto 0);
        ImmExt : out std_logic_vector(31 downto 0)
    );
end entity sign_extend;
 
architecture behavioral of sign_extend is
begin
    process (instr, ImmSrc)
    begin
        case ImmSrc is
            when "000" =>  -- I-type
                ImmExt <= (31 downto 12 => instr(31)) & instr(31 downto 20);
 
            when "001" =>  -- S-type
                ImmExt <= (31 downto 12 => instr(31)) &
                          instr(31 downto 25) & instr(11 downto 7);
 
            when "010" =>  -- B-type
                ImmExt <= (31 downto 12 => instr(31)) &
                          instr(7) & instr(30 downto 25) &
                          instr(11 downto 8) & '0';
 
            when "011" =>  -- J-type
                ImmExt <= (31 downto 20 => instr(31)) &
                          instr(19 downto 12) & instr(20) &
                          instr(30 downto 21) & '0';
 
            when "100" =>  -- U-type
                ImmExt <= instr(31 downto 12) & x"000";
 
            when others =>
                ImmExt <= (others => '0');
        end case;
    end process;
end architecture behavioral;