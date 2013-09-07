--------------------------------------------------------------------------------
--|
--| Filename    : uart_bhv
--| Author      : Russell L Friesenhahn
--| Origin Date : 20130828
--| 
--------------------------------------------------------------------------------
--|
--| Abstract
--|
--| Behavorial architecture of UART core
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

architecture bhv of uart is 

  -----------------------------
  -- Component Declarations  
  -----------------------------

  component cntr is
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
  end component;


  -----------------------------
  -- Constant Declarations  
  -----------------------------
--   constant clk16Gen : integer := SysClkRate / BaudRate / 16;



  -----------------------------
  -- Type Declarations  
  -----------------------------
  type rxst is (
    IDLE,
    START,
    RX,
    PARITYCK,
    STOP,
    ERR
  );

  type txst is (
    IDLE,
    START,
    TX,
    TXPARITY,
    STOP
  );

  -----------------------------
  -- Signal Declarations  
  -----------------------------
  signal clkCntr    : unsigned(19 downto 0);
  signal clkTxCntr : unsigned(23 downto 0);
--   signal clkTxGen  : unsigned(23 downto 0);
  signal clkTxGen  : std_ulogic_vector(23 downto 0);
  signal ClkTxPulse : std_ulogic;
  signal startTxCntr : std_ulogic;
  signal clk16Pulse : std_ulogic;


  signal rxcs     : rxst;
  signal din_d0 : std_ulogic;
  signal din_d1 : std_ulogic;
  signal din_d2 : std_ulogic;
  signal clk16Cnt : unsigned(3 downto 0);
--   signal dout_int : std_ulogic_vector(7 downto 0);
  signal rxCnt    : unsigned(3 downto 0);
  signal dout_i : std_ulogic_vector(7 downto 0);
  signal parity : std_ulogic;

  signal txcs     : txst;
  signal bitTxParity : std_ulogic;
  signal txCnt    : unsigned(2 downto 0);
  signal byteRx_d1  : std_ulogic_vector(7 downto 0);
  signal byteRx_d2  : std_ulogic_vector(7 downto 0);
  signal byteRxValid_d1 : std_ulogic;
  signal txBusy_i : std_ulogic;

