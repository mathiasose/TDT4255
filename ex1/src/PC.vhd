library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    Port (
        clk : in  STD_LOGIC
        ; rst : in  STD_LOGIC := '0'
        ; instr_in : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
        ; jump : in  STD_LOGIC := '0'
        ; branch : in STD_LOGIC := '0'
        ; alu_zero : in STD_LOGIC := '0'
        ; addr_out : out  STD_LOGIC_VECTOR(31 downto 0)
    );
end PC;

architecture Behavioral of PC is
    signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); -- register
    signal jump_addr : STD_LOGIC_VECTOR(31 downto 0); -- bus
    signal imm_value : STD_LOGIC_VECTOR(15 downto 0); -- bus
    signal imm_value_extended : STD_LOGIC_VECTOR(31 downto 0); --bus
begin
    process(clk, rst)
	begin
		if rst = '1' then
			pc <= (others => '0');
		elsif rising_edge(clk) then
			if jump = '1' then
                pc <= jump_addr;
            else
                if branch = '1' and alu_zero = '1' then
                    pc <= STD_LOGIC_VECTOR(signed(pc) + signed(instr_in(15 downto 0)));
                else
                    pc <= STD_LOGIC_VECTOR(signed(pc) + 1);
                end if;
            end if;
		end if;
	end process;
    
    jump_addr <= pc(31 downto 26) & instr_in(25 downto 0);
    addr_out <= pc;
end Behavioral;

