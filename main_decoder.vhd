library ieee;
use ieee.std_logic_1164.all;
 
entity main_decoder is
    port (
        opcode    : in  std_logic_vector(6 downto 0);
        RegWrite  : out std_logic;
        ImmSrc    : out std_logic_vector(2 downto 0);
        ALUSrc    : out std_logic;
        MemWrite  : out std_logic;
        ResultSrc : out std_logic_vector(1 downto 0);
        Branch    : out std_logic;
        ALUOp     : out std_logic_vector(1 downto 0);
        Jump      : out std_logic
    );
end entity main_decoder;
 
architecture behavioral of main_decoder is
begin
 
    process (opcode)
    begin
        case opcode is
 
            when "0110011" =>  -- R-type (add, sub, and, or, slt, ...)
                RegWrite  <= '1';
                ImmSrc    <= "000";  -- don't care, no immediate used
                ALUSrc    <= '0';    -- second operand = register
                MemWrite  <= '0';
                ResultSrc <= "00";   -- write back ALU result
                Branch    <= '0';
                ALUOp     <= "10";   -- let ALU decoder read funct3/funct7
                Jump      <= '0';
 
            when "0000011" =>  -- lw (I-type load)
                RegWrite  <= '1';
                ImmSrc    <= "000";  -- I-type
                ALUSrc    <= '1';    -- second operand = immediate (offset)
                MemWrite  <= '0';
                ResultSrc <= "01";   -- write back memory read data
                Branch    <= '0';
                ALUOp     <= "00";   -- ALU just adds base + offset
                Jump      <= '0';
 
            when "0010011" =>  -- I-type ALU (addi, andi, ori, slti, ...)
                RegWrite  <= '1';
                ImmSrc    <= "000";  -- I-type
                ALUSrc    <= '1';    -- second operand = immediate
                MemWrite  <= '0';
                ResultSrc <= "00";   -- write back ALU result
                Branch    <= '0';
                ALUOp     <= "10";   -- let ALU decoder read funct3/funct7
                Jump      <= '0';
 
            when "0100011" =>  -- sw (S-type store)
                RegWrite  <= '0';
                ImmSrc    <= "001";  -- S-type
                ALUSrc    <= '1';    -- second operand = immediate (offset)
                MemWrite  <= '1';
                ResultSrc <= "00";   -- don't care, no register write
                Branch    <= '0';
                ALUOp     <= "00";   -- ALU just adds base + offset
                Jump      <= '0';
 
            when "1100011" =>  -- beq / bne / blt / ... (B-type branch)
                RegWrite  <= '0';
                ImmSrc    <= "010";  -- B-type
                ALUSrc    <= '0';    -- compare two registers
                MemWrite  <= '0';
                ResultSrc <= "00";   -- don't care, no register write
                Branch    <= '1';
                ALUOp     <= "01";   -- ALU subtracts for the comparison
                Jump      <= '0';
 
            when "1101111" =>  -- jal (J-type jump and link)
                RegWrite  <= '1';
                ImmSrc    <= "011";  -- J-type
                ALUSrc    <= '0';    -- don't care, ALU unused
                MemWrite  <= '0';
                ResultSrc <= "10";   -- write back PC + 4
                Branch    <= '0';
                ALUOp     <= "00";   -- don't care
                Jump      <= '1';
 
            when "0110111" =>  -- lui (U-type load upper immediate)
                RegWrite  <= '1';
                ImmSrc    <= "100";  -- U-type
                ALUSrc    <= '1';    -- don't care, ALU unused
                MemWrite  <= '0';
                ResultSrc <= "11";   -- write back the immediate itself
                Branch    <= '0';
                ALUOp     <= "00";   -- don't care
                Jump      <= '0';
 
            when others =>      -- unrecognized opcode: drive everything safe/inactive
                RegWrite  <= '0';
                ImmSrc    <= "000";
                ALUSrc    <= '0';
                MemWrite  <= '0';
                ResultSrc <= "00";
                Branch    <= '0';
                ALUOp     <= "00";
                Jump      <= '0';
 
        end case;
    end process;
 
end architecture behavioral;