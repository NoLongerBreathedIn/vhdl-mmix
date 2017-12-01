entity rrsh is
  port (i : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63);
        sbar : out bit_vector (0 to 5));
end;

architecture a1 of rrsh is
  signal s : bit_vector (0 to 5);
  signal x5, x4, x3, x2, x1 : bit_vector (0 to 63);
begin
  o5 : or_comb generic map (32) port map (i(0 to 31), s(0));
  m5 : mux2 generic map (64) port map (s(0), i, i(32 to 63)&32b"0", x5);
  o4 : or_comb generic map (16) port map (x5(0 to 15), s(1));
  m4 : mux2 generic map (64) port map (s(1), x5, x5(16 to 63)&16b"0", x4);
  o3 : or_comb generic map (8) port map (x4(0 to 7), s(2));
  m3 : mux2 generic map (64) port map (s(2), x4, x4(8 to 63)&8b"0", x3);
  o2 : or_comb generic map (4) port map (x3(0 to 3), s(3));
  m2 : mux2 generic map (64) port map (s(3), x3, x3(4 to 63)&h"0", x2);
  o1 : or_comb generic map (2) port map (x2(0 to 1), s(4));
  m1 : mux2 generic map (64) port map (s(4), x2, x2(2 to 63)&2b"0", x1);
  nr : not_gate generic map (6) port map (s, sbar);
  m0 : mux2 generic map (64) port map (s(5), x1, x1(1 to 63)&'0', o);
  s(5) <= x1(0);
end;

component rrsh
  port (i : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63);
        sbar : out bit_vector (0 to 5));
end;

entity funpack is
  port (x : in bit_vector (0 to 63);
        f : out bit_vector (0 to 63);
        e : out bit_vector (0 to 15);
        s : out bit;
        ty : out bit_vector (0 to 1));
end;

architecture a1 of funpack is
  signal f0, fzs : bit_vector (0 to 51);
  signal e0, e2, last_e, ezs : bit_vector (0 to 15);
  signal f1 : bit_vector (0 to 63);
  signal e1 : bit_vector (0 to 5);
  signal any_e0, any_f0, all_e0, ninf : bit;
begin
  oc0 : or_comb generic map (11) port map (x(1 to 11), any_e0);
  oc1 : or_comb generic map (52) port map (x(12 to 63), any_f0);
  ac0 : and_comb generic map (11) port map (x(1 to 11), all_e0);
  finish_e : adder generic map (16) port map (h"FFFF", last_e, e, open);
  final_mux : mux2 generic map (71) port map (any_e0,
                                              '0'&any_f0&ezs&fzs&'0',
                                              all_e0&ninf&e0&'1'&f0,
                                              ty&last_e&f(9 to 61));
  lshr : rrsh port map (f0&h"000", f1, e1);
  lsha : adder_1 generic map (16) port map (16b"0", 10sb"1"&e1, e2);
  s <= x(0);
  f0 <= x(12 to 63);
  e0 <= 5b"0"&x(1 to 11);
  fzs <= f1(0 to 51);
  ezs <= e2 when any_f0 else h"F001";
  ninf <= any_f0 or not all_e0;
  f(0 to 8) <= 9b"0";
  f(62 to 63) <= 2b"0";
end;

component funpack
  port (x : in bit_vector (0 to 63);
        f : out bit_vector (0 to 63);
        e : out bit_vector (0 to 15);
        s : out bit;
        ty : out bit_vector (0 to 1));
end;

entity sfunpack is
  port (x : in bit_vector (0 to 31);
        f : out bit_vector (0 to 63);
        e : out bit_vector (0 to 15);
        s : out bit;
        ty : out bit_vector (0 to 1));
end;

architecture a1 of sfunpack is
  signal f0, fzs : bit_vector (0 to 22);
  signal e0, e2, last_e, ezs : bit_vector (0 to 15);
  signal e1 : bit_vector (0 to 5);
  signal f1 : bit_vector (0 to 63);
  signal any_e0, any_f0, all_e0, ninf : bit;
