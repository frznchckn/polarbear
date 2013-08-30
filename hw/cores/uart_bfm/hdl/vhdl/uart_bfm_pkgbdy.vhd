--------------------------------------------------------------------------------
--|
--| Filename    : uart_bfm_pkgbdy
--| Author      : Russell L Friesenhahn
--| Origin Date : 20130828
--| 
--------------------------------------------------------------------------------
--|
--| Abstract
--|
--| Package definition that provides functions and procedures that model a 
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

package body uart_bfm is

  function parityCalc (
    s : std_ulogic_vector(7 downto 0);
    parityType : std_ulogic
  )
    return std_ulogic is
    variable result : std_ulogic := parityType;
  begin
    for i in 7 downto 0 loop
      result := result xor s(i);
    end loop;

    return result;
  end parityCalc;

  procedure uart_tx_byte (
    parity : in string := "none"; -- none | odd | even
    numStopbits : in integer := 1; -- 1 | 2
    byte : in std_ulogic_vector(7 downto 0);
--     signal clk    : in  std_ulogic;
    signal tx_bit : out std_logic
  ) is
  begin
    tx_bit <= '1';
--     tx_bit <= '0' after 8695 ns;
    wait for 8681 ns;
    tx_bit <= '0';
    wait for 8681 ns;

    for i in 0 to 7
    loop
      tx_bit <= byte(i);
      wait for 8681 ns;
--       tx_bit <= byte(i) after 8695 ns;
    end loop;

    if  parity = "odd"
    then
      tx_bit <= parityCalc(byte, '1');
      wait for 8681 ns;
    elsif parity = "even"
    then
      tx_bit <= parityCalc(byte, '0');
      wait for 8681 ns;
    end if;

    tx_bit <= '1';
--     wait for 8681 ns;
--     tx_bit <= '1' after 8695 ns;
  end uart_tx_byte;
end uart_bfm;
