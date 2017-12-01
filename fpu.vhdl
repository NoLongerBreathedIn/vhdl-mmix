-- sel is bits 3, 4, 5, 6|2 of opcode
entity mmix_fpu_one is
  port (y : in bit_vector (0 to 2);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, dr : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 3);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));

end;

architecture a1 of mmix_fpu_one is
  signal r, ztr : bit_vector (0 to 1);
  signal usedr, sln, ffixw, a_nan, inv : bit;
  signal zfr, xle : bit_vector (0 to 63);
  signal zer : bit_vector (0 to 15);
  signal xesh : bit_vector (0 to 39);
  signal xefx, xern, xesq, xesr, xems, xefl : bit_vector (0 to 71);
  signal xemc, xesl, xeaa : bit_vector (0 to 71);
begin
  wrm : mux2 generic map (2) port map (usedr, r, y(1 to 2));
  upf : funpack port map (xern(0 to 63), zfr, zer, open, ztr);
  fixer : ffix port map (zfr, zer, zs, ztr, xefx(0 to 63),
                         xefx(64 to 65)&ffixw&xefx(67 to 71));
  rounder : fround port map (zf, ze, zs, zt, r, xern(0 to 63), xern(64 to 71));
  rooter : fsqrt port map (zf, ze, zs, zt, r, xesq(0 to 63), xesq(64 to 71));
  rouroo : mux2 generic map (72) port map (sel(3), xesq, xern, xesr);
  mbfx : mux2 generic map (72) port map (sel(0), xefx, xesr, xems);
  corr : mux2 generic map (72)
    port map (a_nan, xems, z(0 to 11)&sln&z(13 to 63)&o"0"&inv&h"0", xemc);
  len : ftod port map (z(32 to 63), xle);
  shor : dtof port map (z, dr, xesh(0 to 31), xesh(32 to 39));
  lors : mux2 generic map (72) port map (sel(3), xle&8b"0", 32b"0"&xesh, xesl);
  most : mux2 generic map (72) port map (sel(2), xesl, xemc, xeaa);
  floater : ffloat port map (z, r, sel(3), sel(2),
                             xefl(0 to 63), xefl(64 to 71));
  last : mux2 generic map (72) port map (sel(1), xeaa, xefl, x&exns);
  a_nan <= zt(0) and zt(1);
  inv <= z(12) nand sel(0);
  xefx(66) <= ffixw and not sel(3);
  usedr <= y(0) or y(1) or y(2);
  sln <= z(12) or sel(0);
end;

component mmix_fpu_one
  port (y : in bit_vector (0 to 2);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, dr : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 3);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

-- sel is bits 3, 6, 7 of opcode
entity mmix_fpu_comp is
  port (e, y, yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 2);
        h, l, i : out bit);
end;

architecture a1 of mmix_fpu_comp is
  signal ru, re, rl, eu, ee, s, invalid, rlo, elo, lo0, lo : bit;
begin
  rcmp : fcmp port map (yf, ye, ys, yt, zf, ze, zs, zt, ru, re, rl);
  ecmp : fecmp port map (y, yf, ye, ys, yt, z, zf, ze, zs, zt, e, s, eu&ee);
  invalid <= (eu and sel(2)) when sel(0) else (ru and not sel(1));
  rlo <= ((not re and sel(2)) or (ru and sel(1))) xor (sel(1) and sel(2));
  elo <= (ee xnor sel(1)) when sel(2) else eu;
  lo0 <= elo when sel(0) else rlo;
  i <= invalid;
  lo <= lo0 and not invalid;
  l <= lo;
  h <= rl and lo;
  s <= not sel(1);
end;

component mmix_fpu_comp
  port (e, y, yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 2);
        h, l, i : out bit);
end;

-- sel is bits 3, 5, 6 of opcode
entity mmix_fpu_arith is
  generic (rsteps : integer);
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 2);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7);
        rnf : out bit);
end;

architecture a1 of mmix_fpu_arith is
  signal zas : bit;
  signal xeas, xedv, xerm, xedr, xeml, xemt : bit_vector (0 to 71);
