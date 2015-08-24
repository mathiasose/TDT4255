library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity blinky is
    generic(
        ticksBeforeLevelChange : integer := 24000000;
        ticksForPeriod : integer := 48000000
    );
    Port (
        clk, reset : in STD_LOGIC;
        pulse : out STD_LOGIC
    );
end blinky;

architecture Behavioral of blinky is
    signal tickCount : unsigned(31 downto 0);
begin
    CountPeriodTicks: process(clk, reset)
    begin
        if reset = '1' then
            tickCount <= (others => '0');
        elsif rising_edge(clk) then
            if tickCount < ticksForPeriod then
                tickCount <= tickCount + 1;
            else
                tickCount <= (others => '0');
            end if;
        end if;
    end process;
    
    pulse <= '0' when tickCount < ticksBeforeLevelChange else '1';
end Behavioral;

