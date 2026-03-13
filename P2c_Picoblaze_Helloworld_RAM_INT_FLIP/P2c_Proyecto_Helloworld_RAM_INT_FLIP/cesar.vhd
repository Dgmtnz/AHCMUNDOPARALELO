------------------------------------------------------------------------------------
--
-- Definition of an 8-bit Caesar cipher process
-- Operation
--
-- Real Caesar cipher with alphabet/digit wrapping:
--   Uppercase (A-Z): wraps within A-Z (mod 26)
--   Lowercase (a-z): wraps within a-z (mod 26)
--   Digits    (0-9): wraps within 0-9 (mod 10)
--   Other characters: passed through unchanged
--
-- CESAR sX, kk    : encrypt (shift forward)
-- CESARINV sX, kk : decrypt (shift backward)
--
-- Constraint: shift_amount must be < 26 for letters, < 10 for digits
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cesar is
    Port (operand : in std_logic_vector(7 downto 0);
          shift_amount : in std_logic_vector(7 downto 0);
          decrypt : in std_logic;
          Y : out std_logic_vector(7 downto 0);
          clk : in std_logic);
end cesar;
--
architecture low_level_definition of cesar is
--
signal is_upper : std_logic;
signal is_lower : std_logic;
signal is_digit : std_logic;

signal offset_upper : std_logic_vector(7 downto 0);
signal offset_lower : std_logic_vector(7 downto 0);
signal offset_digit : std_logic_vector(7 downto 0);

signal enc_upper_raw : std_logic_vector(7 downto 0);
signal enc_lower_raw : std_logic_vector(7 downto 0);
signal enc_digit_raw : std_logic_vector(7 downto 0);

signal dec_upper_raw : std_logic_vector(7 downto 0);
signal dec_lower_raw : std_logic_vector(7 downto 0);
signal dec_digit_raw : std_logic_vector(7 downto 0);

signal enc_upper : std_logic_vector(7 downto 0);
signal enc_lower : std_logic_vector(7 downto 0);
signal enc_digit : std_logic_vector(7 downto 0);

signal dec_upper : std_logic_vector(7 downto 0);
signal dec_lower : std_logic_vector(7 downto 0);
signal dec_digit : std_logic_vector(7 downto 0);

signal final_result : std_logic_vector(7 downto 0);
--
begin
  -- Character range detection
  is_upper <= '1' when (operand >= x"41" and operand <= x"5A") else '0';
  is_lower <= '1' when (operand >= x"61" and operand <= x"7A") else '0';
  is_digit <= '1' when (operand >= x"30" and operand <= x"39") else '0';

  -- Offset from range base
  offset_upper <= operand - x"41";
  offset_lower <= operand - x"61";
  offset_digit <= operand - x"30";

  -- Encrypt: (offset + shift) mod N
  enc_upper_raw <= offset_upper + shift_amount;
  enc_upper <= enc_upper_raw - x"1A" when enc_upper_raw >= x"1A" else enc_upper_raw;

  enc_lower_raw <= offset_lower + shift_amount;
  enc_lower <= enc_lower_raw - x"1A" when enc_lower_raw >= x"1A" else enc_lower_raw;

  enc_digit_raw <= offset_digit + shift_amount;
  enc_digit <= enc_digit_raw - x"0A" when enc_digit_raw >= x"0A" else enc_digit_raw;

  -- Decrypt: (offset + N - shift) mod N
  dec_upper_raw <= offset_upper + x"1A" - shift_amount;
  dec_upper <= dec_upper_raw - x"1A" when dec_upper_raw >= x"1A" else dec_upper_raw;

  dec_lower_raw <= offset_lower + x"1A" - shift_amount;
  dec_lower <= dec_lower_raw - x"1A" when dec_lower_raw >= x"1A" else dec_lower_raw;

  dec_digit_raw <= offset_digit + x"0A" - shift_amount;
  dec_digit <= dec_digit_raw - x"0A" when dec_digit_raw >= x"0A" else dec_digit_raw;

  -- Result mux: select based on character type and encrypt/decrypt
  final_result <=
    (enc_upper + x"41") when (decrypt = '0' and is_upper = '1') else
    (enc_lower + x"61") when (decrypt = '0' and is_lower = '1') else
    (enc_digit + x"30") when (decrypt = '0' and is_digit = '1') else
    (dec_upper + x"41") when (decrypt = '1' and is_upper = '1') else
    (dec_lower + x"61") when (decrypt = '1' and is_lower = '1') else
    (dec_digit + x"30") when (decrypt = '1' and is_digit = '1') else
    operand;

  -- Pipeline register for timing consistency with other ALU operations
  process (clk)
  begin
    if (clk'event and clk = '1') then
      Y <= final_result;
    end if;
  end process;
--
end low_level_definition;
