--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:52:05 10/01/2015
-- Design Name:   
-- Module Name:   /home/shomeb/j/jonatanl/TDT4255/ex1/testbench/tb_registers.vhd
-- Project Name:  ex1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: registers
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_registers IS
END tb_registers;
 
ARCHITECTURE behavior OF tb_registers IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT registers
    PORT(
         read_register_1 : IN  std_logic_vector(5 downto 0);
         read_register_2 : IN  std_logic_vector(5 downto 0);
         write_register : IN  std_logic_vector(3 downto 0);
         write_data : IN  std_logic_vector(7 downto 0);
         read_data_1 : OUT  std_logic_vector(31 downto 0);
         read_data_2 : OUT  std_logic_vector(31 downto 0);
         register_write : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal read_register_1 : std_logic_vector(5 downto 0) := (others => '0');
   signal read_register_2 : std_logic_vector(5 downto 0) := (others => '0');
   signal write_register : std_logic_vector(3 downto 0) := (others => '0');
   signal write_data : std_logic_vector(7 downto 0) := (others => '0');
   signal register_write : std_logic := '0';

 	--Outputs
   signal read_data_1 : std_logic_vector(31 downto 0);
   signal read_data_2 : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: registers PORT MAP (
          read_register_1 => read_register_1,
          read_register_2 => read_register_2,
          write_register => write_register,
          write_data => write_data,
          read_data_1 => read_data_1,
          read_data_2 => read_data_2,
          register_write => register_write
        );

   -- Clock process definitions
   <clock>_process :process
   begin
		<clock> <= '0';
		wait for <clock>_period/2;
		<clock> <= '1';
		wait for <clock>_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
