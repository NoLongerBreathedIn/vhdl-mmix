entity fadd is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fadd is
  signal ye0, ze0, ze0b, d, d0, ye1, yf1, dosub, xelg : bit_vector (0 to 15);
  signal yf0, yf1, zf0, zf1, xf0, xfs, xfa, xflg, xfsm : bit_vector (0 to 63);
  signal ysl, yse, ysm, zfl, zfh, ys0, zs0, xfl2, zu, s0 : bit;
  signal xesm, xe : bit_vector (0 to 15);
  signal h0, h1, h2, h3, h4, xssm : bit;
  signal xfs1, xf, xa, xsp, i_bit, xsa, yz : bit_vector (0 to 63);
  signal pxns, prxns, st : bit_vector (0 to 7);
  signal xesa : bit_vector (0 to 5);
begin
  yzc : comparator generic map (64) port map ('0'&y(1 to 63),
                                              '0'&z(1 to 63),
                                              yse, ysl);
  yzs : mux2 generic map (162) port map (ysm, ys&ye&yf&zs&ze&zf,
                                         zs&ze&zf&ys&ye&yf,
                                         ys0&ye0&yf0&zs0&ze0&zf0);
  ze0n : not_gate generic map (16) port map (ze0, ze0b);
  dclc : adder_1 generic map (16) port map (ye0, ze0b, d, open);
  yf1c : mux2 generic map (64) port map (dosub(0), yf0, yf0(1 to 63)&'0', yf1);
  d0c : adder generic map (16) port map (dosub, d, d0, open);
  ye1c : adder generic map (16) port map (dosub, ye0, ye1, open);
  zsh : rsh port map (zf0, d0, zf1(0 to 62)&zfh, zfl);
  ad : adder generic map (64) port map (yf1, zf1, xfa, open);
  sb : subber generic map (64) port map (yf1, zf1, xfs, open);
  fmx : mux2 generic map (64) port map (dosub(0), xfa, xfs, xf0);
  xea : adder generic map (16) port map (15b"0"&xf0(8), ye1, xelg);
  xfl : mux2 generic map (64) port map (xf0(8), xf0, '0'&xf0(0 to 61)&xfl2,
                                        xflg);
  lshr : rrsh port map (xf0(10 to 63)&10b"0", xfs1, xesa);
  lsha : adder generic map (16) port map (10sb"1"&xesa, ye1, xesm);
  xsz : mux2 generic map (80) port map (xssm, xflg&xelg, xfsm&xesm, xf&xe);
  pk : fpack port map (xf, xe, ys, r, xa, pxns);
  xsac : mux2 generic map (72) port map (zt(1), o"0"&i_bit&h"0"&xsp, pxns&xa,
                                         prxns&xsa);
  yzc : mux2 generic map (64) port map (zu, y, z, yz);
  xc : mux2 generic map (64) port map (st(0), xsa, yz, x);
  exc : and_gate generic map (8) port map (st, prxns, exns);
  ysm <= ysl and not yse;
  dosub <= (others => ys xor zs);
  zf1(63) <= zfh or zfl;
  xfl2 <= xf0(63) or xf0(62);
  xssm <= xf0(8) or xf0(9);
  xfsm <= o"000"&xfs1(0 to 56);
  zu <= (zt(0) or zt(1)) and not yt(0);
  st <= (others => (zt(0) xor yt(0)) nor (zt(1) xor yt(1)));
  s0 <= r(0) and r(1) when dosub(0) else ys;
  i_bit <= zt(0) and dosub(0);
  xsp <= (0 => zs when zt(0) else s0,
          1 to 12 => zt(0),
          13 => zt(0) and i_bit,
          others => '0');
end;

component fadd
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity fecmp is
  port (y, yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        e : in bit_vector (0 to 63);
        s : in bit;
        res : out bit_vector (0 to 1));
end;

