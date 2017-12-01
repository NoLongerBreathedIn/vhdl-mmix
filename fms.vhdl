entity fcmp is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        u, e, l : out bit); 
end;

architecture a1 of fcmp is
  signal pe, pl : bit;
begin
  cmp : comparator generic map (80) port map (ye&yf, ze&zf, pe, pl);
  u <= (yt(0) and yt(1)) or (zt(0) and zt(1));
  e <= not (yt(0) or yt(1) or zt(0) or zt(1)) or (pe and (ys xor zs));
  l <= ((ys xor zs) or pl) xor ys;
end;

component fcmp
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        u, e, l : out bit);
end;

entity fround is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fround is
  signal xf0, xf1, xf2, xfp, xp, xo, xfn, xinf : bit_vector (0 to 63);
  signal yes : bit_vector (0 to 15);
  signal pxns : bit_vector (0 to 7);
  signal yehb, yee0, yel0, ylg, xfl, xfla, adb, yee1, yel1, ysm, kx, lx : bit;
  signal adj : bit_vector (0 to 1);
begin
  comp : comparator generic map (16) port map (yehb&ye(1 to 15), h"8432",
                                               yee0, yel0);
  sye : subber generic map (16) port map (16h"432", ye, yes, open);
  shyf : rsh port map (yf, 48b"0"&yes, '0', xf0(0 to 62)&xfl, xfla);
  incx : adder generic map (64) port map (xf0, 62b"0"&adj, xf1, open);
  shxf : lsh port map (xf1(0 to 61), 48b"0"&yes, xf2, open);
  whxf : mux2 generic map (64) port map (ylg, xf2, yf, xfp);
  pk : fpack port map (xfp, ye, ys, b"01", xp, pxns);
  cmpb : comparator generic map (16) port map (yehb&ye(1 to 15), h"83FE",
                                               yee1, yel1);
  clx : or_comb generic map (32) port map (xf2(32 to 63), lx);
  xoc : mux2 generic map (63) port map (lx, xf2(1 to 63),
                                        o"3"&h"FF"&52b"0", xo);
  fxc : mux2 generic map (64) port map (ysm, xp, ys&xo, xfn);
  fmx : mux2 generic map (64) port map (r(1), xinf, xfn, x);
  yehb <= not ye(0);
  ylg <= yee0 or not yel0;
  xf0(63) <= xfl or xfla;
  adb <= ys xor r(1);
  adj(0) <= adb when r(0) else xf0(61) and not r(1);
  adj(1) <= adb when r(0) else xf0(61) nor r(1);
  ysm <= yel1 and not yee1;
  kx <= zt(1) and not ysm;
  exns <= pxns when kx else h"00";
  xinf <= (0 => ys;
           1 to 11 => yt(0);
           others => '0');
end;

component fround
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity ffix is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of ffix is
  signal w_bit, iszro, yl1, ye1, ysm, ylg, yehb : bit;
  signal olf, org, o, ong, ofn : bit_vector (0 to 63);
  signal slamt, sramt : bit_vector (0 to 15);
begin
  cs : comparator generic map (16) port map (yehb&ye(1 to 15), h"8434",
                                             open, ysm);
  cl : comparator generic map (80) port map (yehb&ye(1 to 15)&yf,
                                             h"843D004"&52b"0", ye1, yl1);
  csr : subber generic map (16) port map (h"0434", ye, sramt, open);
  csl : adder generic map (16) port map (h"FBCC", ye, slamt, open);
  sly : lsh port map (yf, 48b"0"&slamt, olf, open);
  sry : rsh port map (yf, 48b"0"&sramt, '0', org, open);
  omx : mux2 generic map (64) port map (ysm, olf, org, o);
  ngo : subber generic map (64) port map (64b"0", o, ong, open);
  ofc : mux2 generic map (64) port map (ys, o, ong, ofn);
  xc : mux2 generic map (64) port map (r(0), ofn, ys&h"FFE"&51b"0", x);
  yehb <= not ye(0);
  iszro <= yt(0) nor yt(1);
  ylg <= not ys when ye1 else not yl1;
  w_bit <= ylg and not r(0);
  exns <= b"00"&w_bit&r(0)&h"0";
end;

