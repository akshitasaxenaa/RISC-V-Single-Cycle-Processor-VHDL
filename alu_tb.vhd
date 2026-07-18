library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity alu_tb is
end alu_tb;
 
architecture sim of alu_tb is
 
    component alu
        Port (
            operand_a   : in  STD_LOGIC_VECTOR(31 downto 0);
            operand_b   : in  STD_LOGIC_VECTOR(31 downto 0);
            alu_control : in  STD_LOGIC_VECTOR(3 downto 0);
            result      : out STD_LOGIC_VECTOR(31 downto 0);
            zero        : out STD_LOGIC
        );
    end component;
 
    signal operand_a   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal operand_b   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_control : STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
    signal result      : STD_LOGIC_VECTOR(31 downto 0);
    signal zero        : STD_LOGIC;
 
begin
 
    DUT: alu
        port map (
            operand_a   => operand_a,
            operand_b   => operand_b,
            alu_control => alu_control,
            result      => result,
            zero        => zero
        );
 
    stim_proc: process
    begin
        report "==== ALU Testbench Start ====";
 
        -- ADD: 15 + 5 = 20
        operand_a <= x"0000000F"; operand_b <= x"00000005"; alu_control <= "0000";
        wait for 10 ns;
        assert result = x"00000014" report "FAIL: ADD 15+5" severity error;
        report "PASS: ADD 15 + 5 = 20";
 
        -- SUB: 15 - 5 = 10
        operand_a <= x"0000000F"; operand_b <= x"00000005"; alu_control <= "0001";
        wait for 10 ns;
        assert result = x"0000000A" report "FAIL: SUB 15-5" severity error;
        report "PASS: SUB 15 - 5 = 10";
 
        -- SUB producing zero, checks the zero flag: 7 - 7 = 0
        operand_a <= x"00000007"; operand_b <= x"00000007"; alu_control <= "0001";
        wait for 10 ns;
        assert result = x"00000000" report "FAIL: SUB 7-7" severity error;
        assert zero = '1' report "FAIL: zero flag should be 1 when result = 0" severity error;
        report "PASS: SUB 7 - 7 = 0, zero flag = 1";
 
        -- AND: 0xFF0F0F0F and 0x0FFFFFFF
        operand_a <= x"FF0F0F0F"; operand_b <= x"0FFFFFFF"; alu_control <= "0010";
        wait for 10 ns;
        assert result = x"0F0F0F0F" report "FAIL: AND" severity error;
        report "PASS: AND";
 
        -- OR: 0xF0F0F0F0 or 0x0F0F0F0F = 0xFFFFFFFF
        operand_a <= x"F0F0F0F0"; operand_b <= x"0F0F0F0F"; alu_control <= "0011";
        wait for 10 ns;
        assert result = x"FFFFFFFF" report "FAIL: OR" severity error;
        report "PASS: OR";
 
        -- XOR: 0xFFFFFFFF xor 0x0F0F0F0F = 0xF0F0F0F0
        operand_a <= x"FFFFFFFF"; operand_b <= x"0F0F0F0F"; alu_control <= "0100";
        wait for 10 ns;
        assert result = x"F0F0F0F0" report "FAIL: XOR" severity error;
        report "PASS: XOR";
 
        -- SLL: 1 << 4 = 16
        operand_a <= x"00000001"; operand_b <= x"00000004"; alu_control <= "0101";
        wait for 10 ns;
        assert result = x"00000010" report "FAIL: SLL" severity error;
        report "PASS: SLL 1 << 4 = 16";
 
        -- SRL: 0x80000000 >> 4 = 0x08000000 (logical, zero-fill)
        operand_a <= x"80000000"; operand_b <= x"00000004"; alu_control <= "0110";
        wait for 10 ns;
        assert result = x"08000000" report "FAIL: SRL" severity error;
        report "PASS: SRL logical shift right, zero-filled";
 
        -- SRA: 0x80000000 >>> 4 = 0xF8000000 (arithmetic, sign-extended)
        operand_a <= x"80000000"; operand_b <= x"00000004"; alu_control <= "0111";
        wait for 10 ns;
        assert result = x"F8000000" report "FAIL: SRA" severity error;
        report "PASS: SRA arithmetic shift right, sign-extended";
 
        -- SLT signed: -1 < 1 -> true (1)
        -- -1 as 32-bit two's complement is 0xFFFFFFFF
        operand_a <= x"FFFFFFFF"; operand_b <= x"00000001"; alu_control <= "1000";
        wait for 10 ns;
        assert result = x"00000001" report "FAIL: SLT signed -1 < 1" severity error;
        report "PASS: SLT (signed) -1 < 1 = 1";
 
        -- SLTU unsigned: same bit patterns, but 0xFFFFFFFF is huge unsigned,
        -- so 0xFFFFFFFF < 1 is FALSE. This is the classic signed/unsigned trap.
        operand_a <= x"FFFFFFFF"; operand_b <= x"00000001"; alu_control <= "1001";
        wait for 10 ns;
        assert result = x"00000000" report "FAIL: SLTU unsigned 0xFFFFFFFF < 1" severity error;
        report "PASS: SLTU (unsigned) 0xFFFFFFFF < 1 = 0  (signed/unsigned trap confirmed)";
 
        report "==== ALU Testbench Complete ====";
        wait;
 
    end process;
 
end sim;