begin
  adsb : fadd port map (yf, ye, ys, yt, zf, ze, zas, zt, r,
                        xeas(0 to 63), xeas(64 to 71));
  cdiv : fdiv port map (yf, ye, ys, yt, zf, ze, zs, zt, r,
                        xedv (0 to 63), xedv(64 to 71));
  crem : frem generic map (rsteps)
    port map (yf, ye, ys, yt, zf, ze, zs, zt,
              xerm(0 to 63), xerm(64 to 71), rnf);
  cmul : fmul port map (yf, ye, ys, yt, zf, ze, zs, zt, r,
                        xeml (0 to 63), xeml(64 to 71));  
  mxdr : mux2 generic map (72) port map (sel(2), xedv, xerm, xedr);
  mdrm : mux2 generic map (72) port map (sel(1), xeml, xedr, xemt);
  mxfi : mux2 generic map (72) port map (sel(0), xeas, xemt, x, exns);
  zas <= zs xor sel(2);
end;

component mmix_fpu_arith
  generic (rsteps : integer);
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 2);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7);
        rnf : out bit);
end;

-- sel is bits 3, 5, 6, 7 of opcode
entity mmix_fpu_two is
  generic (rsteps : integer);
  port (e, y, z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 3);
        x : out bit_vector (0 to 63);
        rnf : out bit;
        exns : out bit_vector (0 to 7));
end;

architecture a1 of mmix_fpu_two is
  signal yf : bit_vector (0 to 63);
  signal ye : bit_vector (0 to 15);
  signal ys, ch, cl, ci, signan, ynan, znan, reg : bit;
  signal yt : bit_vector (0 to 1);
  signal xecm, xerg, xery, xeyz : bit_vector (0 to 71);
begin
  upy : funpack port map (y, yf, ye, ys, yt);
  cmps : mmix_fpu_comp port map (e, y, yf, ye, ys, yt, z, zf, ze, zs, zt,
                                 sel(0)&sel(2 to 3), ch, cl, ci);
  ari : mmix_fpu_arith generic map (rsteps)
    port map (yf, ye, ys, yt, zf, ze, zs, zt, r, sel(0 to 2),
              xerg(0 to 63), xerg(64 to 71), rnf);
  ynmx : mux2 generic map (72)
    port map (ynan, xerg, y(0 to 11)&'1'&y(13 to 63)&o"0"&signan&h"0", xery);
  znmx : mux2 generic map (72)
    port map (znan, xery, z(0 to 11)&'1'&z(13 to 63)&o"0"&signan&h"0", xeyz);
  amux : mux2 generic map (72) port map (reg, xecm, xeyz, x&exns);
  xecm <= (0 to 62 => ch,
           63 => cl,
           67 => ci,
           others => '0');
  ynan <= yt(0) and yt(1);
  znzn <= zt(0) and zt(1);
  signan <= (ynan and not y(12)) or (znan and not z(12));
  reg <= (sel(2) nor sel(3)) or sel(1);
end;

component mmix_fpu_two
  generic (rsteps : integer);
  port (e, y, z, zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 3);
        x : out bit_vector (0 to 63);
        rnf : out bit;
        exns : out bit_vector (0 to 7));
end;

-- sel is bits 0, 2-7 of opcode
entity mmix_fpu is
  generic (rsteps : integer);
  port (e, y, z : in bit_vector (0 to 63);
        r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 6);
        x : out bit_vector (0 to 63);
        rnf : out bit;
        exns : out bit_vector (0 to 7));
end;

architecture a1 of mmix_fpu is
  signal x1, x2, zf : bit_vector (0 to 63);
  signal ze : bit_vector (0 to 15);
  signal zt : bit_vector (0 to 1);
  signal ex1, ex2 : bit_vector (0 to 7);
  signal onelow, which, zs : bit;
begin
  upk : funpack port map (z, zf, ze, zs, zt);
  single : mmix_fpu_one port map (y(61 to 63), z, zf, ze, zs, zt, r,
                                  sel(2 to 4)&onelow,
                                  x1, ex1);
  double : mmix_fpu_two generic map (rsteps) port map (e, y, z, zf, ze, zs, zt,
                                                       r, sel(2)&sel(4 to 6),
                                                       x2, rnf, ex2);
  fmx : mux2 generic map (72) port map (which, x2&ex2, x1&ex1, x&exns);
  which <= sel(0) or sel(3) or (sel(4) and sel(6));
  onelow <= sel(5) or sel(1);
end;

component mmix_fpu
  generic (rsteps : integer);
  port (e, y, z : in bit_vector (0 to 63);
        r : in bit_vector (0 to 1);
        sel : in bit_vector (0 to 6);
        x : out bit_vector (0 to 63);
        rnf : out bit;
        exns : out bit_vector (0 to 7));
end;
