--------------------------------------------------------------------------------
--|
--| Filename    : uart_bfm_pkg
--| Author      : Russell L Friesenhahn
--| Origin Date : 20130820
--| 
--------------------------------------------------------------------------------
--|
--| Abstract
--|
--| Package declaration that provides functions and procedures that model a 
--| UART interface to provide BFM capabilities.
--|
--------------------------------------------------------------------------------
--|
--| Modification History
--|
--|
--|
--------------------------------------------------------------------------------
--|
--| References
--|
--|
--|
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.math_real.all;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all

package uart_bfm is

  function parityCalc (
    s : std_ulogic_vector(7 downto 0);
    parityType : std_ulogic
  ) return std_ulogic;

  procedure uart_tx_byte (
    parity : in string := "none"; -- none | odd | even
    numStopbits : in integer := 1; -- 1 | 2
    byte : in std_ulogic_vector(7 downto 0);
--     signal clk    : in  std_ulogic;
    signal tx_bit : out std_logic
  );
end uart_bfm;
