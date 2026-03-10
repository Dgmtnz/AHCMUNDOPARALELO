------------------------------------------------------------------------------------
--
-- CRC-8 Peripheral for PicoBlaze
-- 
-- This peripheral calculates a CRC-8 checksum for data integrity verification.
-- Used to verify that encryption/decryption operations are correct.
--
-- CRC-8 polynomial: x^8 + x^2 + x + 1 (0x07)
-- This is a simple and efficient CRC for 8-bit data verification.
--
-- Interface:
--   - Write to port: data byte to include in CRC calculation
--   - Read from port: current CRC value
--   - Write 0x00 to reset CRC to initial value
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity crc_peripheral is
    Port (
        clk          : in std_logic;
        reset        : in std_logic;
        write_strobe : in std_logic;
        read_strobe  : in std_logic;
        port_id      : in std_logic_vector(7 downto 0);
        data_in      : in std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0);
        crc_port_sel : out std_logic
    );
end crc_peripheral;

architecture behavioral of crc_peripheral is
    constant CRC_DATA_PORT  : std_logic_vector(7 downto 0) := x"40";
    constant CRC_RESET_PORT : std_logic_vector(7 downto 0) := x"41";
    
    signal crc_reg : std_logic_vector(7 downto 0) := x"00";
    signal crc_next : std_logic_vector(7 downto 0);
    signal port_selected : std_logic;
    
begin
    port_selected <= '1' when (port_id = CRC_DATA_PORT or port_id = CRC_RESET_PORT) else '0';
    crc_port_sel <= port_selected;
    
    -- CRC-8 calculation (polynomial 0x07: x^8 + x^2 + x + 1)
    process(crc_reg, data_in)
        variable crc_temp : std_logic_vector(7 downto 0);
        variable data_temp : std_logic_vector(7 downto 0);
        variable feedback : std_logic;
    begin
        crc_temp := crc_reg;
        data_temp := data_in;
        
        for i in 7 downto 0 loop
            feedback := crc_temp(7) xor data_temp(i);
            crc_temp(7) := crc_temp(6);
            crc_temp(6) := crc_temp(5);
            crc_temp(5) := crc_temp(4);
            crc_temp(4) := crc_temp(3);
            crc_temp(3) := crc_temp(2);
            crc_temp(2) := crc_temp(1) xor feedback;
            crc_temp(1) := crc_temp(0) xor feedback;
            crc_temp(0) := feedback;
        end loop;
        
        crc_next <= crc_temp;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                crc_reg <= x"00";
            elsif write_strobe = '1' then
                if port_id = CRC_RESET_PORT then
                    crc_reg <= x"00";
                elsif port_id = CRC_DATA_PORT then
                    crc_reg <= crc_next;
                end if;
            end if;
        end if;
    end process;
    
    data_out <= crc_reg;
    
end behavioral;
