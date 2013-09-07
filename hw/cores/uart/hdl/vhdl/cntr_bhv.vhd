--------------------------------------------------------------------------------
--|
--| Filename    : cntr_bhv
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

architecture bhv of cntr is
  signal cntr : unsigned(CntrWidth-1 downto 0);
begin
  CntrValue <= std_ulogic_vector(cntr);

  P_CNTR : process (Clk)
  begin
    if Clk'event and Clk = '1' then
      if Rst = '1' then
        cntr <= (others => '0');
        CntReached <= '0';
      else
        CntReached <= '0';

        if En = '1' then
          if Clr = '1' then
            cntr <= (others => '0');
          elsif  cntr = (unsigned(CritValue) - to_unsigned(1, CritValue'length)) then
            CntReached <= '1';
            cntr <= (others => '0');
          else
            cntr <= cntr + 1;
          end if;
        end if;
      end if;
    end if;
  end process P_CNTR;
end architecture bhv;
