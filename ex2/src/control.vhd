library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity control is
    port(
        clock                       : in std_logic;
        reset                       : in std_logic;
        processor_enable            : in std_logic := '0';
        instruction                 : in instruction_t;
        immediate_value_transform   : out immediate_value_transformation_t;
        WB_signals                  : out WB_signals_t;
        MEM_signals                 : out MEM_signals_t;
        EX_signals                  : out EX_signals_t
    );
end control;

architecture Behavioral of control is
    signal opcode : opcode_t;
    signal funct : funct_t;
begin
    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);

    DrivingOutputs : process(funct, opcode, processor_enable) is
    begin
        -- Setting defaults to avoid latches
        EX_signals.reg_dst <= '0';
        EX_signals.alu_op <= NO_OP;
        EX_signals.alu_immediate <= '0';
        MEM_signals.branch <= '0';
        MEM_signals.jump <= '0';
        MEM_signals.mem_write <= '0';
        MEM_signals.mem_read <= '0';
        WB_signals.mem_to_reg <= '0';
        WB_signals.reg_write <= '0';

        immediate_value_transform <= SIGN_EXTEND;

        if processor_enable = '1' then
            case opcode is
            when ALU_OP_OPCODE =>
                WB_signals.reg_write <= '1';
                EX_signals.reg_dst <= '1';
                case funct is
                    when ADD_FUNCT =>
                        EX_signals.alu_op <= ADD;
                    when SUB_FUNCT =>
                        EX_signals.alu_op <= SUB;
                    when AND_FUNCT =>
                        EX_signals.alu_op <= ALU_AND;
                    when OR_FUNCT =>
                        EX_signals.alu_op <= ALU_OR;
                    when SLT_FUNCT =>
                        EX_signals.alu_op <= SLT;
                    when NOR_FUNCT =>
                        EX_signals.alu_op <= ALU_NOR;
                    when XOR_FUNCT =>
                        EX_signals.alu_op <= ALU_XOR;
                    when SLL_FUNCT =>
                        EX_signals.alu_op <= ALU_SLL;
                    when SRL_FUNCT =>
                        EX_signals.alu_op <= ALU_SRL;
                    when SRA_FUNCT =>
                        EX_signals.alu_op <= ALU_SRA;
                    when others =>
                        EX_signals.alu_op <= NO_OP;
                end case;
            when jump_OPCODE =>
                MEM_signals.jump <= '1';
            when BEQ_OPCODE =>
                EX_signals.alu_op <= SUB;
                MEM_signals.branch <= '1';
            when LW_OPCODE =>
                EX_signals.alu_immediate <= '1';
                EX_signals.alu_op <= ADD;
                WB_signals.mem_to_reg <= '1';
                WB_signals.reg_write <= '1';
                MEM_signals.mem_read <= '1';
            when SW_OPCODE =>
                EX_signals.alu_immediate <= '1';
                EX_signals.alu_op <= ADD;
                MEM_signals.mem_write <= '1';
            when LUI_OPCODE =>
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
                immediate_value_transform <= SHIFT_LEFT;
            when ADDI_OPCODE =>
                EX_signals.alu_op <= ADD;
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
            when ANDI_OPCODE =>
                EX_signals.alu_op <= ALU_AND;
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
            when ORI_OPCODE =>
                EX_signals.alu_op <= ALU_OR;
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
            when XORI_OPCODE =>
                EX_signals.alu_op <= ALU_XOR;
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
            when SLTI_OPCODE =>
                EX_signals.alu_op <= SLT;
                EX_signals.alu_immediate <= '1';
                WB_signals.reg_write <= '1';
            when others =>
                --
            end case;
        end if;
    end process DrivingOutputs;
end Behavioral;
