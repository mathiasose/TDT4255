LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;
use work.testutil.all;
 
ENTITY tb_immediate_value_transform IS
END tb_immediate_value_transform;
 
ARCHITECTURE behavior OF tb_immediate_value_transform IS 
  
    COMPONENT immediate_value_transform
    PORT(
         transform : IN immediate_value_transformation_t;
         in_value : IN immediate_value_t;
         out_value : OUT operand_t
        );
    END COMPONENT;
    

   --Inputs
   signal transform : immediate_value_transformation_t := SIGN_EXTEND;
   signal in_value : immediate_value_t := (others => '0');

    --Outputs
   signal out_value : operand_t;

BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: immediate_value_transform PORT MAP (
      transform => transform,
      in_value => in_value,
      out_value => out_value
   );

 

   -- Stimulus process
   stim_proc: process
   begin        
      -- hold reset state for 100 ns.
      wait for 100 ns;    

      transform <= SIGN_EXTEND;
      in_value <= x"0001";
      wait for 100 ns;
      check(out_value = x"00000001", "EXTEND pads with zeroes to the left");

      transform <= SHIFT_LEFT;
      wait for 100 ns;
      check(out_value = x"00010000", "SHIFT pads with zeroes to the right");

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
