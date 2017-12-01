entity mul is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to 2*len-1));
end;

component mul
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to 2*len-1));
end;

architecture a1 of mul is
begin
  base: if len = 2 generate
    signal i0, i1, i2, i3: bit;
  begin
    ha1 : halfadd port map (i1, i2, x(2), i3);
    ha2 : halfadd port map (i0, i3, x(1), x(0));
    i0 <= y(0) and z(0);
    i1 <= y(1) and z(0);
    i2 <= y(0) and z(1);
    x(3) <= y(1) and z(1);
  end;
  rec: if len > 2 generate
    signal pl, ph, npl, nph: bit_vector (0 to len-1);
    signal yc, zc, pc, tc: bit;
    signal tmp: bit_vector (0 to 1);
    signal am: bit_vector (0 to len/2);
    signal ym, zm, my, mz, yx, zx, pm0: bit_vector (0 to len/2-1);
    signal pm, tm, tm0: bit_vector (0 to len);
  begin
    ay : adder generic map (len/2)
      port map (y(0 to len/2-1), y(len/2 to len-1), ym, yc);
    az : adder generic map (len/2)
      port map (z(0 to len/2-1), z(len/2 to len-1), zm, zc);
    ml : mul generic map (len/2)
      port map (y(len/2 to len-1), z(len/2 to len-1), pl);
    mh : mul generic map (len/2)
      port map (y(0 to len/2-1), z(0 to len/2-1), ph);
    mm : mul generic map (len/2)
      port map (ym, zm, pm0&pm(len/2+1 to len));
    m0 : adder generic map (len/2)
      port map (my, mz, am(1 to len/2), am(0));
    m1 : adder generic map (len/2)
      port map (pm0, am(1 to len/2), pm(1 to len/2), pm(0));
    m2 : adder_1 generic map (len)
      port map (pm(1 to len), npl, tm0(1 to len), tm0(0));
    m3 : adder_1 generic map (len)
      port map (tm0(1 to len), nph, tm(1 to len), tm(0));
    m4 : adder generic map (len)
      port map (tm(1 to len), ph(len/2 to len-1)&pl(0 to len/2-1),
                          x(len/4 to 3*len/4-1), tc);
    m5 : halfadd port map (tc, pc, tmp(1), tmp(0));
    mce: if len > 4 generate
      m6 : adder generic map (len/2)
        port map (y(len/2-2 to len/2-1) => tmp,
                  y(0 to len/2-3) => (others => '0'),
                  z => ph(0 to len/2-1), x => x(0 to len/2-1), c => open);
    end;
    mcex: if len = 4 generate
      m6 : adder generic map (2)
        port map (tmp, ph(0 to 1), x(0 to 1), open);
    end;
    ny : and_gate generic map (len/2) port map (zx, ym, my);
    nz : and_gate generic map (len/2) port map (yx, zm, mz);
    ln : not_gate generic map (len/2) port map (pl, npl);
    hn : not_gate generic map (len/2) port map (ph, nph);
    yx <= (others => yc);
    zx <= (others => zc);
    pc <= tm(0) xor am(0) xor (yc and zc) xor pm(0) xor tm0(0);
    x(3*len/2 to 2*len-1) <= pl(len/2 to len-1);
  end;
end;

entity mul_us is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        h, x : out bit_vector (0 to len-1);
        o : out bit);
end;

architecture a1 of mul_s is
  signal mr : bit_vector (0 to len);
  signal my, mz, yx, zx, t0, t1, t2 : bit_vector (0 to len-1);
begin
  am : mul generic map (len) port map (y, z, mr&x(1 to len-1));
  ny : nand_gate generic map (len) port map (y, zx, my);
  nz : nand_gate generic map (len) port map (z, yx, mz);
  ay : adder_1 generic map (len) port map (mr(0 to len-1), my, t0);
  az : adder_1 generic map (len) port map (t0, my, t1);
  fx : xor_gate generic map (len) port map (t1, mr(len)&t1(0 to len-2), t2);
  ores : or_comb generic map (len) port map (t2, o);
  h <= mr(0 to len-1);
  x(0) <= mr(len);
  yx <= (others => y(0));
  zx <= (others => z(0));
end;

component mul_us
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        h, x : out bit_vector (0 to len-1);
        o : out bit);
end;
