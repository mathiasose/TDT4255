LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
use work.defs.all;
 
ENTITY tb_ex_PC IS
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
END tb_ex_PC;
 
ARCHITECTURE behavior OF tb_ex_PC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ex_PC
    Port (
        pc_in           : in pc_t
    ;   immediate_value : in operand_t
    ;   j_value         : in jump_value_t
    ;   branch_address  : out pc_t
    ;   jump_address    : out pc_t
    );
    END COMPONENT;

    --Inputs
    signal pc_in            : pc_t;
    signal immediate_value  : operand_t;
    signal j_value          : jump_value_t;

    --Outputs
    signal branch_address : pc_t;
    signal jump_address : pc_t;

    -- Clock period definitions
    constant clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: ex_PC PORT MAP (
        pc_in => pc_in,
        immediate_value => immediate_value,
        j_value => j_value,
        branch_address => branch_address,
        jump_address => jump_address
    );

    -- Stimulus process
    stim_proc: process
    begin
        wait for clock_period;

        pc_in <= x"80000000";
        immediate_value <= x"00000001";
        j_value <= (others => '1');
        wait for clock_period;
        check(branch_address=x"80000001", "Check calculated branch address");
        check(jump_address="100000" & "11" & x"FFFFFF", "Check calculated jump address");

        report "ALL TESTS SUCCESSFUL";
        wait;
    end process;

END;
