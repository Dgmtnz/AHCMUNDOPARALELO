------------------------------------------------------------------------------------
--
-- Definition of an 8-bit Caesar cipher process
-- Operation
--
-- CESAR: Y = (operand + shift_amount) mod 256
-- CESARINV: Y = (operand - shift_amount) mod 256
--
-- Implements Caesar cipher encryption/decryption for the PicoBlaze ALU
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cesar is
    Port (operand : in std_logic_vector(7 downto 0);      -- Character to encrypt/decrypt
          shift_amount : in std_logic_vector(7 downto 0); -- Number of positions to shift
          decrypt : in std_logic;                          -- '0' = encrypt (CESAR), '1' = decrypt (CESARINV)
          Y : out std_logic_vector(7 downto 0);           -- Result
          clk : in std_logic);
end cesar;
--
architecture low_level_definition of cesar is
--
signal result_encrypt : std_logic_vector(8 downto 0);
signal result_decrypt : std_logic_vector(8 downto 0);
signal final_result   : std_logic_vector(7 downto 0);
--
begin
  -- Caesar cipher: simple modular addition/subtraction
  -- For encryption: Y = (X + K) mod 256
  -- For decryption: Y = (X - K) mod 256
  
  result_encrypt <= ('0' & operand) + ('0' & shift_amount);
  result_decrypt <= ('0' & operand) - ('0' & shift_amount);
  
  -- Select encryption or decryption based on decrypt signal
  final_result <= result_encrypt(7 downto 0) when decrypt = '0' else
                  result_decrypt(7 downto 0);
  
  -- Pipeline register for timing consistency with other ALU operations
  process (clk)
  begin
    if (clk'event and clk = '1') then
      Y <= final_result;
    end if;
  end process;
--
end low_level_definition;

