---
 -- Copyright (c) 2019 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity top is
  port( clk50M                         : in  std_logic;
        enc_a, enc_b, enc_sw           : in  std_logic;
        arst                           : in  std_logic;
        sseg_an                        : out std_logic_vector(3 downto 0);
        sseg_a, sseg_b, sseg_c, sseg_d : out std_logic;
        sseg_e, sseg_f, sseg_g         : out std_logic );
end entity;

architecture dfault of top is

  component enbdiv is
    generic( n : integer );
    port( clk_in  : in  std_logic;
          srst_in : in  std_logic;
          enb_out : out std_logic_vector(n downto 1) );   --< enb_out(n) <= clk_in % (2^n)
  end component;

  component sigsync is
    port( clk_in    : in  std_logic;
          srst_in   : in  std_logic;
          async_in  : in  std_logic;
          sync_out  : out std_logic );
  end component;

  component debounce is
    generic( n : integer );             --< number of samples
    port( clk_in  : in  std_logic;
          srst_in : in  std_logic;
          enb_in  : in  std_logic;      --< 'sample clk'
          d_in    : in  std_logic;
          q_out   : out std_logic );    --< q <= d upon (2^n) samples
  end component;

  component incenc is
    generic( n : positive );          --< counter width
    port( clk_in  : in  std_logic;
          srst_in : in  std_logic;
          a_in    : in  std_logic;
          b_in    : in  std_logic;
          cnt_out : out unsigned(n-1 downto 0) );
  end component;

  component sseg is
    port( value_in     : in  unsigned(15 downto 0);
          clk_in       : in  std_logic;
          srst_in      : in  std_logic;
          blank_in     : in  std_logic;
          step_in      : in  std_logic;     --< step to cycle through digits
          anodedrv_out : out std_logic_vector(3 downto 0);
          segments_out : out std_logic_vector(6 downto 0) );
  end component;

  constant enb_n : integer := 16;
  signal enb : std_logic_vector(enb_n downto 1);

  constant cnt_n : integer := 16;
  signal cnt : unsigned(cnt_n-1 downto 0);

  signal a, b, sw : std_logic;
  signal ss_a, ss_b, ss_sw : std_logic;

  signal srst : std_logic;

begin
  srst <= '0';

  enbdiv0 : enbdiv
    generic map( n => enb_n )
    port map( clk_in  => clk50M,
              srst_in => srst,
              enb_out => enb );

  -------------------------------------

  ss0 : sigsync
    port map ( clk_in   => clk50M,
               srst_in  => srst,
               async_in => enc_a,
               sync_out => ss_a );

  db0 : debounce
    generic map( n => 8 )
    port map( clk_in  => clk50M,
              srst_in => srst,
              enb_in  => enb(12),
              d_in    => ss_a,
              q_out   => a );

  -------------------------------------

  ss1 : sigsync
    port map ( clk_in   => clk50M,
               srst_in  => srst,
               async_in => enc_b,
               sync_out => ss_b );

  db1 : debounce
    generic map( n => 8 )
    port map( clk_in  => clk50M,
              srst_in => srst,
              enb_in  => enb(12),
              d_in    => ss_b,
              q_out   => b );

  -------------------------------------

  ss2 : sigsync
    port map ( clk_in   => clk50M,
               srst_in  => srst,
               async_in => not(enc_sw),
               sync_out => ss_sw );

  db2 : debounce
    generic map( n => 8 )
    port map( clk_in  => clk50M,
              srst_in => srst,
              enb_in  => enb(12),
              d_in    => ss_sw,
              q_out   => sw );

  -------------------------------------

  incenc0 : incenc
    generic map ( n => cnt_n)
    port map ( clk_in  => clk50M,
               srst_in => sw,
               a_in    => a,
               b_in    => b,
               cnt_out => cnt );

  sseg0 : sseg
    port map( clk_in   => clk50M,
              srst_in  => srst,
              value_in => cnt,
              blank_in => '0',
              step_in  => enb(16),
              anodedrv_out    => sseg_an,
              segments_out(0) => sseg_a,
              segments_out(1) => sseg_b,
              segments_out(2) => sseg_c,
              segments_out(3) => sseg_d,
              segments_out(4) => sseg_e,
              segments_out(5) => sseg_f,
              segments_out(6) => sseg_g );

end architecture;