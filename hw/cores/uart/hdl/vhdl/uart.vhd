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
generic(
  SysClkRate  : integer := 50e6;
  -- 9600 | 56400 | 115200
  BaudRate    : integer := 115200; 
  -- 1 | 2
  NumStopBits : integer := 1;
  -- true | false
  UseParity   : boolean := false;
  -- odd | even
  ParityType  : std_ulogic := '1'
);
port(
  Clk         : in std_ulogic;
  Rst         : in std_ulogic;
  DIn         : in std_ulogic;
  DOut        : out std_ulogic_vector(7 downto 0);
  DOutValid   : out std_ulogic;
  ParErr      : out std_ulogic;
  StopErr     : out std_ulogic
);
end uart;
