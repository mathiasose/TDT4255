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
        wb_signals                  : out wb_signals_t;
        mem_signals                 : out mem_signals_t;
        ex_signals                  : out ex_signals_t
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
        ex_signals.reg_dst <= '0';
        ex_signals.alu_op <= NO_OP;
        ex_signals.alu_immediate <= '0';
        mem_signals.branch <= '0';
        mem_signals.jump <= '0';
        mem_signals.mem_write <= '0';
        wb_signals.mem_to_reg <= '0';
        wb_signals.reg_write <= '0';

        immediate_value_transform <= SIGN_EXTEND;

        if processor_enable = '1' then
            case opcode is
            when ALU_OP_OPCODE =>
                wb_signals.reg_write <= '1';
                ex_signals.reg_dst <= '1';
                case funct is
                    when ADD_FUNCT =>
                        ex_signals.alu_op <= ADD;
                    when SUB_FUNCT =>
                        ex_signals.alu_op <= SUB;
                    when AND_FUNCT =>
                        ex_signals.alu_op <= ALU_AND;
                    when OR_FUNCT =>
                        ex_signals.alu_op <= ALU_OR;
                    when SLT_FUNCT =>
                        ex_signals.alu_op <= SLT;
                    when NOR_FUNCT =>
                        ex_signals.alu_op <= ALU_NOR;
                    when XOR_FUNCT =>
                        ex_signals.alu_op <= ALU_XOR;
                    when SLL_FUNCT =>
                        ex_signals.alu_op <= ALU_SLL;
                    when SRL_FUNCT =>
                        ex_signals.alu_op <= ALU_SRL;
                    when SRA_FUNCT =>
                        ex_signals.alu_op <= ALU_SRA;
                    when others =>
                        ex_signals.alu_op <= NO_OP;
                end case;
            when jump_OPCODE =>
                mem_signals.jump <= '1';
            when BEQ_OPCODE =>
                ex_signals.alu_op <= SUB;
                mem_signals.branch <= '1';
            when LW_OPCODE =>
                ex_signals.alu_immediate <= '1';
                ex_signals.alu_op <= ADD;
                wb_signals.mem_to_reg <= '1';
                wb_signals.reg_write <= '1';
            when SW_OPCODE =>
                ex_signals.alu_immediate <= '1';
                ex_signals.alu_op <= ADD;
                mem_signals.mem_write <= '1';
            when LUI_OPCODE =>
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
                immediate_value_transform <= SHIFT_LEFT;
            when ADDI_OPCODE =>
                ex_signals.alu_op <= ADD;
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
            when ANDI_OPCODE =>
                ex_signals.alu_op <= ALU_AND;
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
            when ORI_OPCODE =>
                ex_signals.alu_op <= ALU_OR;
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
            when XORI_OPCODE =>
                ex_signals.alu_op <= ALU_XOR;
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
            when SLTI_OPCODE =>
                ex_signals.alu_op <= SLT;
                ex_signals.alu_immediate <= '1';
                wb_signals.reg_write <= '1';
            when others =>
                --
            end case;
        end if;
    end process DrivingOutputs;
end Behavioral;
