---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity sseg is
  port( value_in : in  unsigned(15 downto 0);
        enb_in   : in  std_logic;
        clk_in   : in  std_logic;
        an_out   : out std_logic_vector(3 downto 0);
        seg_out  : out std_logic_vector(6 downto 0) );
end entity;

architecture arch of sseg is

  signal an    : std_logic_vector(3 downto 0);
  signal digit : unsigned(3 downto 0);


  type state_t is ( DIG1, DIG2, DIG3, DIG4 );
  signal state : state_t := DIG1;

begin

  -- capture and cycle through digits:
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      case state is
        when DIG1 =>
          digit <= value_in(15 downto 12);
          an    <= (0=>'0', others=>'1');
          state <= DIG2;
        when DIG2 =>
          digit <= value_in(11 downto 8);
          an    <= (1=>'0', others=>'1');
          state <= DIG3;
        when DIG3 =>
          digit <= value_in(7 downto 4);
          an    <= (2=>'0', others=>'1');
          state <= DIG4;
        when DIG4 =>
          digit <= value_in(3 downto 0);
          an    <= (3=>'0', others=>'1');
          state <= DIG1;
        when others =>
          an    <= (others=>'1');
          state <= DIG1;
      end case;
    end if;
  end process;

  -- decode
  with digit select   --< g: msb, a: lsb
    seg_out <= "0001110" when x"f",
               "0000110" when x"e",
               "0100001" when x"d",
               "0100111" when x"c",
               "0000011" when x"b",
               "0001000" when x"a",
               "0011000" when x"9",
               "0000000" when x"8",
               "1111000" when x"7",
               "0000010" when x"6",
               "0010010" when x"5",
               "0011001" when x"4",
               "0110000" when x"3",
               "0100100" when x"2",
               "1111001" when x"1",
               "1000000" when others;

  an_out <= an when enb_in = '1' else (others=>'1');

end architecture;