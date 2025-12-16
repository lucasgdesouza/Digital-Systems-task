-- 3x3 matrix multiplier
-- Each element is 8 bits
-- PC/PO (Processo Combinacional / Processo Operacional)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity matrix_mult is
    port (
        Clock : in std_logic;
        reset : in std_logic;          -- active high reset
        start : in std_logic;          -- start multiplication
        A, B  : in unsigned(71 downto 0);
        C     : out unsigned(71 downto 0);
        done  : out std_logic           -- high when result is ready
    );
end entity;

architecture PC_PO of matrix_mult is

    -- Matrix type
    type matType is array (0 to 2, 0 to 2) of unsigned(7 downto 0);

    -- FSM states
    type state_type is (INIT, DO_MULT, APPLY_OUTPUTS);

    -- State registers
    signal state, next_state : state_type := INIT;

    -- Matrix registers
    signal matA, matB, matC : matType := (others => (others => (others => '0')));

    -- Counters
    signal i, j, k : integer range 0 to 2 := 0;

    -- Output control
    signal done_c : std_logic := '0';

begin

    ------------------------------------------------------------------
    -- PO : Processo Operacional (sequencial)
    ------------------------------------------------------------------
    PO : process (Clock, reset)
        variable temp : unsigned(15 downto 0);
    begin
        if reset = '1' then
            state <= INIT;
            i <= 0;
            j <= 0;
            k <= 0;
            matA <= (others => (others => (others => '0')));
            matB <= (others => (others => (others => '0')));
            matC <= (others => (others => (others => '0')));
            C    <= (others => '0');

        elsif rising_edge(Clock) then
            state <= next_state;

            case state is

                ------------------------------------------------------------------
                when INIT =>
                    if start = '1' then
                        -- Load matrices A and B
                        for ii in 0 to 2 loop
                            for jj in 0 to 2 loop
                                matA(ii,jj) <= A((ii*3+jj+1)*8-1 downto (ii*3+jj)*8);
                                matB(ii,jj) <= B((ii*3+jj+1)*8-1 downto (ii*3+jj)*8);
                            end loop;
                        end loop;

                        matC <= (others => (others => (others => '0')));
                        i <= 0;
                        j <= 0;
                        k <= 0;
                    end if;

                ------------------------------------------------------------------
                when DO_MULT =>
                    -- Multiply and accumulate
                    temp := matA(i,k) * matB(k,j);
                    matC(i,j) <= matC(i,j) + temp(7 downto 0);

                    -- Counter control
                    if k = 2 then
                        k <= 0;
                        if j = 2 then
                            j <= 0;
                            if i = 2 then
                                i <= 0;
                            else
                                i <= i + 1;
                            end if;
                        else
                            j <= j + 1;
                        end if;
                    else
                        k <= k + 1;
                    end if;

                ------------------------------------------------------------------
                when APPLY_OUTPUTS =>
                    -- Flatten matrix C
                    for ii in 0 to 2 loop
                        for jj in 0 to 2 loop
                            C((ii*3+jj+1)*8-1 downto (ii*3+jj)*8) <= matC(ii,jj);
                        end loop;
                    end loop;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------
    -- PC : Processo Combinacional (próximo estado e saídas)
    ------------------------------------------------------------------
    PC : process (state, start, i, j, k)
    begin
        next_state <= state;
        done_c <= '0';

        case state is

            when INIT =>
                if start = '1' then
                    next_state <= DO_MULT;
                end if;

            when DO_MULT =>
                if (i = 2 and j = 2 and k = 2) then
                    next_state <= APPLY_OUTPUTS;
                end if;

            when APPLY_OUTPUTS =>
                done_c <= '1';
                next_state <= INIT;

        end case;
    end process;

    done <= done_c;

end architecture;