begin

  ByteTx <= dout_i;
  TxBusy <= txBusy_i;

  clkTxGen <= BaudRateGen & X"0";

  cntr_tx : cntr
  generic map (
    CntrWidth => 24
  )
  port map (
    Clk         => Clk,
    Rst         => Rst,
    En          => '1',
    Clr         => startTxCntr,
    CritValue   => clkTxGen,
    CntrValue   => open,
    CntReached  => ClkTxPulse
  );

  P_TX : process (Clk)
  begin
    if Clk'event and Clk = '1' then
      if Rst = '1' then
        BitTx <= '1';
        txBusy_i <= '1';
        clkTxCntr <= (others => '0');
        byteRxValid_d1 <= '0';
        startTxCntr <= '0';
      else

        if ByteRxValid = '1' and txBusy_i = '0' then
          byteRx_d1 <= ByteRx;
          byteRxValid_d1 <= ByteRxValid;
          txBusy_i <= '1';
        end if;

        C_TX : case txcs is
          when IDLE =>
            txBusy_i <= '0';
            BitTx <= '1';
            bitTxParity <= ParityType;
            txCnt <= (others => '0');

            if byteRxValid_d1 = '1' then
              byteRx_d2 <= byteRx_d1;
              startTxCntr <= '1';
              txBusy_i <= '1';
              txcs <= START;
              byteRxValid_d1 <= '0';
            end if;

          when START =>
            startTxCntr <= '0';
            BitTx <= '0';

            if ClkTxPulse = '1' then
              txcs <= TX;
              BitTx <= byteRx_d1(0);
              bitTxParity <= bitTxParity xor byteRx_d1(0);
              txCnt <= txCnt + 1;
            end if;
          when TX =>
            if ClkTxPulse = '1' then
              if txCnt = to_unsigned(0, txCnt'length) then
                BitTx <= bitTxParity;
                txcs <= TXPARITY;
              else
                BitTx <= byteRx_d1(to_integer(txCnt));
                bitTxParity <= bitTxParity xor byteRx_d1(to_integer(txCnt));
                txCnt <= txCnt + 1;
              end if;
            end if;
          when TXPARITY =>
            if ClkTxPulse = '1' then
              BitTx <= '1';
              txcs <= STOP;
            end if;
          when STOP =>
            txBusy_i <= '0';
            if ClkTxPulse = '1' then
              BitTx <= '1';
              txcs <= IDLE;
            end if;
          when others => null;
        end case C_TX;
      end if;
    end if;
  end process P_TX;

  CLK16_PULSE_GEN : process (Clk)
  begin
    if  Clk'event and Clk = '1'
    then
      if Rst = '1'
      then
        clkCntr <= (others => '0');
        clk16Pulse <= '0';
      else
--         if  clkCntr = to_unsigned(clk16Gen, clkCntr'length)
        if  clkCntr = unsigned(BaudRateGen)
        then
          clkCntr <= (others => '0');
          clk16Pulse <= '1';
        else
          clkCntr <= clkCntr + 1;
          clk16Pulse <= '0';
        end if;
      end if;
    end if;
  end  process CLK16_PULSE_GEN;

  P_STABLE_DATA : process (Clk)
  begin
    if Clk'event and Clk = '1'
    then
      if Rst = '1'
      then
        din_d0 <= '0';
        din_d1 <= '0';
        din_d2 <= '0';
      else
        din_d2 <= din_d1;
        din_d1 <= din_d0;
        din_d0 <= BitRx;
      end if;
    end if;
  end process P_STABLE_DATA;
  
  P_CLK16_CNTR : process (Clk)
  begin
    if Clk'event and Clk = '1'
    then
      if Rst = '1'
      then
        clk16Cnt <= (others => '0');
      else
        if clk16Pulse = '1'
        then
          clk16Cnt <= clk16Cnt + 1;
        end if;

        if din_d1 /= din_d2
        then
          clk16Cnt <= (others => '0');
        end if;
      end if;
    end if;
  end process P_CLK16_CNTR;
  
  P_RX : process (Clk)
  begin
    if Clk'event and Clk = '1'
    then
      if Rst = '1'
      then
        rxcs <= IDLE;
        dout_i <= (others => '0');
        ParErr <= '0';
        StopErr <= '0';
      else

        CO_RX_SM : case rxcs is

          when IDLE =>

            ByteTxValid <= '0';

            rxCnt <= (others => '0');

            parity <= ParityType;

            if      din_d1 = '0'
                and din_d2 = '1'
            then
              rxcs <= START;
            end if;

          when START =>
            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if din_d2 = '0'
              then
                rxcs <= RX;
              else
                rxcs <= IDLE;
              end if;
            end if;

          when RX =>
            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              rxCnt <= rxCnt + 1;
            end if;

            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              dout_i <= din_d2 & dout_i(7 downto 1);
              parity <= parity xor din_d2;
            end if;

            if rxCnt = to_unsigned(8, 4)
            then
              if  UseParity = '1'
              then
                rxcs <= PARITYCK;
              else
                rxcs <= STOP;
              end if;
            end if;

          when PARITYCK =>
            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if  parity /= din_d2
              then
                ParErr <= '1';
                rxcs <= ERR;

                assert false
                  report "ERROR: parity incorrect"
                  severity error;
              else
                rxcs <= STOP;
              end if;
            end if;
            
          when STOP =>

            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if din_d2 = '1'
              then
                ByteTxValid <= '1';
                rxcs <= IDLE;
              else
                StopErr <= '1';
                rxcs <= ERR;
              end if;
            end if;

          when ERR =>
            ParErr <= '0';
            StopErr <= '0';
            rxcs <= IDLE;
        end case;
      end if;
    end if;
  end process P_RX;
end architecture bhv;  
