--------------------------------------------------------------------------------
--|
--| Filename    : uart
--| Author      : Russell L Friesenhahn
--| Origin Date : 20130828
--| 
--------------------------------------------------------------------------------
--|
--| Abstract
--|
--| Parameterized UART core
--|
--| BaudRateGen = ClkRate / BaudRate / 16
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
use ieee.numeric_std.all;

entity uart is
port(
  Clk         : in std_ulogic;
  Rst         : in std_ulogic;
  BaudRateGen : in std_ulogic_vector(19 downto 0);
  NumStopBits : in std_ulogic_vector(1 downto 0);
  UseParity   : in std_ulogic;
  ParityType  : in std_ulogic;
  -- rx 
  BitRx       : in std_ulogic;
  ByteTx      : out std_ulogic_vector(7 downto 0);
  ByteTxValid : out std_ulogic;
  ParErr      : out std_ulogic;
  StopErr     : out std_ulogic;
  -- tx
  ByteRx      : in std_ulogic_vector(7 downto 0);
  ByteRxValid : in std_ulogic;
  BitTx       : out std_ulogic;
  TxBusy      : out std_ulogic
);
end uart;
