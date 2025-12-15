----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2025 14:17:11
-- Design Name: 
-- Module Name: matrix_mult - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity matrix_mult is
  Port (
    clk, rst, start : in std_logic;
    done            : out std_logic
  );
end matrix_mult;

architecture rtl of matrix_mult is


signal EndA : std_logic_vector(5 downto 0) := "000000";
signal EndB : std_logic_vector(5 downto 0) := "001001";
signal EndC : std_logic_vector(5 downto 0) := "010010";

type t_state is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
signal state, next_state : t_state;

type mem_type is array(0 to 63) of std_logic_vector(7 downto 0);
signal mem : mem_type := (
    0 => x"01",
    1 => x"02",
    2 => x"03",
    3 => x"04",
    4 => x"05",
    5 => x"06",
    6 => x"07",
    7 => x"08",
    8 => x"09",
    9 => x"09",
    10 => x"08",
    11 => x"07",
    12 => x"06",
    13 => x"05",
    14 => x"04",
    15 => x"03",
    16 => x"02",
    17 => x"01",
    others => (others => '0')
);

signal contI, contJ, contK : std_logic_vector(2 downto 0);
signal IA, JB, KA, KB : std_logic_vector(5 downto 0);
signal acc : std_logic_vector(15 downto 0);

signal decContI, decContJ, decContK : std_logic;
signal incIA, incJB, incKA, incKB : std_logic;
signal addAcc, stMem : std_logic;

signal rstContI, rstContJ, rstContK : std_logic;
signal rstIA, rstJB, rstKA, rstKB : std_logic;
signal rstAcc : std_logic;

begin


process(clk, rstContI) begin
    if rstContI = '1' then
        contI <= "100";
    elsif rising_edge(clk) then
        if decContI = '1' then
            contI <= std_logic_vector(unsigned(contI) - 1);
        end if;
    end if;
end process;


process(clk, rstContJ) begin
    if rstContJ = '1' then
        contJ <= "100";
    elsif rising_edge(clk) then
        if decContJ = '1' then
            contJ <= std_logic_vector(unsigned(contJ) - 1);
        end if;
    end if;
end process;


process(clk, rstContK) begin
    if rstContK = '1' then
        contK <= "011";
    elsif rising_edge(clk) then
        if decContK = '1' then
            contK <= std_logic_vector(unsigned(contK) - 1);
        end if;
    end if;
end process;


process(clk, rstIA) begin
    if rstIA = '1' then
        IA <= std_logic_vector(unsigned(EndA) - 3);
    elsif rising_edge(clk) then
        if incIA = '1' then
            IA <= std_logic_vector(unsigned(IA) + 3);
        end if;
    end if;
end process;


process(clk, rstJB) begin
    if rstJB = '1' then
        JB <= std_logic_vector(unsigned(EndB) - 1);
    elsif rising_edge(clk) then
        if incJB = '1' then
            JB <= std_logic_vector(unsigned(JB) + 1);
        end if;
    end if;
end process;


process(clk, rstKA) begin
    if rstKA = '1' then
        KA <= (others => '0');
    elsif rising_edge(clk) then
        if incKA = '1' then
            KA <= std_logic_vector(unsigned(KA) + 1);
        end if;
    end if;
end process;


process(clk, rstKB) begin
    if rstKB = '1' then
        KB <= (others => '0');
    elsif rising_edge(clk) then
        if incKB = '1' then
            KB <= std_logic_vector(unsigned(KB) + 3);
        end if;
    end if;
end process;


process(clk, rstAcc) begin
    if rstAcc = '1' then
        acc <= (others => '0');
    elsif rising_edge(clk) then
        if addAcc = '1' then
            acc <= std_logic_vector(unsigned(acc) + 
            (unsigned(mem(to_integer(unsigned(IA) + unsigned(KA)))) * 
            unsigned(mem(to_integer(unsigned(JB) + unsigned(KB))))));
        end if;
    end if;
end process;


process(clk) begin
    if rising_edge(clk) and stMem = '1' then
        mem(to_integer((unsigned(IA) + unsigned(JB) - unsigned(EndA) - unsigned(EndB)) * 2 + unsigned(EndC))) <= acc(7 downto 0);
        mem(to_integer((unsigned(IA) + unsigned(JB) - unsigned(EndA) - unsigned(EndB)) * 2 + unsigned(EndC) + 1)) <= acc(15 downto 8);
    end if;
end process;


process(clk, rst) begin
    if rst = '1' then
        state <= s0;
    elsif rising_edge(clk) then
        state <= next_state;
    end if;
end process;


process(state, start) begin
    case state is
    when s0 =>
        decContI <= '0';
        decContJ <= '0';
        decContK <= '0';
        incIA <= '0';
        incJB <= '0';
        incKA <= '0';
        incKB <= '0';
        addAcc <= '0';
        stMem <= '0';
        rstContI <= '1';
        rstContJ <= '1';
        rstContK <= '1';
        rstIA <= '1';
        rstJB <= '1';
        rstKA <= '1';
        rstKB <= '1';
        rstAcc <= '1';
        done <= '0';

        if start = '1' then
            next_state <= s1;
        end if;
        
    when s1 =>
        rstContJ <= '0';
        rstContK <= '0';
        rstJB <= '0';
        rstKA <= '0';
        rstKB <= '0';
        rstAcc <= '0';
        rstContI <= '1';
        rstIA <= '1';

        next_state <= s2;
    
    when s2 =>
        rstContK <= '0';
        rstKA <= '0';
        rstKB <= '0';
        rstAcc <= '0';
        incJB <= '0';
        rstContI <= '0';
        rstIA <= '0';
        decContI <= '1';
        
        next_state <= s3;
    
    when s3 =>
        decContI <= '0';
        rstContJ <= '1';
        rstJB <= '1';
        incIA <= '1';
        
        if unsigned(contI) = 0 then
            next_state <= s9;
        else next_state <= s4;
        end if;
        
    when s4 =>
        stMem <= '0';
        rstContJ <= '0';
        rstJB <= '0';
        incIA <= '0';
        decContJ <= '1';
        
        next_state <= s5;
    
    when s5 =>
        decContJ <= '0';
        rstContK <= '1';
        rstKA <= '1';
        rstKB <= '1';
        rstAcc <= '1';
        incJB <= '1';
        
        if unsigned(contJ) = 0 then
            next_state <= s2;
        else next_state <= s6;
        end if;
    
    when s6 =>
        incKA <= '0';
        incKB <= '0';
        rstContK <= '0';
        rstKA <= '0';
        rstKB <= '0';
        rstAcc <= '0';
        incJB <= '0';
        addAcc <= '1';
        decContK <= '1';
        
        next_state <= s7;
    
    when s7 =>
        addAcc <= '0';
        decContK <= '0';
        incKA <= '1';
        incKB <= '1';
        
        if unsigned(contK) = 0 then
            next_state <= s8;
        else next_state <= s6;
        end if;
    
    when s8 =>
        incKA <= '0';
        incKB <= '0';
        stMem <= '1';
        
        next_state <= s4;
    
    when s9 =>
        decContI <= '0';
        decContJ <= '0';
        decContK <= '0';
        incIA <= '0';
        incJB <= '0';
        incKA <= '0';
        incKB <= '0';
        addAcc <= '0';
        stMem <= '0';
        rstContI <= '1';
        rstContJ <= '1';
        rstContK <= '1';
        rstIA <= '1';
        rstJB <= '1';
        rstKA <= '1';
        rstKB <= '1';
        rstAcc <= '1';
        
        done <= '1';
    end case;
end process;


end rtl;
