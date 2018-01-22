type arrarr is array (range <>) of bit_vector (range <>);

entity muxn is
  generic (len, lcnt : integer);
  port (i : in arrarr (0 to 2**lcnt-1) (0 to len-1);
        sel : in bit_vector (0 to lcnt-1);
        o : out bit_vector (0 to len-1));
end;

component muxn
  generic (len, lcnt : integer);
  port (i : in arrarr (0 to 2**lcnt-1) (0 to len-1);
        sel : in bit_vector (0 to lcnt-1);
        o : out bit_vector (0 to len-1));
end;

architecture a1 of muxn is
begin
  base: if lcnt = 1 generate
  begin
    rmx : mux2 generic map (len) port map (sel(0), i(0), i(1), o);
  end;
  rec: if lcnt > 1 generate
    signal rl, rh : bit_vector (0 to len-1);
  begin
    lmx : muxn generic map (len, lcnt-1) port map (i(0 to 2**(lcnt-1)-1),
                                                   sel(1 to lcnt-1), rl);
    hmx : muxn generic map (len, lcnt-1) port map (i(2**(lcnt-1) to 2**lcnt-1),
                                                   sel(1 to lcnt-1), rh);
    fmx : mux2 generic map (len) port map (sel(0), rl, rh, o);
  end;
end;

entity mux1 is
  generic (lcnt : integer);
  port (i : in bit_vector (0 to 2**lcnt-1);
        sel : in bit_vector (0 to lcnt-1);
        o : out bit);
end;

component mux1
  generic (lcnt : integer);
  port (i : in bit_vector (0 to 2**lcnt-1);
        sel : in bit_vector (0 to lcnt-1);
        o : out bit);
end;

architecture a1 of mux1 is
begin
  base: if lcnt = 1 generate
  begin
    rmx : mux2 generic map (1) port map (sel(0), i(0), i(1), o);
  end;
  rec: if lcnt > 1 generate
    signal rl, rh : bit;
  begin
    lmx : mux1 generic map (lcnt-1) port map (i(0 to 2**(lcnt-1)-1),
                                                   sel(1 to lcnt-1), rl);
    hmx : mux1 generic map (lcnt-1) port map (i(2**(lcnt-1) to 2**lcnt-1),
                                                   sel(1 to lcnt-1), rh);
    fmx : mux2 generic map (1) port map (sel(0), rl, rh, o);
  end;
end;


entity dmxn is
  generic (lob, lcnt : integer);
  port (s : in bit_vector (0 to lcnt-1);
        i : in bit;
        o : out bit_vector (0 to 2**(lcnt+lob)-1));
end;

component dmxn
  generic (lob, lcnt : integer);
  port (s : in bit_vector (0 to lcnt-1);
        i : in bit;
        o : out bit_vector (0 to 2**(lcnt+lob)-1));
end;

architecture a1 of dmxn is
begin
  base: if lcnt = 0 generate
  begin
    o <= (others => i);
  end;
  rec: if lcnt > 0 generate
    signal l, h : bit;
  begin
    ldm : dmxn generic map (lob, lcnt-1) port map (s(1 to lcnt-1), l,
                                                   o(0 to 2**(lcnt+lob-1)-1));
    hdm : dmxn generic map (lob, lcnt-1)
      port map (s(1 to lcnt-1), h, o(2**(lcnt+lob-1) to 2**(lcnt+lob)-1));
    l <= i and not s(0);
    h <= i and s(0);
  end;
end;

entity aao_reg is
  generic (lws, lbs : integer);
  port (a : in bit_vector (0 to 2**lws-1);
        aao, c : in bit;
        aaod, d : in bit_vector (0 to 2**lbs-1);
        o : out bit_vector (0 to 2**lbs-1));
end;

architecture a1 of aao_reg is
  signal laao, set : bit_vector (0 to 2**lws-1);
  signal rdt : bit_vector (0 to 2**lbs-1);
begin
  wst : and_gate generic map (2**lws) port map (a, laao, set);
  wdt : mux2 generic map (2**lbs) port map (aao, d, aaod, rdt);
  rrg : da_reg generic map (lws, lbs) port map (set, c, rdt, o);
  laao <= (others => aao);
end;

component aao_reg
  generic (lws, lbs : integer);
  port (a : in bit_vector (0 to 2**lws-1);
        aao, c : in bit;
        aaod, d : in bit_vector (0 to 2**lbs-1);
        o : out bit_vector (0 to 2**lbs-1));
end;

