---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity enc is
  generic( cntwidth : positive );
  port( clk_in  : in  std_logic;
        data_in : in  std_logic;
        rst_in  : in  std_logic;
        cnt_out : out unsigned(cntwidth-1 downto 0) );
end entity;

architecture arch of enc is
begin

  process(clk_in, rst_in)
    variable enccnt : unsigned(cntwidth-1 downto 0);
  begin
    if rst_in = '1' then
      enccnt := to_unsigned(0, enccnt'length);
    elsif falling_edge(clk_in) then
      if data_in = '1' then
        enccnt := enccnt +1;  --< ++, clockwise
      else
        enccnt := enccnt -1;  --< --, counterclockwise
      end if;
    end if;
    cnt_out <= enccnt;
  end process;

end architecture;