component ffix
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity ffloat is
  port (y : in bit_vector (0 to 63);
        r : in bit_vector (0 to 1);
        u, p : in bit;
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of ffloat is
  signal z0, z1, negz, xf0, xf1, xf, x0 : bit_vector (0 to 63);
  signal xshr : bit_vector (0 to 31);
  signal xe0, xe1, xe : bit_vector (0 to 16);
  signal xs, az, alz : bit;
  signal spxns, msx, pxns, axns : bit_vector (0 to 7);
  signal sbar : bit_vector (0 to 5);
begin
  ngz : subber generic map (64) port map (64b"0", z, negz, open);
  snz : mux2 generic map (64) port map (xs, z, negz, z0);
  ljust : rrsh port map (z0, z1, sbar);
  cxe : adder generic map (16) port map (10sb"1"sbar, h"043E", xe0);
  spk : sfpack port map (xf0, xe0, xs, r, xshr, spxns);
  sup : sfunpack port map (xshr, xf1, xe1, open, open);
  whx : mux2 generic map (88) port map (p, xf0&xe0&8b"0", xf1&xe1&spxns,
                                        xf&xe&msx);
  caz : or_comb generic map (64) port map (z, az);
  clz : or_comb generic map (10) port map (z2(54 to 63), alz);
  fpk : fpack port map (xf, xe, xs, r, x0, pxns);
  oxs : or_gate generic map (8) port map (pxns, msx, axns);
  fmx : mux2 generic map (72) port map (az, 72b"0", axns&x0, exns&x);
  xs <= z(0) and not u;
  xf0 <= 9b"0"&z1(0 to 53)&alz;
end;

component ffloat
  port (y : in bit_vector (0 to 63);
        r : in bit_vector (0 to 1);
        u, p : in bit;
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity rootstep is
  port (ri, zi, xi : in bit_vector (0 to 63);
        ro, zo, xo : out bit_vector (0 to 63));
end;

architecture a1 of rootstep is
  signal r0, r1 : bit_vector (0 to 63);
  signal re, rl, rlg : bit;
begin
  crx : comparator generic map (64) port map (r0, xi(1 to 63)&'0', re, rl);
  srx : subber generic map (64) port map (r0, xi(1 to 63)&'1', r1, open);
  rmx : mux2 generic map (64) port map (rlg, r0, r1, ro);
  r0 <= ri(2 to 63)&zi(0 to 1);
  zo <= zi(2 to 63)&2b"0";
  rlg <= re nor rl;
  xo <= xi(1 to 62)&rlg&'0';
end;

component rootstep
  port (ri, zi, xi : in bit_vector (0 to 63);
        ro, zo, xo : out bit_vector (0 to 63));
end;

entity fsqrt is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fsqrt is
  type intermediate is array (0 to 53) of bit_vector (0 to 63);
  signal zi, ri, xi : intermediate;
  signal zf, xin, xfi : bit_vector (0 to 63);
  signal xe : bit_vector (0 to 14);
  signal pxns : bit_vector (0 to 7);
  signal i_bit, ar : bit;
begin
  sbr : subber generic map (64) port map (54b"0"&zf(0 to 9), 64h"1",
                                          ri(0), open);
  zmx : mux2 generic map (64) port map (ye(15), yf(0 to 63), yf(1 to 63)&'0',
                                        zf);
  rst : for i from 0 to 52 generate
  begin
    rstp : rootstep port map (ri(i), zi(i), xi(i),
                              ri(i + 1), zi(i + 1), xi(i + 1));
  end;
  anyr : or_comb generic map (64) port map (ri(53), ar);
  xec : adder generic map (15) port map (ye(0 to 14), o"00777", xe, open);
  pk : fpack port map (xi(53)(0 to 62)&ar, '0'&xe, '0', r, xfi);
  mx0 : mux2 generic map (72) port map (yt(1), o"0"&i_bit&h"0"&xin, pxns&xfi,
                                        exns&x);
  xin <= (0 => ys,
          1 to 11 => i_bit or yt(0),
          12 => i_bit,
          others => '0');
  zi(0) <= zf(10 to 63)&10b"0";
  xi(0) <= 64h"2";
  i_bit <= ys and (yt(0) or yt(1));
end;

component fsqrt
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity remstep is
  port (yfi, zf : in bit_vector (0 to 63);
        tci, zri, odi : in bit;
        yei, ze : in bit_vector (0 to 15);
        yfo : out bit_vector (0 to 63);
        yeo : out bit_vector (0 to 15);
        tco, zro, odo : out bit);
end;

architecture a1 of remstep is
  signal fe, fl, ee0, el0, ee1, pass, passy, tc, s0 : bit;
  signal ye0, yedc, ye1 : bit_vector (0 to 15);
  signal yf0, yfdc, yf1 : bit_vector (0 to 63);
  signal sbar : bit_vector (0 to 5);
begin
  cmpf : comparator generic map (64) port map (yfi, zf, fe, fl);
  cmp0 : comparator generic map (16) port map (yei, ze, ee0, el0);
  cmp1 : comparator generic map (16) port map (ye0, ze, ee1, open);
  edc : adder generic map (16) port map (yei, h"FFFF", yedc, open);
  dcmx : mux2 generic map (80) port map (s0, yei&yfi, yedc&yfi(1 to 63)&'0',
                                         ye0&yf0);
  rr : subber generic map (64) port map (yf0, zf, yfdc, open);
  lsh : rrsh port map (yfdc(9 to 63)&o"000", yf1, sbar);
  dce : adder_1 generic map (16) port map (ye0, 10sb"1"&sbar, ye1, open);
  ymx : mux2 generic map (80) port map (passy, ye1&9b"0"&yf1(0 to 54),
                                        yei&yfi, yeo&yfo);
  bmx : mux2 generic map (3) port map (pass, tc&fe&od, tci&zri&odi,
                                       tco&zro&odo);
  pass <= (el0 and not ee0) or tci;
  passy <= pass or tc;
  s0 <= fl and not fe and not ee0;
  tc <= ee0 and fl0 and not fe0;
end;

component remstep
  port (yfi, zf : in bit_vector (0 to 63);
        tci, zri, odi : in bit;
        yei, ze : in bit_vector (0 to 15);
        yfo : out bit_vector (0 to 63);
        yeo : out bit_vector (0 to 15);
        tco, zro, odo : out bit);
end;

entity finrem is
  port (yf, zf : in bit_vector (0 to 63);
        ye, ze : in bit_vector (0 to 15);
        tc, od : in bit;
        xf : out bit_vector (0 to 63);
        xe : out bit_vector (0 to 15);
        xss, e : out bit);
end;

architecture a1 of finrem is
  signal zep, xe0 : bit_vector (0 to 15);
  signal yf0, xf0, xf1, xf2 : bit_vector (0 to 63);
  signal ee, el, fe, fl, zehb, yehb, c, cont : bit;
  signal sbar : bit_vector (0 to 5);
begin
  dze : adder generic map (16) port map (ze, h"FFFF", zep, open);
  cex : comparator generic map (16) port map (yehb&ye(1 to 15),
                                              zehb&zep(1 to 15), ee, el);
  msy : mux2 generic map (64) port map (tc, '0'&yf(0 to 62), yf, yf0);
  szy : subber generic map (64) port map (zf, yf0, xf0, open);
  cfr : comparator generic map (64) port map (xf0, yf0, fe, fl);
  wx1 : mux2 generic map (64) port map (c, yf0, xf0, xf1);
  sxl : rrsh port map (xf1(9 to 63)&o"000", xf2, sbar);
  dce : adder_1 generic map (16) port map (ze, sbar, xe0);
  whx : mux2 generic map (80) port map (cont, ye&yf, xe0&o"000"&xf2(0 to 54),
                                        xe&xf);
  c <= fl or (fe and od);
  e <= cont nor el;
  yehb <= not ye(0);
  zehb <= not zep(0);
  cont <= tc or ee;
  xss <= cont and c;
end;

component finrem
  port (yf, zf : in bit_vector (0 to 63);
        ye, ze : in bit_vector (0 to 15);
        tc, od : in bit;
        xf : out bit_vector (0 to 63);
        xe : out bit_vector (0 to 15);
        xss, e : out bit);
end;

entity frem is
  generic (steps : integer);
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7);
        trap : out bit);
