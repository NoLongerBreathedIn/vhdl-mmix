entity ad_reg_2 is
  port (a, c : in bit;
        d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

architecture a1 of ad_reg_2 is
  signal xi, yi, xo, yo, yob, xr, yr : bit_vector (0 to 63);
begin
  xrg : da_reg generic map (0, 6) port map ('1', c, xi, xo);
  yrg : da_reg generic map (0, 6) port map ('1', c, yi, yo);
  ync : not_gate generic map (64) port map (yo, yob);
  xrc : or_gate generic map (64) port map (xo, yob, xr);
  yrc : xnor_gate generic map (64) port map (xo, yo, yr);
  rsc : subber generic map (64) port map (xo, yo, o, open);
  wxy : mux2 generic map (128) port map (a, xr(1 to 63)&'0'&yr, d&64b"0");
end;

component ad_reg_2
  port (a, c : in bit;
        d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

entity is_reg is
  generic (len : integer);
  port (i, s, c : in bit;
        d, g : in bit_vector (0 to len-1);
        o : out bit_vector (0 to len-1));
end;

architecture a1 of is_reg is
  signal aw : bit;
  signal xi, yi, xo, yo, yob, xr, yr, i0, i1, i2, i3 : bit_vector (0 to len-1);
  signal i4 : bit_vector (0 to len-1);
begin
  xrg : al_reg generic map (len) port map (aw, c, xi, xo);
  yrg : al_reg generic map (len) port map (aw, c, yi, yo);
  ync : not_gate generic map (len) port map (yo, yob);
  i0c : and_gate generic map (len) port map (xo, yob, i0);
  i1c : or_gate generic map (len) port map (xo, yob, i1);
  i2c : and_gate generic map (len) port map (i1, g, i2);
  xrc : or_gate generic map (len) port map (i0, i2, xr);
  i3c : xor_gate generic map (len) port map (xo, yo, i3);
  yrc : xor_gate generic map (len) port map (i3, g, yr);
  rsc : subber generic map (len) port map (xo, yo, o, open);
  whx : mux2 generic map (len) port map (i, d, xr(1 to len-1)&'0', xi);
  why : and_gate generic map (len) port map (yr, i4, yi);
  i4 <= (others => i);
  aw <= i or s;
end;

component is_reg
  generic (len : integer);
  port (i, s, c : in bit;
        d, g : in bit_vector (0 to len-1);
        o : out bit_vector (0 to len-1));
end;


entity fonreg8_2 is
  port (a, c : in bit;
        f, d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

architecture a1 of fonreg8_2 is
  signal as, bs, ds : bit_vector (0 to 63);
begin
  whb : or_gate generic map (128) port map (f&f, as&d, bs&ds);
  rrg : da_reg generic map (6, 6) port map (bs, c, ds, o);
  as <= (others => a);
end;

component fonreg8_2
  port (a, c : in bit;
        f, d : in bit_vector (0 to 63);
        o : out bit_vector (0 to 63));
end;

entity sregs_2 is
  port (di : in arrarr (0 to 31) (0 to 63);
        wt : in bit_vector (0 to 31);
        qi : in bit_vector (0 to 63);
        ck : in bit;
        do : out arrarr (0 to 31) (0 to 63));
end;

architecture a1 of sregs_2 is
begin
  rregs: for i from 0 to 31 generate
  begin
    lregs: if i /= 9 and i /= 12 and i /= 15 and i /= 16
             and (i < 19 or i > 21) generate
    begin
      reg : da_reg generic map (0, 6) port map (wt(i), ck, di(i), do(i));
    end;
    sregs: if i = 19 or i = 20 generate
    begin
      sreg : da_reg generic map (0, 3) port map (wt(i), ck, di(i)(56 to 63),
                                                 do(i)(56 to 63));
      do(i)(0 to 55) <= 56b"0";
    end;
  end;
  areg : da_reg generic map (0, 5) port map (wt(21), ck, di(21)(32 to 63),
                                             do(21)(32 to 63));
  ireg : ad_reg_2 port map (wt(12), ck, di(21), do(21));
  kreg : fonreg8_2 port map (wt(15), ck, 30b"0"&qi(31)&33b"0", di(15), do(15));
  qreg : fonreg8_2 port map (wt(16), ck, qi, di(16), do(16));
  do(21)(0 to 31) <= 32b"0";
  do(9) <= h"010101005A662BC1";
end;