begin
  oc0 : or_comb generic map (8) port map (x(1 to 8), any_e0);
  oc1 : or_comb generic map (23) port map (x(9 to 31), any_f0);
  ac0 : and_comb generic map (8) port map (x(1 to 8), all_e0);
  finish_e : adder generic map (16) port map (h"037F", last_e, e, open);
  final_mux : mux2 generic map (42) port map (any_e0,
                                              '0'&any_f0&ezs&fzs&'0',
                                              all_e0&ninf&e0&'1'&f0,
                                              ty&last_e&f(9 to 32));
  lshr : rrsh port map (f0&41b"0", f1, e1);
  lsha : adder_1 generic map (16) port map (16b"0", 10sb"1"&e1, e2);
  s <= x(0);
  f0 <= x(9 to 31);
  fzs <= f1(0 to 22);
  e0 <= h"00"&x(1 to 8);
  ezs <= e2 when any_f0 else h"EC81";
  ninf <= any_f0 or not all_e0;
  f(0 to 8) <= 9b"0";
  f(33 to 63) <= 31b"0";
end;

component sfunpack
  port (x : in bit_vector (0 to 31);
        f : out bit_vector (0 to 63);
        e : out bit_vector (0 to 15);
        s : out bit;
        ty : out bit_vector (0 to 1));
end;

