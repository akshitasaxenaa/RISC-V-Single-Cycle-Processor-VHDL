----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.06.2026 01:01:34
-- Design Name: 
-- Module Name: program_counter_tb - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity program_counter_tb is
end program_counter_tb;

architecture sim of program_counter_tb is
component program_counter is
port( 
clk : in std_logic; 
reset : in std_logic; 
pc_next : in std_logic_vector(31 downto 0); 
pc : out std_logic_vector(31 downto 0) );
end component;

signal clk_tb : std_logic := '0'; 
signal reset_tb : std_logic := '0'; 
signal pc_next_tb : std_logic_vector(31 downto 0) := (others => '0'); 
signal pc_tb : std_logic_vector(31 downto 0);
constant CLK_PERIOD : time := 10 ns;
begin
DUT : program_counter 
port map( 
clk => clk_tb, 
reset => reset_tb, 
pc_next => pc_next_tb, 
pc => pc_tb 
);
clk_tb <= not clk_tb after CLK_PERIOD / 2;
process is 
begin
reset_tb <= '1';
pc_next_tb <= x"00000010";
wait for CLK_PERIOD * 3;

reset_tb <= '0';

pc_next_tb <= x"00000004";
wait for CLK_PERIOD;

pc_next_tb <= x"00000008"; 
wait for CLK_PERIOD;

pc_next_tb <= x"0000000C"; 
wait for CLK_PERIOD;

pc_next_tb <= x"00000010"; 
wait for CLK_PERIOD;

pc_next_tb <= x"000000A0";
wait for CLK_PERIOD;

pc_next_tb <= x"000000A4"; 
wait for CLK_PERIOD;

reset_tb <= '1';
wait for CLK_PERIOD * 2;

wait;
end process;
end architecture sim;