entity fonreg8 is
  port (a : in bit_vector (0 to 7);
        c : in bit;
        f, d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

architecture a1 of fonreg8 is
  signal as, bs, ds : bit_vector (0 to 63);
begin
  sta : mor_expand_z port map (a, as);
  whb : or_gate generic map (128) port map (f&f, as&d, bs&ds);
  rrg : da_reg generic map (6, 6) port map (bs, c, ds, o);
end;

component fonreg8
  port (a : in bit_vector (0 to 7);
        c : in bit;
        f, d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

entity ad_reg is
  port (a : in bit_vector (0 to 7);
        c : in bit;
        d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

architecture a1 of ad_reg is
  signal any_a, wds, nnz : bit;
  signal repl : bit_vector (0 to 7);
  signal wrt, io, do : bit_vector (0 to 63);
begin
  caa : or_comb generic map (8) port map (a, any_a);
  cnz : or_comb generic map (64) port map (io, nnz);
  whc : mux2 generic map (72) port map (wds, h"FF"&do, a&d, repl&wrt);
  sb1 : adder generic map (64) port map (64sb"1", io, do, open);
  rrg : da_reg generic map (3, 6) port map (repl, c, wrt, io);
  wds <= any_a or not nnz;
end;

component ad_reg
  port (a : in bit_vector (0 to 7);
        c : in bit;
        d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

-- ro: rV 8 rG 1 rE 8 rI 8 rM 8 rD 8 v2(rQ&rK) 1
-- rw: rL 1 rO 8 rS 8 rU 8 (all bytewise) rA 4 (tetwise)
-- wo: rQ 8 (bitwise, only on) rR 8 (octwise) rH 8 (octwise) rF 8 (octwise) 
-- other outputs: rK progbits, any(rQ&rK)
-- register order: B D E H J M R BB C N O S I T TT K
-- Q U V G L A F P W X Y Z WW XX YY ZZ

entity sregs is
  port (sdri, rfi, rhi, rqi, rri : in bit_vector (0 to 63);
        rai : in bit_vector (0 to 31);
        srs, sdrw, row, rsw, ruw : in bit_vector (0 to 7);
        raw, rfw, rgw, rhw, rlw, rrw, clock : in bit;
        sdro, rdo, reo, rio, rmo : out bit_vector (0 to 63);
        roo, rso, ruo, rvo : out bit_vector (0 to 63);
        rao : out bit_vector (0 to 31);
        rgo, rlo, kpb : out bit_vector (0 to 7);
        qka : out bit);
end;

architecture a1 of sregs is
  type regs is array (0 to 31) of bit_vector (0 to 63);
  signal post : regs;
  signal activate, wbytes, wregs : bit_vector (0 to 255);
  signal uosw : bit_vector (8 to 31);
  signal glw : bit_vector (0 to 1);
  signal qak : bit_vector (0 to 63);
begin
  suios : for i in 0 to 3 generate
  begin
    aon : or_comb generic map (8) port map (iuosw(i*8 to i*8+7), aiuos(i));
  end;
  rregs: for i in 0 to 31 generate
  begin
    reg: if i /= 3 and i /= 6 and i /= 9 and i /= 12
           and i /= 15 and i /= 16 and (i < 19 or i > 22) generate
      signal act : bit_vector (0 to 7);
    begin
      uos: if i = 10 or i = 11 or i = 17 generate
        signal any : bit;
      begin
        sps : or_comb generic map (8)
          port map (uosw((i mod 4)*8 to (i mod 4)*8+7), any);
        wact : mux2 generic map (8)
          port map (any, activate(i*8 to i*8+7),
                    uosw((i mod 4)*8 to (i mod 4)*8+7), act);
      end;
      vreg: if i /= 10 and i /= 11 and i /= 17 generate
      begin
        act <= activate(i*8 to i*8+7);
      end;
      arg : da_reg generic map (3, 6) port map (act, clock, sdri, post(i));
    end;
    gl: if i = 19 or i = 20 generate
      signal tow : bit_vector (0 to 7);
      signal dow : bit;
    begin
      wbyte : mux2 generic map (8)
        port map (glw(i mod 2),
                  sdri(56 to 63),
                  sdri((i mod 2)*8+16 to (i mod 2)*8+23),
                  tow);
      arg : da_reg generic map (0, 3)
        port map (dow, clock, tow, post(i)(56 to 63));
      dow <= activate(8*i+7) or glw(i mod 2);
      post(i)(0 to 55) <= (others => '0');
    end;
  end;
  ra : aao_reg generic map (2, 5) port map (activate(172 to 175), raw, clock,
                                            rai, sdri(32 to 63),
                                            post(21)(32 to 63));
  rf : aao_reg generic map (3, 6) port map (activate(176 to 183), rfw, clock,
                                            rfi, sdri, post(22));
  rh : aao_reg generic map (3, 6) port map (activate(24 to 31), rhw, clock,
                                            rhi, sdri, post(3));
  ri : ad_reg port map (activate(96 to 103), clock, sdri, post(12));,
  rk : fonreg8 port map (activate(120 to 127), clock, 30b"0"&rqi(31)&33b"0",
                         sdri, post(15));
  rq : fonreg8 port map (activate(128 to 135), clock, rqi, sdri, post(16));
  rr : aao_reg generic map (3, 6) port map (activate(48 to 55), rrw, clock,
                                            rri, sdri, post(6));
  cwrg : dmxn generic map (3, 5) port map (srs(3 to 7), '1', wregs);
  byreg : and_gate generic map (256) port map (wbytes, wregs, activate);
  whsr : muxn generic map (64, 5) port map (post, srso(3 to 7), sdro);
  nqk : and_gate generic map (64) port map (post(15), post(16), qak);
  neqk : or_comb generic map (64) port map (qak, qka);
  nehi : or_comb generic map (61) port map
  post(21)(0 to 31) <= (others => '0'); -- rA
  post(9) <= h"010100005A1EEBF7"; -- rN
  wbytes <= sdrw&sdrw&sdrw&sdrw&sdrw&sdrw&sdrw&sdrw&
            sdrw&sdrw&sdrw&sdrw&sdrw&sdrw&sdrw&sdrw;
  uosw <= ruw&row&rsw;
  glw <= rgw&rlw;
  kpb <= post(15)(24 to 31);
  rao <= post(21)(32 to 63);
  rdo <= post(1);
  reo <= post(2);
  rgo <= post(19)(56 to 63);
  rio <= post(12);
  rlo <= post(20)(56 to 63);
  rmo <= post(5);
  roo <= post(10);
  rso <= post(11);
  ruo <= post(17);
  rvo <= post(18);
end;

component sregs
  port (sdri, rfi, rhi, rqi, rri : in bit_vector (0 to 63);
        rai : in bit_vector (0 to 31);
        srs, sdrw, row, rsw, ruw : in bit_vector (0 to 7);
        raw, rfw, rgw, rhw, rlw, rrw, clock : in bit;
        sdro, rdo, reo, rio, rmo : out bit_vector (0 to 63);
        roo, rso, ruo, rvo : out bit_vector (0 to 63);
        rao : out bit_vector (0 to 31);
        rgo, rlo, kpb : out bit_vector (0 to 7);
        qka : out bit);
end;

entity mcstack is
  generic (maxlen : integer);
  port (topi : in bit_vector (0 to 15);
        push, pop, clock : in bit;
        topo, seco : out bit_vector (0 to 15));
end;

architecture a1 of mcstack is
  type sarr is array (0 to maxlen) of bit_vector (0 to 15);
  signal post : sarr;
  signal porp : bit;
begin
  regs : for i in 1 to maxlen-1 generate
    signal data : bit_vector (0 to 15);
  begin
    mx : mux2 generic map (16) port map (pop, post(i-1), post(i+1), data);
    reg : da_reg generic map (0, 4) port map (porp, clock, data, post(i));
  end;
  tstk : da_reg generic map (0, 4) port map ('1', clock, topi, post(0));
  topo <= post(0);
  seco <= post(1);
  post(maxlen) <= 16b"0";
  porp <= push or pop;
end;

component mcstack
  generic (maxlen : integer);
  port (topi : in bit_vector (0 to 15);
        push, pop, clock : in bit;
        topo, seco : out bit_vector (0 to 15));
end;

entity gregs is
  generic (llocs : integer);
  port (s, o, gdri : in bit_vector (0 to 63);
        g, l, grs, gdrw, lgammaw : in bit_vector (0 to 7);
        clock : in bit;
        gdro, lgammao : out bit_vector (0 to 63));
end;

architecture a1 of gregs is
  type lring is array (0 to 2**llocs-1) of bit_vector (0 to 63);
  type gstuf is array (0 to 255) of bit_vector (0 to 63);
  signal postl : lring;
  signal postg : gstuf;
  signal lw : bit_vector (0 to 2**llocs-1);
  signal alphapx, lwp, lrd, grd, mlrd : bit_vector (0 to 63);
  signal gw : bit_vector (0 to 255);
  signal ws : bit_vector (0 to 7);
  signal algw, arw, wl, wg, xl0, xe0, xl1, xe1, xsm, xlg : bit;
begin
  grgs : for i in 0 to 255 generate
    signal wrt : bit_vector (0 to 7);
  begin
    rreg : da_reg generic map (3, 6) port map (wrt, clock, gdri, postg(i));
    wrt <= gdrw when gw(i) else h"00";
  end;
  lrgs : for i in 0 to 2**llocs-1 generate
    signal wrt : bit_vector (0 to 7);
  begin
    rreg : da_reg generic map (3, 6) port map (wrt, clock, gdri, postl(i));
    wrt <= ws when lw(i) else h"00";
  end;
  lgw : or_comb generic map (8) port map (lgammaw, algw);
  wsr : or_gate generic map (8) port map (gdrw, lgammaw, ws);
  lwrc : dmxn generic map (0, llocs) port map (lwp(61-llocs to 60),
                                               wl, lwr);
  adax : adder generic map (64) port map (o, 53b"0"&grs&o"0", alphapx, open);
  wlw : mux2 generic map (64) port map (algw, alphapx, s, lwp);
  gwc : dmxn generic map (0, 8) port map (gdri, wg, gw);
  rwc : or_comb generic map (8) port map (gdrw, arw);
  cxl : comparator generic map (8) port map (grs, l, xe0, xl0);
  cxg : comparator generic map (8) port map (grs, l, xe1, xl1);
  lrc : muxn generic map (64, llocs) port map (postl, alphapx(61-llocs to 60),
                                               lrd);
  grc : muxn generic map (64, 8) port map (postg, gdri, grd);
  ret : mux2 generic map (64) port map (xlg, mlrd, grd, gdro);
  flg : muxn generic map (64, llocs) port map (postl, s(61-llocs to 60),
                                               lgammao);
  mlrd <= lrd when xsm else 64b"0";
  xsm <= xl0 and not xe0;
  xlg <= xe1 or not xl1;
  wl <= (xsm and arw) or algw;
  wg <= xlg and arw;
end;

component gregs
  generic (llocs : integer);
  port (s, o, gdri : in bit_vector (0 to 63);
        g, l, grs, gdrw, lgammaw : in bit_vector (0 to 7);
        clock : in bit;
        gdro, lgammao : out bit_vector (0 to 63));
end;

entity pthr is
  port (i : in bit_vector (0 to 15);
        o : out bit_vector (0 to 15);
        ob : out bit_vector (0 to 2));
end;

architecture a1 of pthr
begin
  o <= o"0"&i(3 to 12)&o"0" after 0 ns;
  ob <= i(13 to 15) after 0 ns;
end;

component pthr
  port (i : in bit_vector (0 to 15);
        o : out bit_vector (0 to 15);
        ob : out bit_vector (0 to 2));
end;

entity base1024 is
  port (i : in bit_vector (0 to 55);
        o4, o3, o2, o1, o0 : out bit_vector (0 to 15));
end;

architecture a1 of base1024 is
begin
  o0 <= o"0"&i(46 to 55)&o"0" after 0 ns;
  o1 <= o"0"&i(36 to 45)&o"0" after 0 ns;
  o2 <= o"0"&i(26 to 35)&o"0" after 0 ns;
  o3 <= o"0"&i(16 to 25)&o"0" after 0 ns;
  o4 <= o"0"&i(6 to 15)&o"0" after 0 ns;

component base1024
  port (i : in bit_vector (0 to 55);
        o4, o3, o2, o1, o0 : out bit_vector (0 to 15));
end;

entity rvdec is
  port (rv : in bit_vector (0 to 63);
        n0, n1, n2, n3, b3 : out bit_vector (0 to 7);
        nf : out bit_vector (0 to 15);
        r : out bit_vector (0 to 31));
end;

architecture a1 of rvdec is
begin
  n0 <= h"0"&rv(0 to 3) after 0 ns;
  n1 <= h"0"&rv(4 to 7) after 0 ns;
  n2 <= h"0"&rv(8 to 11) after 0 ns;
  n3 <= h"0"&rv(12 to 15) after 0 ns;
  b3 <= rv(16 to 23) after 0 ns;
  r <= rv(24 to 50) after 0 ns;
  nf <= rv(51 to 63) after 0 ns;
end;

component rvdec
  port (rv : in bit_vector (0 to 63);
        n0, n1, n2, n3, b3 : out bit_vector (0 to 7);
        nf : out bit_vector (0 to 15);
        r : out bit_vector (0 to 31));
end;

entity da5by is
  port (rw : in bit_vector (0 to 4);
        rdt, sdt : in bit_vector (0 to 39);
        sw, clock : in bit;
        v : out bit_vector (0 to 39));
end;

architecture a1 of da5by is
  signal w : bit_vector (0 to 4);
  signal dt : bit_vector (0 to 39);
begin
  wh : mux2 generic map (44) port map (sw, rw(1 to 4)&rdt, h"F"&sdt,
                                       w(1 to 4)&dt);
  h : da_reg generic map (0, 3) port map (w(0), clock, dt(0 to 7), v(0 to 7));
  l : da_reg generic map (2, 5) port map (w(1 to 4), clock,
                                          dt(8 to 39), v(8 to 39));
  w(0) <= rw(0) or sw;
end;

component da5by
  port (rw : in bit_vector (0 to 4);
        rdt, sdt : in bit_vector (0 to 39);
        sw, clock : in bit;
        v : out bit_vector (0 to 39));
end;
