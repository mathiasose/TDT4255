library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tutorial is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           C : in  STD_LOGIC;
           X : out  STD_LOGIC;
           Y : out  STD_LOGIC;
           Z : out  STD_LOGIC);
end tutorial;

architecture Behavioral of tutorial is
    signal tempSignal1, tempSignal2 : std_logic;
begin
    tempSignal1 <= B or C;
    tempSignal2 <= B xor C;
    
    X <= A and B;
    Y <= tempSignal1;
    
    Z <= tempSignal1 when A = '1' else tempSignal2;
end Behavioral;

