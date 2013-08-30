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



  -----------------------------
  -- Constant Declarations  
  -----------------------------
  constant clk16Gen : integer := SysClkRate / BaudRate / 16;



  -----------------------------
  -- Type Declarations  
  -----------------------------
  type state is (
    IDLE,
    START,
    RX,
    PARITYCK,
    STOP,
    ERR
  );



  -----------------------------
  -- Signal Declarations  
  -----------------------------
  signal clkCntr    : unsigned(15 downto 0);
  signal clk16Pulse : std_ulogic;


  signal cs     : state;
  signal din_d0 : std_ulogic;
  signal din_d1 : std_ulogic;
  signal din_d2 : std_ulogic;
  signal clk16Cnt : unsigned(3 downto 0);
--   signal dout_int : std_ulogic_vector(7 downto 0);
  signal rxCnt    : unsigned(3 downto 0);
  signal dout_i : std_ulogic_vector(7 downto 0);
  signal parity : std_ulogic;

begin

  DOut <= dout_i;

  CLK16_PULSE_GEN : process (Clk)
  begin
    if  Clk'event and Clk = '1'
    then
      if Rst = '1'
      then
        clkCntr <= (others => '0');
        clk16Pulse <= '0';
      else
        if  clkCntr = to_unsigned(clk16Gen, clkCntr'length)
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
        din_d0 <= DIn;
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
        cs <= IDLE;
        dout_i <= (others => '0');
        ParErr <= '0';
        StopErr <= '0';
        parity <= ParityType;
      else

        CO_RX_SM : case cs is

          when IDLE =>

            DOutValid <= '0';

            rxCnt <= (others => '0');

            if      din_d1 = '0'
                and din_d2 = '1'
            then
              cs <= START;
            end if;

          when START =>
            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if din_d2 = '0'
              then
                cs <= RX;
              else
                cs <= IDLE;
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
              if  UseParity = true
              then
                cs <= PARITYCK;
              else
                cs <= STOP;
              end if;
            end if;

          when PARITYCK =>
            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if  parity /= din_d2
              then
                ParErr <= '1';
                cs <= ERR;

                assert false
                  report "ERROR: parity incorrect"
                  severity error;
              else
                cs <= STOP;
              end if;
            end if;
            
          when STOP =>

            if clk16Pulse = '1'
                and clk16Cnt = to_unsigned(7, 4)
            then
              if din_d2 = '1'
              then
                DoutValid <= '1';
                cs <= IDLE;
              else
                StopErr <= '1';
                cs <= ERR;
              end if;
            end if;

          when ERR =>
            ParErr <= '0';
            StopErr <= '0';
            cs <= IDLE;
        end case;
      end if;
    end if;
  end process P_RX;
end architecture bhv;  
