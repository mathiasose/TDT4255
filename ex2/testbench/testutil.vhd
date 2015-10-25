library ieee;
use ieee.std_logic_1164.all;

package testutil is

    procedure check (
        condition : in boolean;
        error_msg : in string
    );

end package testutil;

package body testutil is

    procedure check (
        condition : in boolean;
        error_msg : in string
    ) is begin
        assert condition report error_msg severity failure;
        report "TEST SUCCESS: " & error_msg;
    end procedure check;

end package body testutil;
