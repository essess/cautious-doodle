---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all;

entity debounce is
  generic( samples : integer range 3 to integer'high ); --< +1 latency
  port( d_in                 : in  std_logic;
        rst_in, sampleclk_in : in  std_logic;
        q_out                : out std_logic );
end entity;

architecture arch of debounce is

  component sr is
    generic( width : integer range 2 to integer'high );
    port( d_in           : in  std_logic;
          rst_in, clk_in : in  std_logic;
          q_out          : out std_logic_vector(width-1 downto 0) );
  end component;

  signal sr_q_out     : std_logic_vector(samples-1 downto 0);

begin

  shiftreg: sr
    generic map( width=>samples )
    port map( d_in=>d_in,
              rst_in=>rst_in, clk_in=>sampleclk_in,
              q_out=>sr_q_out );

  process(sampleclk_in)
    constant all_ones  : std_logic_vector(samples-1 downto 0) := (others=>'1');
    constant all_zeros : std_logic_vector(samples-1 downto 0) := (others=>'0');
    variable q : std_logic;
  begin
    if rising_edge(sampleclk_in) then
      if rst_in = '1' then  q := d_in;
      else
        case sr_q_out is
          when all_ones  => q := '1';
          when all_zeros => q := '0';
          when others    => q :=  q ;
        end case;
      end if;
    end if;
    q_out <= q;
  end process;

end architecture;