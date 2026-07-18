----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.06.2026 03:03:51
-- Design Name: 
-- Module Name: instruction_memory_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity instruction_memory_tb is
end instruction_memory_tb;

architecture sim of instruction_memory_tb is
component instruction_memory is 
port( 
a : in std_logic_vector(31 downto 0); 
rd : out std_logic_vector(31 downto 0) 
); 
end component;

signal a_tb : std_logic_vector(31 downto 0) := (others => '0'); 
signal rd_tb : std_logic_vector(31 downto 0);

begin
DUT : instruction_memory 
port map( 
a => a_tb, 
rd => rd_tb 
);

process is
begin

a_tb <= x"00000000"; -- address 0x00 
wait for 10 ns; -- EXPECT: rd = 0x00500093 (addi x1,x0,5) 
a_tb <= x"00000004"; -- address 0x04 
wait for 10 ns; -- EXPECT: rd = 0x00300113 (addi x2,x0,3) 
a_tb <= x"00000008"; -- address 0x08 
wait for 10 ns; -- EXPECT: rd = 0x002081B3 (add x3,x1,x2) 
a_tb <= x"0000000C"; -- address 0x0C 
wait for 10 ns; -- EXPECT: rd = 0x401181B3 (sub x4,x3,x1) 
a_tb <= x"00000010"; -- address 0x10 
wait for 10 ns; -- EXPECT: rd = 0x0001A283 (lw x5,0(x2)) 
a_tb <= x"00000014"; -- address 0x14 - unused slot 
wait for 10 ns; -- EXPECT: rd = 0x00000000 (nothing stored here) 
wait; 

end process;
end architecture sim;
