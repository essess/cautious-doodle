---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all;

-- variable width shift register
entity sr is
  generic( width : integer range 2 to integer'high );
  port( d_in           : in  std_logic;
        rst_in, clk_in : in  std_logic;
        q_out          : out std_logic_vector(width-1 downto 0) );
end entity;

architecture arch of sr is
  signal q : std_logic_vector(width-1 downto 0);
begin

  q_out <= q;

  process(clk_in, rst_in, d_in)
  begin
    if rising_edge(clk_in) then
      if rst_in = '1' then
        if d_in = '1' then    --< reset/preset
          q <= (q'range => '1');
        else
          q <= (q'range => '0');
        end if;
      else                    --< shift
        q(width-1 downto 1) <= q(width-2 downto 0);
        q(0) <= d_in;
      end if;
    end if;
  end process;

end architecture;