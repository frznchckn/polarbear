library ieee;
use ieee.std_logic_1164.all;
-- use ieee.math_real.all;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all

library uart_bfm;
use uart_bfm.uart_bfm.all;

-- library uart_rx;
-- use uart_rx.uart_rx;

entity uart_tb is
end uart_tb;

architecture tb of uart_tb is

  component uart is
  generic(
    SysClkRate  : integer := 50e6;
    -- 9600 | 56400 | 115200
    BaudRate    : integer := 115200; 
    -- 1 | 2
    NumStopBits : integer := 1;
    -- true | false
    UseParity   : boolean := true;
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
  end component;

  component uart_rx is
  generic(
    NumDataBits : integer := 8;
    NumStopBits : integer := 1;
    UseParity   : boolean := true;
    ParityType  : string  := "odd"
  );
  port(
    Clk         : in std_ulogic;
    Rst         : in std_ulogic;
    Clk16       : in std_ulogic;
    DIn         : in std_ulogic;
    DOut        : out std_ulogic_vector(7 downto 0);
    DoutValid   : out std_ulogic;
    ParErr      : out std_ulogic;
    StopErr     : out std_ulogic
  );
  end component;

  signal byte : std_ulogic_vector(7 downto 0) := X"A5";
  signal uart_tx : std_logic;

  signal clk : std_ulogic := '1';
--   signal clk16 : std_ulogic := '1';
  signal rst : std_ulogic := '1';
  signal dout : std_ulogic_vector(7 downto 0);
  signal doutValid : std_ulogic;

  signal test_done : std_ulogic := '0';

begin

--   uart_rx_0 : uart_rx
--   port map (
--     Clk         => clk,
--     Rst         => rst,
--     Clk16       => clk16,
--     DIn         => uart_tx,
--     DOut        => dout,
--     DoutValid   => doutValid,
--     ParErr      => open,
--     StopErr     => open
--   );

  uart_0 : uart
  generic map(
    SysClkRate  => 100e6,
    -- 9600 | 56400 | 115200
    BaudRate    => 115200,
    -- 1 | 2
    NumStopBits => 1,
    -- true | false
    UseParity   => true,
    -- odd | even
    ParityType  => '1' 
  )
  port map (
    Clk         => clk,
    Rst         => rst,
    DIn         => uart_tx,
    DOut        => dout,
    DoutValid   => doutValid,
    ParErr      => open,
    StopErr     => open
  );

  P_CLK : process
  begin
    clk <= '0';
    loop
      wait for 5 ns;
      clk <= not clk;
      exit when test_done = '1';
    end loop;
    assert test_done = '0'
      report "test run completed"
      severity note;
--     loop
--       clk <= not clk after 5 ns;
--       exit when test_done = '1';
--     end loop;
    wait;
  end process P_CLK;

  rst <= '0' after 15 ns;
--   clk16 <= not clk16 after 271 ns;


  P_STIMULUS : process
  begin
    wait for 100 ns;
    uart_tx_byte("odd", 1, x"A5", uart_tx);
    uart_tx_byte("odd", 1, x"FF", uart_tx);
    uart_tx_byte("odd", 1, x"00", uart_tx);
    uart_tx_byte("odd", 1, x"15", uart_tx);
    wait for 10 us;
    test_done <= '1';
    wait;
  end process P_STIMULUS;
  
end tb;
