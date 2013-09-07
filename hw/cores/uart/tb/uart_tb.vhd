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
  port(
    Clk         : in std_ulogic;
    Rst         : in std_ulogic;
    BaudRateGen : in std_ulogic_vector(19 downto 0);
    NumStopBits : in std_ulogic_vector(1 downto 0);
    UseParity   : in std_ulogic;
    ParityType  : in std_ulogic;
    -- rx
    BitRx         : in std_ulogic;
    ByteTx        : out std_ulogic_vector(7 downto 0);
    ByteTxValid   : out std_ulogic;
    ParErr      : out std_ulogic;
    StopErr     : out std_ulogic;
    -- tx
    ByteRx      : in std_ulogic_vector(7 downto 0);
    ByteRxValid : in std_ulogic;
    BitTx       : out std_ulogic;
    TxBusy      : out std_ulogic
  );
  end component;

  signal byte : std_ulogic_vector(7 downto 0) := X"A5";
  signal uart_tx : std_logic;

  signal clk : std_ulogic := '1';
  signal rst : std_ulogic := '1';
  signal dout : std_ulogic_vector(7 downto 0);
  signal doutValid : std_ulogic;
  signal uartByteRx : std_ulogic_vector(7 downto 0);
  signal uartByteRxValid : std_ulogic;
  signal uartBitTx        : std_ulogic;
  signal uartTxBusy : std_ulogic;

  signal test_done : std_ulogic := '0';

begin

  uart_0 : uart
  port map (
    Clk         => clk,
    Rst         => rst,
    BaudRateGen => X"00036",
    NumStopBits => "01",
    UseParity   => '1',
    ParityType  => '1',
    BitRx       => uart_tx,
--     ByteTx      => dout,
--     ByteTxValid => doutValid,
    ByteTx      => uartByteRx,
    ByteTxValid => uartByteRxValid,
    ParErr      => open,
    StopErr     => open,
    -- tx
    ByteRx      => uartByteRx,
    ByteRxValid => uartByteRxValid,
    BitTx       => uartBitTx,
    TxBusy      => uartTxBusy
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
    wait for 150 us;
    test_done <= '1';
    wait;
  end process P_STIMULUS;
  
end tb;