end;

architecture a1 of frem is
  type inte is array (0 to steps) of bit_vector (0 to 15);
  type intf is array (0 to steps) of bit_vector (0 to 63);
  signal tcs, zrs, ods : bit_vector (0 to steps);
  signal yes : inte;
  signal yfs : intf;
  signal i_bit, e_bit, keepr, xss, xs : bit;
  signal xfin, xinf, xf0, xf : bit_vector (0 to 63);
  signal xe0, xe : bit_vector (0 to 15);
  signal pxns, mxns : bit_vector (0 to 7);
begin
  stps : for i from 0 to (steps - 1) generate
  begin
    step : remstep port map (yfs(i), zf, tcs(i), zrs(i), ods(i), yes(i), ze,
                             yfs(i + 1), yes(i + 1), tcs(i + 1), zrs(i + 1),
                             ods(i + 1));                             
  end;
  fmux : mux2 generic map (73) port map (keepr, h"0"&i_bit&h"0"&xinf,
                                         e_bit&mxns&xfin,
                                         trap&exns&x);
  xmux : mux2 generic map (8) port map (zt(0), pxns, h"00", mxns);
  wmux : mux2 generic map (81) port map (zt(0), xe0&xf0, ye&yf, xe&xf);
  pk : fpack port map (xf, xe, xs, b"01", xfin, pxns);
  fin : finrem port map (yfs(steps), zf, yes(steps), ze,
                         tcs(steps), ods(steps),
                          xf0, xe0, xss, e_bit);
  xinf <= (0 => ys,
           1 to 12 => i_bit,
           others => '0');
  i_bit <= yt(0) or (zt(0) nor zt(1));
  keepr <= yt(1) and (zt(0) or (zt(1) and not zrs(steps)));
  yes(0) <= ye;
  yfs(0) <= yf;
  tcs(0) <= '0';
  zrs(0) <= '0';
  ods(0) <= '0';
  xs <= (xss and zt(1)) xor ys

end;

component frem
  generic (steps : integer);
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7);
        trap : out bit);
end;
