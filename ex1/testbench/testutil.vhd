library ieee;
use ieee.std_logic_1164.all;
--use work.defs.all;

package testutil is

  type machine_operation_t is (OP_PUSH, OP_ADD, OP_SUB);

    procedure check (
      condition : in boolean;
      error_msg : in string);
    
end package testutil;

package body testutil is

      procedure check (
      condition : in boolean;
      error_msg : in string) is
    begin  -- procedure check
      assert condition report error_msg severity failure;
    end procedure check;

end package body testutil;
