--------------------------------------------------------------------------------
--|
--| Filename    : cntr
--| Author      : R. Friesenhahn
--| Origin Date : 20130906
--| 
--------------------------------------------------------------------------------
--|
--| Abstract
--|
--| 
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

entity cntr is
generic (
  CntrWidth : integer := 8
);
port (
  Clk         : in std_ulogic;
  Rst         : in std_ulogic;
  En          : in std_ulogic;
  Clr         : in std_ulogic;
  CritValue   : in std_ulogic_vector(CntrWidth-1 downto 0);
  CntrValue   : out std_ulogic_vector(CntrWidth-1 downto 0);
  CntReached  : out std_ulogic
);
end cntr;
