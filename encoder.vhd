---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity top is
  port( clk50M                         : in  std_logic;
        encclk, encdata, encsw         : in  std_logic;
        btn                            : in  std_logic_vector(2 downto 1);
        led                            : out std_logic_vector(1 downto 1);
        sseg_an                        : out std_logic_vector(3 downto 0);
        sseg_a, sseg_b, sseg_c, sseg_d : out std_logic;
        sseg_e, sseg_f, sseg_g         : out std_logic );
end entity;

architecture arch of top is

  component sseg is
    port( value_in : in  unsigned(15 downto 0);
          enb_in   : in  std_logic;
          clk_in   : in  std_logic;
          an_out   : out std_logic_vector(3 downto 0);
          seg_out  : out std_logic_vector(6 downto 0) );
  end component;

  component debounce is
    generic( samples : integer := 3 );
    port( d_in                 : in  std_logic;
          rst_in, sampleclk_in : in  std_logic;
          q_out                : out std_logic );
  end component;

  component enc is
    generic( cntwidth : positive := 8 );
    port( clk_in  : in  std_logic;
          data_in : in  std_logic;
          rst_in  : in  std_logic;
          cnt_out : out unsigned(cntwidth-1 downto 0) );
  end component;

  signal clk : unsigned(31 downto 0);
  signal db_encclk, db_encdata, db_encsw : std_logic;

  constant cntwidth : positive := 16;
  signal enccnt : unsigned(cntwidth-1 downto 0);

begin

  db0 : debounce    --< debounce encoder clk line
    generic map( samples => 8 )
    port map( d_in         => encclk,
              rst_in       => btn(1),
              sampleclk_in => clk(5),     --< 781250Hz (x8: 10.24us)
              q_out        => db_encclk );

  db1 : debounce    --< debounce encoder data line
    generic map( samples => 8 )
    port map( d_in         => encdata,
              rst_in       => btn(1),
              sampleclk_in => clk(5),     --< 781250Hz (x8: 10.24us)
              q_out        => db_encdata );

  db2 : debounce    --< debounce encoder press switch
    generic map( samples => 4 )
    port map( d_in         => encsw,
              rst_in       => btn(1),
              sampleclk_in => clk(13),    --< 3052Hz (x4: 1.3ms)
              q_out        => db_encsw );
  led(1) <= not(db_encsw);

  enc0 : enc
    generic map( cntwidth => cntwidth )
    port map( clk_in  => db_encclk,
              data_in => db_encdata,
              rst_in  => btn(1),
              cnt_out => enccnt );

  sseg0 : sseg
    port map( value_in   => enccnt,
              enb_in     => not(btn(2)),
              clk_in     => clk(14),      --< ~1.5KHz (380Hz update rate)
              an_out     => sseg_an,
              seg_out(0) => sseg_a,
              seg_out(1) => sseg_b,
              seg_out(2) => sseg_c,
              seg_out(3) => sseg_d,
              seg_out(4) => sseg_e,
              seg_out(5) => sseg_f,
              seg_out(6) => sseg_g );

  process(clk50M)
  begin
    if rising_edge(clk50M) then
      if btn(1) = '1' then
        clk    <= to_unsigned(0,    clk'length);
      else
        clk <= clk +1;
      end if;
    end if;
  end process;

end architecture;