entity fpack is
  port (f : in bit_vector (0 to 63);
        e : in bit_vector (0 to 15);
        s : in bit;
        r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fpack is
  signal ebar, nege, e0, e1 : bit_vector (0 to 15);
  signal f0, f1, o0 : bit_vector (0 to 63);
  signal o1 : bit_vector (0 to 64);
  signal enlg, ee, el, lof, sf0, obit, xbit, ubar, hrb, lrb, rb : bit;
  signal c0, ubit : bit;
begin
  eislg : comparator generic map (16) port map (ebar(0)&e(1 to 15),
                                                h"87FD",
                                                ee, el);
  nege0 : not_gate generic map (16) port map (e, ebar);
  nege1 : adder_1 generic map (16) port map (16b"0", ebar, nege, open);
  srf : rsh port map (f, 48b"0"&nege, '0', f0, lof);
  snmx : mux2 generic map (80) port map (e(0), e&f, 16b"0"&f0(0 to 62)&sf0,
                                         e0&f1);
  lmx : mux2 generic map (80) port map (enlg, 80h"07FF", f1&e0, o0&e1);
  add0 : adder generic map (64) port map (o0, e1(6 to 15)&52b"0"&hrb&lrb,
                                          o1(1 to 64), c0);
  oflow : and_comb generic map (11) port map (o1(0 to 10), obit);
  uflow : or_comb generic map (11) port map (o1(0 to 10), ubar);
  enlg <= ee or el;
  sf0 <= f0(63) or lof;
  rb <= r(0) and (s xnor r(1));
  hrb <= rb or (not r(0) and not r(1) and o0(61));
  lrb <= rb or not (r(0) or r(1) or o0(61));
  o1(0) <= c0 xor e1(5);
  xbit <= o0(62) or o0(63) or obit;
  x <= s&o1(0 to 62);
  ubit <= not ubar;
  exns <= b"0000"&obit&ubit&'0'&xbit;
end;

component fpack
  port (f : in bit_vector (0 to 63);
        e : in bit_vector (0 to 15);
        s : in bit;
        r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity sfpack is
  port (f : in bit_vector (0 to 63);
        e : in bit_vector (0 to 15);
        s : in bit;
        r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 31);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of sfpack is
  signal ebar, nege, ea, e0, e1 : bit_vector (0 to 15);
  signal f0, f1, o0 : bit_vector (0 to 63);
  signal o1 : bit_vector (0 to 32);
  signal enlg, ee, el, lof0, lof1, sf0, sf1, obit, xbit, ubar, ubit : bit;
  signal rb, hrb, lrb, c0 : bit;
begin
  debias_e : adder generic map (16) port map (e, h"FC80", ea, open);
  eislg : comparator generic map (16) port map (ebar(0)&ea(1 to 15),
                                                h"80FD",
                                                ee, el);
  nege0 : not_gate generic map (16) port map (ea, ebar);
  nege1 : adder_1 generic map (16) port map (16b"0", ebar, nege, open);
  clf0 : or_comb generic map (29) port map (f(35 to 63), lof0);
  srf : rsh port map (29b"0"&f(0 to 34), 48b"0"&nege, '0', f0, lof1);
  snmx : mux2 generic map (80) port map (ea(0), ea&29b"0"&f(0 to 33)&sf0,
                                         16b"0"&f0(0 to 62)&sf1,
                                         e0&f1);
  lmx : mux2 generic map (80) port map (enlg, 80h"047F", f1&e0, o0&e1);
  oa : adder generic map (32) port map (o0(32 to 63),
                                        e1(9 to 15)&23b"0"&hrb&lrb,
                                        o1(1 to 32), open);
  oflow : and_comb generic map (8) port map (o1(0 to 7), obit);
  uflow : or_comb generic map (8) port map (o1(0 to 7), ubar);
  enlg <= ee or el;
  sf0 <= lof0 or f(34);
  sf1 <= lof0 or lof1 or f0(63);
  rb <= r(0) and (s xnor r(1));
  hrb <= rb or (not r(0) and not r(1) and o0(61));
  lrb <= rb or not (r(0) or r(1) or o0(61));
  o1(0) <= c0 xor e1(8);
  xbit <= o0(62) or o0(63) or obit;
  ubit <= not ubar;
  exns <= b"0000"&obit&ubit&'0'&xbit;
  x <= s&o1(0 to 30);
end;

component sfpack
  port (f : in bit_vector (0 to 63);
        e : in bit_vector (0 to 15);
        s : in bit;
        r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 31);
        exns : out bit_vector (0 to 7));
end;

entity ftod is
  port (z : in bit_vector (0 to 31);
        x : out bit_vector (0 to 63));
end;

architecture a1 of ftod is
  signal f, x0 : bit_vector (0 to 63);
  signal t : bit_vector (0 to 1);
  signal s : bit;
  signal e : bit_vector (0 to 16);
begin
  upk : sfunpack port map (z, f, e, s, t);
  pk : fpack port map (f, e, s, b"01", x0, open);
  mx : mux2 generic map (64) port map (t(0), x0, s&11sb"1"&f(10 to 61), x);
end;

component ftod
  port (z : in bit_vector (0 to 31);
        x : out bit_vector (0 to 63));
end;

entity dtof is
  port (x : in bit_vector (0 to 63);
        r : out bit_vector (0 to 1);
        z : out bit_vector (0 to 31);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of dtof is
  signal f : bit_vector (0 to 63);
  signal t : bit_vector (0 to 1);
  signal s, nan, ibit : bit;
  signal pxn : bit_vector (0 to 7);
  signal e : bit_vector (0 to 16);
  signal z0 : bit_vector (0 to 31);
begin
  upk : funpack port map (x, f, e, s, t);
  pk : sfpack port map (f, e, s, r, z0, pxn);
  mx : mux2 generic map (16) port map (t(0), z0, s&h"FF"&nan&f(11 to 32), z);
  nan <= t(0) and t(1);
  ibit <= nan and not f(10);
  exns <= pxn(0 to 2)&ibit&pxn(4 to 7);
end;

component dtof
  port (x : in bit_vector (0 to 63);
        r : out bit_vector (0 to 1);
        z : out bit_vector (0 to 31);
        exns : out bit_vector (0 to 7));
end;
