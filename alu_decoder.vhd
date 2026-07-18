library ieee;
use ieee.std_logic_1164.all;
 
entity alu_decoder is
    port (
        opb5       : in  std_logic;
        funct3     : in  std_logic_vector(2 downto 0);
        funct7b5   : in  std_logic;
        ALUOp      : in  std_logic_vector(1 downto 0);
        ALUControl : out std_logic_vector(2 downto 0)
    );
end entity alu_decoder;
 
architecture behavioral of alu_decoder is
begin
 
    process (opb5, funct3, funct7b5, ALUOp)
    begin
        case ALUOp is
 
            when "00" =>                       -- lw / sw : address = rs1 + imm
                ALUControl <= "000";            -- add
 
            when "01" =>                       -- beq / bne : rs1 - rs2, check zero flag
                ALUControl <= "001";            -- subtract
 
            when "10" =>                       -- R-type / I-type ALU instructions
                case funct3 is
                    when "000" =>               -- add / sub / addi
                        if (funct7b5 = '1') and (opb5 = '1') then
                            -- funct7b5 only distinguishes sub from add on R-type
                            -- (opb5='1'); for I-type addi (opb5='0') it's always add
                            ALUControl <= "001";   -- sub
                        else
                            ALUControl <= "000";   -- add / addi
                        end if;
 
                    when "010" =>               -- slt / slti
                        ALUControl <= "101";
 
                    when "110" =>               -- or / ori
                        ALUControl <= "011";
 
                    when "111" =>               -- and / andi
                        ALUControl <= "010";
 
                    when others =>
                        ALUControl <= "000";     -- default: add
                end case;
 
            when others =>
                ALUControl <= "000";             -- default: add
 
        end case;
    end process;
 
end architecture behavioral;