architecture a1 of fecmp is
  signal ef, yf1, zf1, yf2, zf2, zf3, zf4, os, oa, o : bit_vector (0 to 63);
  signal efl, efr, efs : bit_vector (0 to 63);
  signal eeb, ee, eet, ee1, ye1, ze1, ye2, ze2, ze3, d : bit_vector (0 to 15);
  signal es, elg, ens, ece, ecl, eehb, dty, sfr, sr, cr, einf : bit;
  signal pdr, dr, ysn, zsn, ss, yltz, yehb, zehb, eslg, esm : bit;
  signal de, dl, trn, ptr, ee53, el53, inczf, ee1hb, ee51, el51 : bit;
  signal shefl, ol, oe : bit;
  signal slamt, sramt : bit_vector (0 to 15);
  signal et : bit_vector (0 to 1);
begin
  upk : funpack port map (e, ef, eeb, es, et);
  ecm : comparator generic map (16) port map (eehb&ee(1 to 15), h"83FE",
                                              ece, ecl);
  dsny : mux2 generic map (80) port map (ysn, yf&ye, y(2 to 63)&18b"0",
                                         yf1&ye1);
  dsnz : mux2 generic map (80) port map (zsn, zf&ze, z(2 to 63)&18b"0",
                                         zf1&ze1);
  cyz : comparator generic map (80) port map (yehb&ye1(1 to 15)&yf1,
                                              zehb&ze1(1 to 15)&zf1,
                                              open, yltz);
  yzms : mux2 generic map (160) port map (yltz,
                                          ye1&yf1&ze1&zf1,
                                          ze1&zf1&ye1&yf1,
                                          ye2&yf2&ze2&zf2);
  zemx : mux2 generic map (16) port map (ze2(0), ze2, ye2, ze3);
  dc : subber generic map (16) port map (ye2, ze3, d, open);
  eds : subber generic map (16) port map (ee, d, eet, open);
  ee1m : mux2 generic map (16) port map (s, eet, ee, ee1);
  ec51 : comparator generic map (16) port map (eehb&ee1(1 to 15), h"83FF",
                                               ee51, el51);
  dcmp : comparator generic map (16) port map (d, h"0036", de, dl);
  szr : rsh port map (zf2, 48b"0"&d, '0', zf3, ptr);
  piz : adder generic map (64) port map (zf3, 63b"0"&inczf, zf4, open);
  ec53 : comparator generic map (16) port map (ee1hb&ee1(1 to 15), h"83FC",
                                               ee53, el53);
  oac : adder generic map (64) port map (yf2, zf4, oa, open);
  osc : subber generic map (64) port map (yf2, zf4, os, open);
  omx : mux2 generic map (64) port map (ss, oa, os, o);
  csl : adder generic map (16) port map (ee1, h"FC03", slamt, open);
  csr : subber generic map (16) port map (h"03FD", ee1, sramt, open);
  sefl : lsh port map (ef, 48b"0"&slamt, efl, open);
  sefr : rsh port map (ef, 48b"0"&sramt, '0', efr, open);
  efmx : mux2 generic map (64) port map (shefl, efr, efl, efs);
  oec : comparator generic map (64) port map (o, efs, ol, oe);
  c <= ((ol or oe) and not esm) or eslg;
  eslg <= ee51 or not el51;
  shefl <= ee53 nor el53;
  esm <= el53 and not ee53 and trn;
  inczf <= trn and ss;
  trn <= ptr and not (de or dl);
  yehb <= not ye1(0);
  zehb <= not ze1(0);
  ysn <= yt(0) and ye(0);
  zsn <= zt(0) and ze(0);
  ee <= h"4000" when et(0) else eeb;
  eehb <= not ee(0);
  ee1hb <= not ee1(0);
  elg <= ece nor ecl;
  ens <= ece or not ecl;
  dty <= (yt(0) xor zt(0)) or (yt(1) xor zt(1));
  sfr <= cr or not yt(1);
  ss <= ys xnor zs;
  sr <= elg or ss when yt(0) else sfr;
  einf <= yt(0) or zt(0);
  pdr <= ens when einf else cr;
  dr <= pdr and s;
  res(0) <= (yt(0) and yt(1)) or (zt(0) and zt(1)) or (et(0) and et(1)) or es;
  res(1) <= dr when dty else sr;
end;
  
component fecmp
  port (y, yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        e : in bit_vector (0 to 63);
        s : in bit;
        res : out bit_vector (0 to 1));
end;
